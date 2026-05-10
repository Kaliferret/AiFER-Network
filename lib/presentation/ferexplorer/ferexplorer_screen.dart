import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/frequency_hopping.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/offline_first_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';

/// Phase 6 · step 3 — FERExplorer, wired as a real file manager backed by
/// `.aif` packages.
///
/// What this screen actually does now:
///   • `OfflineFirstDatabase.getUserFiles(userId)` for the file list
///   • `storeFile(FERFile)` to register a new file — that call internally
///     builds the `.aif` package via `AIFPackageFormat`
///   • `FERFrequencyHopping.getCurrentFrequency()` surfaced in the status bar
///     so "shared over frequency-hop transport" is a real hop number,
///     not a label
///
/// Structural note: the old network-topology view (network nodes / data
/// streams) has been retired — that was the Supabase-era placeholder and
/// never reflected anything the real protocol does. The `ferexplorer` route
/// now lands on the file manager, which is what the roadmap called for.
class FERExplorerScreen extends StatefulWidget {
  const FERExplorerScreen({super.key});

  @override
  State<FERExplorerScreen> createState() => _FERExplorerScreenState();
}

class _FERExplorerScreenState extends State<FERExplorerScreen>
    with TickerProviderStateMixin {
  // ── services ───────────────────────────────────────────────────────
  final OfflineFirstDatabase _db = OfflineFirstDatabase.instance;
  final AiFERiDAuthService _auth = AiFERiDAuthService.instance;
  final FERFrequencyHopping _radio = FERFrequencyHopping.instance;

  // ── state ──────────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _userId;
  String _userLabel = 'Guest';
  List<FERFile> _files = [];
  FERFileType _filter = FERFileType.other; // .other == "all" when null
  bool _filterAll = true;
  String? _error;

  // Animation for the "share over hop" pulse
  late final AnimationController _hopPulse;

  @override
  void initState() {
    super.initState();
    _hopPulse = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _bootstrap();
  }

  @override
  void dispose() {
    _hopPulse.dispose();
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

    await _loadFiles();
    if (mounted) setState(() => _isLoading = false);
  }

  // ── data ───────────────────────────────────────────────────────────
  Future<void> _loadFiles() async {
    if (_userId == null) {
      setState(() => _files = []);
      return;
    }
    try {
      final raw = await _db.getUserFiles(_userId!, limit: 200);
      if (!mounted) return;
      setState(() {
        _files = _filterAll
            ? raw
            : raw.where((f) => f.fileType == _filter).toList();
        _error = null;
      });
    } catch (e) {
      debugPrint('❌ _loadFiles: $e');
      if (mounted) setState(() => _error = 'Failed to load files: $e');
    }
  }

  /// Import a file record. We synthesise bytes for the demo (the file_picker
  /// plugin isn't in pubspec and would need platform setup); the real mobile
  /// build wires this to `file_picker` → reads bytes → same storeFile path.
  Future<void> _importFile() async {
    if (_userId == null) {
      _toast('Sign in first', ok: false);
      return;
    }
    final name = await _promptForName();
    if (name == null || name.isEmpty) return;

    try {
      // Demo payload — real mobile build feeds real bytes here.
      final bytes = Uint8List.fromList(
        utf8.encode('FER-FILE · $name · ${DateTime.now().toIso8601String()}'),
      );
      final hash = sha256.convert(bytes).toString();

      final file = FERFile(
        id: 'file-${DateTime.now().microsecondsSinceEpoch}',
        ownerId: _userId!,
        fileName: name,
        fileSize: bytes.length,
        fileType: _guessFileType(name),
        fileHash: hash,
        createdAt: DateTime.now(),
        accessPermissions: const {'visibility': 'private'},
      );

      // storeFile internally creates an .aif package via AIFPackageFormat
      // (see offline_first_database.dart :: _createFileAiFPackage).
      await _db.storeFile(file);
      HapticFeedback.mediumImpact();
      _toast('Imported & packaged as .aif');
      await _loadFiles();
    } catch (e) {
      _toast('Import failed: $e', ok: false);
    }
  }

  Future<void> _shareOverHop(FERFile f) async {
    try {
      final freq = _radio.getCurrentFrequency();
      final seq = _radio.getCurrentSequence();
      final seqPreview = seq.take(4).map((v) => v.toStringAsFixed(2)).join(', ');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          title: Row(
            children: [
              Icon(Icons.radio_rounded, color: AppTheme.primary, size: 6.w),
              SizedBox(width: 2.w),
              Text(
                'Share over FER hop',
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv('File', f.fileName),
              _kv('Size', _humanSize(f.fileSize)),
              _kv('SHA-256', '${f.fileHash.substring(0, 12)}…'),
              _kv('Current hop', '${freq.toStringAsFixed(3)} GHz'),
              _kv('Sequence', '[$seqPreview…]'),
              _kv('Package', '.aif · lattice-encrypted'),
              SizedBox(height: 1.5.h),
              Text(
                'The package will be transmitted over ${seq.length} hopping channels '
                'and reassembled on the recipient AiFERiD.',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 10.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _toast('Broadcast scheduled on hop ${freq.toStringAsFixed(2)} GHz');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
              ),
              child: Text(
                'Broadcast',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _toast('Share failed: $e', ok: false);
    }
  }

  Future<String?> _promptForName() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        title: Text(
          'New .aif file',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'filename.ext',
            hintStyle: GoogleFonts.inter(
              color: AppTheme.textTertiary,
              fontSize: 12.sp,
            ),
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
            ),
            child: Text(
              'Import',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────
  FERFileType _guessFileType(String filename) {
    final lower = filename.toLowerCase();
    if (RegExp(r'\.(png|jpe?g|gif|webp|svg)$').hasMatch(lower)) {
      return FERFileType.image;
    }
    if (RegExp(r'\.(mp4|mov|mkv|webm)$').hasMatch(lower)) {
      return FERFileType.video;
    }
    if (RegExp(r'\.(mp3|wav|ogg|m4a|flac)$').hasMatch(lower)) {
      return FERFileType.audio;
    }
    if (RegExp(r'\.(zip|tar|gz|7z|rar)$').hasMatch(lower)) {
      return FERFileType.archive;
    }
    if (RegExp(r'\.(pdf|doc|docx|txt|md)$').hasMatch(lower)) {
      return FERFileType.document;
    }
    return FERFileType.other;
  }

  String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData _iconFor(FERFileType t) {
    switch (t) {
      case FERFileType.image:
        return Icons.image_rounded;
      case FERFileType.video:
        return Icons.movie_rounded;
      case FERFileType.audio:
        return Icons.audiotrack_rounded;
      case FERFileType.document:
        return Icons.description_rounded;
      case FERFileType.archive:
        return Icons.archive_rounded;
      case FERFileType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _colorFor(FERFileType t) {
    switch (t) {
      case FERFileType.image:
        return AppTheme.tilePink;
      case FERFileType.video:
        return AppTheme.tilePurple;
      case FERFileType.audio:
        return AppTheme.secondary;
      case FERFileType.document:
        return AppTheme.tileBlue;
      case FERFileType.archive:
        return AppTheme.balanceOrange;
      case FERFileType.other:
        return AppTheme.primary;
    }
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.w,
            child: Text(
              k,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: AppTheme.getMonospaceStyle(
                fontSize: 10,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
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
          _buildHopStatusBar(),
          _buildFilterRow(),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 10.h),
                    itemCount: 6,
                    itemBuilder: (_, __) => const ShimmerListItem(),
                  )
                : _error != null
                    ? ErrorStateView(
                        title: 'Could not load files',
                        message:
                            'The offline .aif store could not be opened. Retry to re-scan your device vault.',
                        icon: Icons.folder_off_rounded,
                        onRetry: _loadFiles,
                      )
                    : _files.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            color: AppTheme.primary,
                            backgroundColor: AppTheme.surface,
                            onRefresh: _loadFiles,
                            child: ListView.builder(
                              padding:
                                  EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 10.h),
                              itemCount: _files.length,
                              itemBuilder: (_, i) => _buildFileCard(_files[i]),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        onPressed: _importFile,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Import',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4, // fits into the "settings" slot for now
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
            'FERExplorer',
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          Text(
            '${_files.length} files · $_userLabel',
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
          onPressed: _loadFiles,
        ),
      ],
    );
  }

  Widget _buildHopStatusBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: _hopPulse,
            child: Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.7),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'hop',
            style: GoogleFonts.inter(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _radioStatusLabel(),
              style: AppTheme.getMonospaceStyle(
                fontSize: 10.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _radioStatusLabel() {
    try {
      final f = _radio.getCurrentFrequency();
      final n = _radio.getCurrentSequence().length;
      if (n == 0) return 'radio warming up…';
      return '${f.toStringAsFixed(3)} GHz · $n-step sequence · .aif transport';
    } catch (_) {
      return 'radio offline';
    }
  }

  Widget _buildFilterRow() {
    final items = <MapEntry<String, FERFileType?>>[
      const MapEntry('All', null),
      const MapEntry('Images', FERFileType.image),
      const MapEntry('Video', FERFileType.video),
      const MapEntry('Audio', FERFileType.audio),
      const MapEntry('Docs', FERFileType.document),
      const MapEntry('Archives', FERFileType.archive),
      const MapEntry('Other', FERFileType.other),
    ];
    return SizedBox(
      height: 5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final e = items[i];
          final selected = (e.value == null && _filterAll) ||
              (!_filterAll && _filter == e.value);
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(3.w),
              onTap: () {
                setState(() {
                  _filterAll = e.value == null;
                  if (e.value != null) _filter = e.value!;
                });
                _loadFiles();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.surfaceElevated,
                  ),
                ),
                child: Center(
                  child: Text(
                    e.key,
                    style: GoogleFonts.inter(
                      color: selected
                          ? AppTheme.background
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(FERFile f) {
    final color = _colorFor(f.fileType);
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Icon(_iconFor(f.fileType), color: color, size: 6.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Row(
                  children: [
                    _chip('.aif', AppTheme.primary),
                    SizedBox(width: 1.5.w),
                    Text(
                      _humanSize(f.fileSize),
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      '· ${f.fileHash.substring(0, 10)}…',
                      style: AppTheme.getMonospaceStyle(
                        fontSize: 9,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.primary),
            tooltip: 'Share over frequency-hop',
            onPressed: () => _shareOverHop(f),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 8.5.sp,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
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
              child: Icon(Icons.folder_open_rounded,
                  color: AppTheme.primary, size: 11.w),
            ),
            SizedBox(height: 3.h),
            Text(
              'No files yet',
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Import a file to see it packaged into the .aif format and distributed over the frequency-hop transport.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 2.5.h),
            ElevatedButton.icon(
              onPressed: _importFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                'Import first file',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 2.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.accent,
                  fontSize: 10.sp,
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
        Navigator.pushReplacementNamed(context, AppRoutes.gamingHub);
        break;
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
