import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/offline_first_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
// Import new mini-games
import '../games/tic_tac_toe/tic_tac_toe_screen.dart';
import '../games/connect_four/connect_four_screen.dart';
import '../games/memory_match/memory_match_screen.dart';
import '../games/snake/snake_screen.dart';
import '../games/game_2048/game_2048_screen.dart';
import '../games/math_racer/math_racer_screen.dart';
import '../games/word_search/word_search_screen.dart';
import '../games/bubble_pop/bubble_pop_screen.dart';
import '../games/fer_world/fer_world_screen.dart';

/// Phase 6 · step 4 — Gaming Hub wired to `OfflineFirstDatabase.FERGamingSession`.
///
/// • Identity:  `AiFERiDAuthService.getCurrentUser()`
/// • Sessions:  `OfflineFirstDatabase.getGamingSessions(userId:)`
///              `OfflineFirstDatabase.storeGamingSession(FERGamingSession)`
/// • Catalog:   static list of FER Network native titles (placeholder catalog,
///              a real game-discovery API is out of scope for Phase 6).
///
/// Zero Supabase, zero OpenAI wrappers. All game state is local-first.
class GamingHubScreen extends StatefulWidget {
  const GamingHubScreen({super.key});

  @override
  State<GamingHubScreen> createState() => _GamingHubScreenState();
}

class _GamingHubScreenState extends State<GamingHubScreen>
    with TickerProviderStateMixin {
  // ── services ───────────────────────────────────────────────────────
  final OfflineFirstDatabase _db = OfflineFirstDatabase.instance;
  final AiFERiDAuthService _auth = AiFERiDAuthService.instance;

  // ── tabs ───────────────────────────────────────────────────────────
  late final TabController _tabs;
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  // ── state ──────────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _userId;
  String _userLabel = 'Guest';
  List<FERGamingSession> _mySessions = [];

  // Derived stats
  int get _activeCount =>
      _mySessions.where((s) => s.status == GameSessionStatus.active).length;
  int get _waitingCount =>
      _mySessions.where((s) => s.status == GameSessionStatus.waiting).length;
  int get _completedCount =>
      _mySessions.where((s) => s.status == GameSessionStatus.completed).length;
  int get _totalScore => _mySessions.fold<int>(
      0, (sum, s) => sum + ((s.sessionData['score'] as int?) ?? 0));
  int get _totalPlaytimeMin => _mySessions.fold<int>(
      0,
      (sum, s) =>
          sum + ((s.sessionData['playtime_minutes'] as int?) ?? 0));

  // Catalog (displayed on the middle tab) - Updated with AIFER v11 mini-games
  static const List<_GameCatalogEntry> _catalog = [
    // Classic Mini-Games
    _GameCatalogEntry(
      id: 'game.tic_tac_toe',
      name: 'Tic-Tac-Toe',
      tag: 'Classic',
      tagline: '3x3 grid · X vs O · Score tracking',
      color: Color(0xFF00E5FF),
      icon: Icons.grid_on_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.connect_four',
      name: 'Connect Four',
      tag: 'Strategy',
      tagline: '6x7 grid · Drop pieces · Win detection',
      color: Color(0xFF448AFF),
      icon: Icons.view_column_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.memory_match',
      name: 'Memory Match',
      tag: 'Puzzle',
      tagline: '16 cards · 8 pairs · Find matches',
      color: Color(0xFF39FF14),
      icon: Icons.psychology_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.snake',
      name: 'Snake',
      tag: 'Arcade',
      tagline: 'Classic snake · Eat food · Grow longer',
      color: Color(0xFF7B61FF),
      icon: Icons.show_chart_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.2048',
      name: '2048',
      tag: 'Puzzle',
      tagline: 'Merge tiles · Reach 2048 · Score high',
      color: Color(0xFFE040FB),
      icon: Icons.grid_view_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.math_racer',
      name: 'Math Racer',
      tag: 'Educational',
      tagline: 'Fast math · 60s timer · Streak bonuses',
      color: Color(0xFFFFD740),
      icon: Icons.calculate_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.word_search',
      name: 'Word Search',
      tag: 'Puzzle',
      tagline: '10x10 grid · Find 8 words · Multi-direction',
      color: Color(0xFF69F0AE),
      icon: Icons.text_fields_rounded,
    ),
    _GameCatalogEntry(
      id: 'game.bubble_pop',
      name: 'Bubble Pop',
      tag: 'Arcade',
      tagline: 'Pop groups · Gravity effect · Score high',
      color: Color(0xFFFF5252),
      icon: Icons.circle_rounded,
    ),
    // FER World
    _GameCatalogEntry(
      id: 'game.fer_world_2d',
      name: 'FER World 2D',
      tag: 'Metaverse',
      tagline: '2D open world · Ferret avatar · Coming soon',
      color: Color(0xFF40C4FF),
      icon: Icons.public_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      await _db.initialize();
      await _auth.initialize();
    } catch (_) {}

    final user = _auth.getCurrentUser();
    _userId = user?.walletAddress ?? user?.ferretId;
    _userLabel = user?.ferretId ?? user?.walletAddress ?? 'Guest';

    await _reload();
    if (mounted) setState(() => _isLoading = false);
  }

  // ── data ───────────────────────────────────────────────────────────
  String? _loadError;

  Future<void> _reload() async {
    if (_userId == null) {
      setState(() => _mySessions = []);
      return;
    }
    try {
      final sessions =
          await _db.getGamingSessions(userId: _userId, limit: 200);
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (!mounted) return;
      setState(() {
        _mySessions = sessions;
        _loadError = null;
      });
    } catch (e) {
      debugPrint('❌ gaming reload: $e');
      if (mounted) setState(() => _loadError = e.toString());
    }
  }

  Future<void> _startSession(_GameCatalogEntry g) async {
    if (_userId == null) {
      _toast('Sign in first', ok: false);
      return;
    }
    
    // Navigate to the actual game screen based on game ID
    Widget? gameScreen;
    switch (g.id) {
      case 'game.tic_tac_toe':
        gameScreen = const TicTacToeScreen();
        break;
      case 'game.connect_four':
        gameScreen = const ConnectFourScreen();
        break;
      case 'game.memory_match':
        gameScreen = const MemoryMatchScreen();
        break;
      case 'game.snake':
        gameScreen = const SnakeScreen();
        break;
      case 'game.2048':
        gameScreen = const Game2048Screen();
        break;
      case 'game.math_racer':
        gameScreen = const MathRacerScreen();
        break;
      case 'game.word_search':
        gameScreen = const WordSearchScreen();
        break;
      case 'game.bubble_pop':
        gameScreen = const BubblePopScreen();
        break;
      case 'game.fer_world_2d':
        gameScreen = const FerWorldScreen();
        break;
      default:
        // For placeholder games, use the original session logic
        final now = DateTime.now();
        final session = FERGamingSession(
          id: 'gs-${now.microsecondsSinceEpoch}',
          gameId: g.id,
          hostUserId: _userId!,
          sessionData: {
            'game_name': g.name,
            'tag': g.tag,
            'score': 0,
            'playtime_minutes': 0,
            'started_at': now.toIso8601String(),
          },
          status: GameSessionStatus.waiting,
          createdAt: now,
          updatedAt: now,
        );
        try {
          await _db.storeGamingSession(session);
          HapticFeedback.mediumImpact();
          _toast('${g.name} · lobby opened');
          await _reload();
          _tabs.animateTo(0);
          return;
        } catch (e) {
          _toast('Failed to start session: $e', ok: false);
          return;
        }
    }
    
    // Navigate to the game screen
    if (gameScreen != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => gameScreen!),
      );
    }
  }

  Future<void> _advanceSession(FERGamingSession s, GameSessionStatus next) async {
    final updated = FERGamingSession(
      id: s.id,
      gameId: s.gameId,
      hostUserId: s.hostUserId,
      sessionData: {
        ...s.sessionData,
        if (next == GameSessionStatus.completed)
          'score': (s.sessionData['score'] as int? ?? 0) + 100,
        if (next == GameSessionStatus.completed)
          'playtime_minutes':
              (s.sessionData['playtime_minutes'] as int? ?? 0) + 7,
      },
      status: next,
      createdAt: s.createdAt,
      updatedAt: DateTime.now(),
    );
    try {
      await _db.storeGamingSession(updated);
      _toast('Status → ${next.name}');
      await _reload();
    } catch (e) {
      _toast('Update failed: $e', ok: false);
    }
  }

  // ── helpers ────────────────────────────────────────────────────────
  String _shortId(String id) =>
      id.length <= 10 ? id : '${id.substring(0, 6)}…${id.substring(id.length - 4)}';

  Color _statusColor(GameSessionStatus s) {
    switch (s) {
      case GameSessionStatus.active:
      case GameSessionStatus.inProgress:
        return AppTheme.primary;
      case GameSessionStatus.waiting:
        return AppTheme.balanceOrange;
      case GameSessionStatus.completed:
        return AppTheme.secondary;
      case GameSessionStatus.cancelled:
        return AppTheme.accent;
    }
  }

  void _toast(String msg, {bool ok = true}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: ok ? AppTheme.primary : AppTheme.accent,
      textColor: AppTheme.background,
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildTabs(),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 4,
                    itemBuilder: (_, __) => const ShimmerListItem(),
                  )
                : _loadError != null
                    ? ErrorStateView(
                        title: 'Could not load sessions',
                        message:
                            'The local gaming cache failed to open. Retry to re-scan your offline session store.',
                        icon: Icons.sports_esports_outlined,
                        onRetry: _reload,
                      )
                    : TabBarView(
                        controller: _tabs,
                        children: [
                          _buildSessionsTab(),
                          _buildCatalogTab(),
                          _buildStatsTab(),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: _handleBottomNav,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gaming Hub',
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          Text(
            _userLabel,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 9.5.sp,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
          onPressed: _reload,
        ),
      ],
    );
  }

  /// Green header card — mirrors the dashboard's "Play Games" tile colour,
  /// makes the whole screen feel like the expansion of that tile.
  Widget _buildHeaderCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.tileGreen,
            AppTheme.tileGreen.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.tileGreen.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3.5.w),
              ),
              child: Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 7.5.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_activeCount active · $_waitingCount waiting',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  _totalScore.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  'Total score · $_completedCount completed · ${_totalPlaytimeMin}m played',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: TabBar(
        controller: _tabs,
        labelColor: AppTheme.background,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10.5.sp),
        unselectedLabelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 10.5.sp),
        indicator: BoxDecoration(
          color: AppTheme.tileGreen,
          borderRadius: BorderRadius.circular(3.w),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'My Sessions'),
          Tab(text: 'Catalog'),
          Tab(text: 'Stats'),
        ],
      ),
    );
  }

  // ── Sessions tab ──────────────────────────────────────────────────
  Widget _buildSessionsTab() {
    if (_mySessions.isEmpty) {
      return _buildEmpty(
        icon: Icons.videogame_asset_off_rounded,
        title: 'No sessions yet',
        subtitle: 'Pick a game from the catalog to open a lobby.',
        cta: 'Browse catalog',
        color: AppTheme.tileGreen,
        onTap: () => _tabs.animateTo(1),
      );
    }
    return RefreshIndicator(
      color: AppTheme.tileGreen,
      backgroundColor: AppTheme.surface,
      onRefresh: _reload,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
        itemCount: _mySessions.length,
        itemBuilder: (_, i) => _buildSessionCard(_mySessions[i]),
      ),
    );
  }

  Widget _buildSessionCard(FERGamingSession s) {
    final name = s.sessionData['game_name']?.toString() ?? s.gameId;
    final tag = s.sessionData['tag']?.toString() ?? '';
    final score = s.sessionData['score'] as int? ?? 0;
    final color = _statusColor(s.status);
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child:
                    Icon(Icons.sports_esports_rounded, color: color, size: 5.w),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      '${_shortId(s.id)} · $tag',
                      style: AppTheme.getMonospaceStyle(
                        fontSize: 9,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(1.5.w),
                ),
                child: Text(
                  s.status.name,
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 8.5.sp,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Row(
            children: [
              Icon(Icons.stars_rounded,
                  color: AppTheme.balanceOrange, size: 4.w),
              SizedBox(width: 1.w),
              Text(
                '$score pts',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (s.status == GameSessionStatus.waiting)
                _miniBtn(
                  'Enter',
                  color: AppTheme.primary,
                  onTap: () =>
                      _advanceSession(s, GameSessionStatus.inProgress),
                ),
              if (s.status == GameSessionStatus.inProgress) ...[
                _miniBtn(
                  'Finish',
                  color: AppTheme.secondary,
                  onTap: () =>
                      _advanceSession(s, GameSessionStatus.completed),
                ),
              ],
              if (s.status == GameSessionStatus.active ||
                  s.status == GameSessionStatus.waiting ||
                  s.status == GameSessionStatus.inProgress) ...[
                SizedBox(width: 1.5.w),
                _miniBtn(
                  'Cancel',
                  color: AppTheme.accent,
                  outline: true,
                  onTap: () =>
                      _advanceSession(s, GameSessionStatus.cancelled),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(String label,
      {required Color color,
      bool outline = false,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(2.w),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(2.w),
          border: outline ? Border.all(color: color, width: 1.2) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: outline ? color : AppTheme.background,
            fontWeight: FontWeight.w700,
            fontSize: 9.5.sp,
          ),
        ),
      ),
    );
  }

  // ── Catalog tab ───────────────────────────────────────────────────
  Widget _buildCatalogTab() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
      itemCount: _catalog.length,
      itemBuilder: (_, i) => _buildCatalogCard(_catalog[i]),
    );
  }

  Widget _buildCatalogCard(_GameCatalogEntry g) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: Row(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [g.color, g.color.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(3.5.w),
            ),
            child: Icon(g.icon, color: Colors.white, size: 7.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      g.name,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: g.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        g.tag,
                        style: GoogleFonts.inter(
                          color: g.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 8.5.sp,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.3.h),
                Text(
                  g.tagline,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          _miniBtn(
            'Play',
            color: AppTheme.tileGreen,
            onTap: () => _startSession(g),
          ),
        ],
      ),
    );
  }

  // ── Stats tab ─────────────────────────────────────────────────────
  Widget _buildStatsTab() {
    final perGame = <String, int>{};
    for (final s in _mySessions) {
      final name = s.sessionData['game_name']?.toString() ?? s.gameId;
      perGame.update(name, (v) => v + 1, ifAbsent: () => 1);
    }

    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _statRow('Total sessions', _mySessions.length.toString(),
            AppTheme.tileGreen),
        _statRow('Active / in-progress', _activeCount.toString(),
            AppTheme.primary),
        _statRow('Waiting in lobby', _waitingCount.toString(),
            AppTheme.balanceOrange),
        _statRow('Completed', _completedCount.toString(), AppTheme.secondary),
        _statRow('Total score', _totalScore.toString(),
            AppTheme.balanceOrange),
        _statRow('Total playtime', '${_totalPlaytimeMin}m',
            AppTheme.tilePurple),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: AppTheme.surfaceElevated),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sessions by game',
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 1.5.h),
              if (perGame.isEmpty)
                Text(
                  'No data yet — play something to populate this.',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp,
                  ),
                )
              else
                ...perGame.entries.map((e) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 11.sp,
                            ),
                          ),
                          Text(
                            '${e.value}×',
                            style: AppTheme.getMonospaceStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: Row(
        children: [
          Container(
            width: 1.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ── shared empty state ────────────────────────────────────────────
  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    String? cta,
    Color color = AppTheme.primary,
    VoidCallback? onTap,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: AppTheme.surfaceElevated),
              ),
              child: Icon(icon, color: color, size: 11.w),
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11.sp,
                height: 1.5,
              ),
            ),
            if (cta != null && onTap != null) ...[
              SizedBox(height: 2.5.h),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppTheme.background,
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: Text(
                  cta,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleBottomNav(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.messagingInterface);
        break;
      case 2:
        break; // already here
      case 3:
        Navigator.pushReplacementNamed(
            context, AppRoutes.blockchainWalletManager);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.deviceSettings);
        break;
    }
  }
}

class _GameCatalogEntry {
  final String id;
  final String name;
  final String tag;
  final String tagline;
  final Color color;
  final IconData icon;

  const _GameCatalogEntry({
    required this.id,
    required this.name,
    required this.tag,
    required this.tagline,
    required this.color,
    required this.icon,
  });
}
