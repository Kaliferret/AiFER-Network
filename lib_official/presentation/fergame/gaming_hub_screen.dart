<![CDATA[import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/offline_first_database.dart';
import '../../widgets/unified_sliding_menu.dart';
import '../../core/fer_quantum_encryption.dart';

/// FERGame Gaming Hub Screen
/// Multiplayer gaming platform with quantum protocol
class FERGameScreen extends StatefulWidget {
  final AiFERiDUserProfile? userProfile;
  final Function(FERAppType) onAppSelected;
  
  const FERGameScreen({
    Key? key,
    this.userProfile,
    required this.onAppSelected,
  }) : super(key: key);
  
  @override
  _FERGameScreenState createState() => _FERGameScreenState();
}

class _FERGameScreenState extends State<FERGameScreen> 
    with TickerProviderStateMixin {
  
  final OfflineFirstDatabase _database = OfflineFirstDatabase.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<FERGame> _availableGames = [];
  List<GameSession> _activeSessions = [];
  List<FERGame> _featuredGames = [];
  List<GameTournament> _tournaments = [];
  
  late TabController _tabController;
  
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  
  // User stats
  int _totalPlayTime = 0; // minutes
  int _gamesPlayed = 0;
  int _tournamentsWon = 0;
  double _winRate = 0.0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeGamingHub();
    _setupRealtimeUpdates();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Gaming header with stats
          _buildGamingHeader(),
          
          // Tab bar for different views
          _buildGameTabBar(),
          
          // Main content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGameLibraryView(),
                _buildActiveSessionsView(),
                _buildTournamentView(),
                _buildMyStatsView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  /// Build gaming header
  Widget _buildGamingHeader() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // User stats row
          Row(
            children: [
              // User avatar and info
              CircleAvatar(
                radius: 24.0,
                backgroundColor: FERColors.primary.withOpacity(0.2),
                backgroundImage: widget.userProfile?.ferretId.isNotEmpty == true
                  ? null
                  : NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=${widget.userProfile?.id}'),
                child: widget.userProfile?.ferretId.isNotEmpty == true
                  ? Icon(Icons.pets, color: FERColors.primary)
                  : null,
              ),
              
              SizedBox(width: 12.0),
              
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userProfile?.ferretId.isNotEmpty == true
                        ? widget.userProfile!.ferretId
                        : 'FER Gamer',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        _buildStatBadge('⏱️', '${_totalPlayTime}h'),
                        SizedBox(width: 8.0),
                        _buildStatBadge('🎮', '$_gamesPlayed'),
                        SizedBox(width: 8.0),
                        _buildStatBadge('🏆', '$_tournamentsWon'),
                        SizedBox(width: 8.0),
                        _buildStatBadge('📊', '${(_winRate * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Online status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.0),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.0),
          
          // Featured games carousel
          _buildFeaturedGamesCarousel(),
        ],
      ),
    );
  }
  
  /// Build stat badge
  Widget _buildStatBadge(String icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: FERColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 11.0),
          ),
          SizedBox(width: 4.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              color: FERColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build featured games carousel
  Widget _buildFeaturedGamesCarousel() {
    if (_featuredGames.isEmpty) return Container();
    
    return Container(
      height: 180.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredGames.length,
        itemBuilder: (context, index) {
          final game = _featuredGames[index];
          return Container(
            width: 320.0,
            margin: EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              image: DecorationImage(
                image: NetworkImage(game.thumbnailUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                
                // Game info
                Positioned(
                  bottom: 12.0,
                  left: 12.0,
                  right: 12.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14.0,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            '${game.minPlayers}-${game.maxPlayers} players',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Icon(
                            Icons.star,
                            size: 14.0,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            game.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () => _launchGame(game),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FERColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 36.0),
                        ),
                        child: Text('Play Now'),
                      ),
                    ],
                  ),
                ),
                
                // Live indicator
                if (game.hasActiveSessions)
                  Positioned(
                    top: 12.0,
                    right: 12.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Build game tab bar
  Widget _buildGameTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: FERColors.primary,
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.caption?.color,
        tabs: [
          Tab(text: 'Library'),
          Tab(text: 'Active'),
          Tab(text: 'Tournaments'),
          Tab(text: 'My Stats'),
        ],
      ),
    );
  }
  
  /// Build game library view
  Widget _buildGameLibraryView() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search and filter row
          Row(
            children: [
              // Search bar
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search games...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              SizedBox(width: 12.0),
              
              // Category filter
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list),
                onSelected: _filterByCategory,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'all', child: Text('All Games')),
                  PopupMenuItem(value: 'action', child: Text('Action')),
                  PopupMenuItem(value: 'puzzle', child: Text('Puzzle')),
                  PopupMenuItem(value: 'strategy', child: Text('Strategy')),
                  PopupMenuItem(value: 'racing', child: Text('Racing')),
                  PopupMenuItem(value: 'sports', child: Text('Sports')),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 16.0),
          
          // Games grid
          Expanded(
            child: _buildGamesGrid(),
          ),
        ],
      ),
    );
  }
  
  /// Build games grid
  Widget _buildGamesGrid() {
    final filteredGames = _getFilteredGames();
    
    if (filteredGames.isEmpty) {
      return _buildEmptyState(
        icon: Icons.sports_esports,
        title: 'No Games Found',
        subtitle: 'Try adjusting your search or filters',
      );
    }
    
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return _buildGameCard(game);
      },
    );
  }
  
  /// Build game card
  Widget _buildGameCard(FERGame game) {
    return GestureDetector(
      onTap: () => _showGameDetails(game),
      onLongPress: () => _showGameOptions(game),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: game.hasActiveSessions ? FERColors.primary : Colors.grey.withOpacity(0.2),
            width: game.hasActiveSessions ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                  image: DecorationImage(
                    image: NetworkImage(game.thumbnailUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Game type badge
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          game.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Live indicator
                    if (game.hasActiveSessions)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    
                    // Rating overlay
                    Positioned(
                      bottom: 8.0,
                      right: 8.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 10.0,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 2.0),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Game info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4.0),
                    
                    Text(
                      game.description,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Spacer(),
                    
                    // Player count and quick actions
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 12.0,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          '${game.minPlayers}-${game.maxPlayers}',
                          style: TextStyle(
                            fontSize: 9.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        Spacer(),
                        
                        // Quick play button
                        if (game.canQuickPlay)
                          InkWell(
                            onTap: () => _quickPlayGame(game),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                              decoration: BoxDecoration(
                                color: FERColors.primary,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Quick Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build active sessions view
  Widget _buildActiveSessionsView() {
    if (_activeSessions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending,
        title: 'No Active Sessions',
        subtitle: 'Join or host a game to get started',
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _activeSessions.length,
        itemBuilder: (context, index) {
          final session = _activeSessions[index];
          return _buildGameSessionCard(session);
        },
      ),
    );
  }
  
  /// Build game session card
  Widget _buildGameSessionCard(GameSession session) {
    final isMySession = session.hostUserId == widget.userProfile?.id;
    final isJoinable = session.status == GameSessionStatus.waiting && 
                      session.currentPlayers < session.maxPlayers;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: isMySession 
          ? Border.all(color: FERColors.primary, width: 2)
          : Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: NetworkImage(session.gameThumbnail),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          session.sessionName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Host: ${session.hostName}',
              style: TextStyle(fontSize: 12.0),
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.people, size: 12.0, color: Colors.grey[600]),
                SizedBox(width: 4.0),
                Text(
                  '${session.currentPlayers}/${session.maxPlayers} players',
                  style: TextStyle(fontSize: 11.0, color: Colors.grey[600]),
                ),
                SizedBox(width: 12.0),
                Icon(Icons.public, size: 12.0, color: Colors.grey[600]),
                SizedBox(width: 4.0),
                Text(
                  session.isPrivate ? 'Private' : 'Public',
                  style: TextStyle(fontSize: 11.0, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Session status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: _getStatusColor(session.status),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                session.status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(height: 8.0),
            
            if (isJoinable)
              ElevatedButton(
                onPressed: () => _joinGameSession(session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FERColors.primary,
                  minimumSize: Size(60.0, 25.0),
                ),
                child: Text(
                  'JOIN',
                  style: TextStyle(fontSize: 10.0),
                ),
              )
            else if (isMySession)
              ElevatedButton(
                onPressed: () => _manageGameSession(session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FERColors.secondary,
                  minimumSize: Size(60.0, 25.0),
                ),
                child: Text(
                  'MANAGE',
                  style: TextStyle(fontSize: 10.0),
                ),
              )
            else
              Text(
                session.status == GameSessionStatus.inProgress ? 'IN PROGRESS' : 'FULL',
                style: TextStyle(
                  fontSize: 9.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build tournament view
  Widget _buildTournamentView() {
    if (_tournaments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events,
        title: 'No Tournaments Available',
        subtitle: 'Check back later for upcoming tournaments',
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _tournaments.length,
        itemBuilder: (context, index) {
          final tournament = _tournaments[index];
          return _buildTournamentCard(tournament);
        },
      ),
    );
  }
  
  /// Build tournament card
  Widget _buildTournamentCard(GameTournament tournament) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FERColors.primary.withOpacity(0.1),
            FERColors.primaryDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FERColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tournament trophy
              Icon(
                Icons.emoji_events,
                size: 24.0,
                color: Colors.amber,
              ),
              SizedBox(width: 12.0),
              
              // Tournament info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tournament.description,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.0),
          
          // Tournament details
          Row(
            children: [
              _buildTournamentDetail(
                Icons.people,
                '${tournament.currentParticipants}/${tournament.maxParticipants}',
                'Players',
              ),
              SizedBox(width: 16.0),
              _buildTournamentDetail(
                Icons.attach_money,
                tournament.entryFee.toString(),
                'Entry Fee',
              ),
              SizedBox(width: 16.0),
              _buildTournamentDetail(
                Icons.timer,
                _formatDuration(tournament.startTime.difference(DateTime.now())),
                'Starts In',
              ),
            ],
          ),
          
          SizedBox(height: 12.0),
          
          // Prize pool and join button
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16.0,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      'Prize Pool: ${tournament.prizePool}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Spacer(),
              
              ElevatedButton(
                onPressed: tournament.canJoin ? () => _joinTournament(tournament) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FERColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  tournament.canJoin ? 'Join Tournament' : 'Registration Closed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build tournament detail
  Widget _buildTournamentDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16.0, color: FERColors.primary),
        SizedBox(height: 2.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: FERColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  /// Build my stats view
  Widget _buildMyStatsView() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Overall stats card
            _buildStatsCard(),
            
            SizedBox(height: 16.0),
            
            // Recent achievements
            _buildAchievementsSection(),
            
            SizedBox(height: 16.0),
            
            // Game history
            _buildGameHistorySection(),
          ],
        ),
      ),
    );
  }
  
  /// Build stats card
  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FERColors.primary,
            FERColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text(
            'My Gaming Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('⏱️', '$_totalPlayTime', 'Hours Played'),
              _buildStatItem('🎮', '$_gamesPlayed', 'Games Played'),
              _buildStatItem('🏆', '$_tournamentsWon', 'Tournaments Won'),
              _buildStatItem('📊', '${(_winRate * 100).toStringAsFixed(1)}%', 'Win Rate'),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build stat item
  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: 24.0),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }
  
  /// Build achievements section
  Widget _buildAchievementsSection() {
    final achievements = [
      {'icon': Icons.star, 'name': 'First Victory', 'description': 'Won your first game'},
      {'icon': Icons.emoji_events, 'name': 'Tournament Champion', 'description': 'Won a tournament'},
      {'icon': Icons.flash_on, 'name': 'Speed Demon', 'description': 'Won a game in under 5 minutes'},
      {'icon': Icons.group, 'name': 'Team Player', 'description': 'Played 10 multiplayer games'},
    ];
    
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.0),
          ...achievements.map((achievement) => Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Icon(
                  achievement['icon'] as IconData,
                  size: 24.0,
                  color: Colors.amber,
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['name'] as String,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        achievement['description'] as String,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  /// Build game history section
  Widget _buildGameHistorySection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Games',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.0),
          // Game history items would go here
          Text(
            'Game history will appear here',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build empty state
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80.0,
            color: Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _hostNewGame,
      icon: Icon(Icons.add),
      label: Text('Host Game'),
      backgroundColor: FERColors.primary,
      foregroundColor: Colors.white,
    );
  }
  
  /// Initialize gaming hub
  Future<void> _initializeGamingHub() async {
    setState(() => _isLoading = true);
    
    try {
      await _database.initialize();
      await _loadGames();
      await _loadActiveSessions();
      await _loadTournaments();
      await _loadUserStats();
    } catch (e) {
      debugPrint('Failed to initialize gaming hub: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// Load available games
  Future<void> _loadGames() async {
    // Simulate loading games
    final games = [
      FERGame(
        id: '1',
        name: 'Quantum Puzzle',
        description: 'Solve quantum-inspired puzzles',
        category: 'puzzle',
        thumbnailUrl: 'https://picsum.photos/200/150?random=1',
        minPlayers: 1,
        maxPlayers: 4,
        rating: 4.5,
        hasActiveSessions: true,
        canQuickPlay: true,
      ),
      FERGame(
        id: '2',
        name: 'FER Racing',
        description: 'High-speed racing on FERChain',
        category: 'racing',
        thumbnailUrl: 'https://picsum.photos/200/150?random=2',
        minPlayers: 2,
        maxPlayers: 8,
        rating: 4.2,
        hasActiveSessions: false,
        canQuickPlay: true,
      ),
      FERGame(
        id: '3',
        name: 'Battle Arena',
        description: 'Multiplayer battle arena game',
        category: 'action',
        thumbnailUrl: 'https://picsum.photos/200/150?random=3',
        minPlayers: 4,
        maxPlayers: 16,
        rating: 4.8,
        hasActiveSessions: true,
        canQuickPlay: false,
      ),
      FERGame(
        id: '4',
        name: 'Strategy Wars',
        description: 'Real-time strategy game',
        category: 'strategy',
        thumbnailUrl: 'https://picsum.photos/200/150?random=4',
        minPlayers: 2,
        maxPlayers: 6,
        rating: 4.3,
        hasActiveSessions: false,
        canQuickPlay: true,
      ),
      FERGame(
        id: '5',
        name: 'FER Sports',
        description: 'Multiplayer sports simulator',
        category: 'sports',
        thumbnailUrl: 'https://picsum.photos/200/150?random=5',
        minPlayers: 2,
        maxPlayers: 10,
        rating: 4.1,
        hasActiveSessions: true,
        canQuickPlay: false,
      ),
    ];
    
    setState(() {
      _availableGames = games;
      _featuredGames = games.take(3).toList();
    });
  }
  
  /// Load active sessions
  Future<void> _loadActiveSessions() async {
    final sessions = [
      GameSession(
        id: '1',
        gameId: '1',
        gameName: 'Quantum Puzzle',
        gameThumbnail: 'https://picsum.photos/60/60?random=1',
        sessionName: 'Quick Match - Room A',
        hostUserId: widget.userProfile?.id ?? '',
        hostName: widget.userProfile?.ferretId ?? 'AnonymousFerret',
        status: GameSessionStatus.waiting,
        maxPlayers: 4,
        currentPlayers: 2,
        isPrivate: false,
        startTime: DateTime.now(),
      ),
      GameSession(
        id: '2',
        gameId: '3',
        gameName: 'Battle Arena',
        gameThumbnail: 'https://picsum.photos/60/60?random=3',
        sessionName: 'Competitive Match',
        hostUserId: 'other_user',
        hostName: 'ProGamer42',
        status: GameSessionStatus.inProgress,
        maxPlayers: 16,
        currentPlayers: 12,
        isPrivate: false,
        startTime: DateTime.now().subtract(Duration(minutes: 15)),
      ),
    ];
    
    setState(() {
      _activeSessions = sessions;
    });
  }
  
  /// Load tournaments
  Future<void> _loadTournaments() async {
    final tournaments = [
      GameTournament(
        id: '1',
        name: 'FER Championship 2024',
        description: 'Annual FER gaming tournament',
        startTime: DateTime.now().add(Duration(days: 7)),
        maxParticipants: 256,
        currentParticipants: 128,
        entryFee: 10,
        prizePool: 2500,
        canJoin: true,
      ),
      GameTournament(
        id: '2',
        name: 'Speed Run Challenge',
        description: 'Fastest completion wins',
        startTime: DateTime.now().add(Duration(days: 2)),
        maxParticipants: 64,
        currentParticipants: 32,
        entryFee: 5,
        prizePool: 320,
        canJoin: true,
      ),
    ];
    
    setState(() {
      _tournaments = tournaments;
    });
  }
  
  /// Load user stats
  Future<void> _loadUserStats() async {
    setState(() {
      _totalPlayTime = 127; // hours
      _gamesPlayed = 45;
      _tournamentsWon = 3;
      _winRate = 0.67; // 67%
    });
  }
  
  /// Setup realtime updates
  void _setupRealtimeUpdates() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _updateGameSessions();
      }
    });
  }
  
  /// Update game sessions
  void _updateGameSessions() {
    setState(() {
      // Simulate session updates
      for (final session in _activeSessions) {
        if (session.status == GameSessionStatus.waiting && Random().nextBool()) {
          session.currentPlayers = (session.currentPlayers + 1).clamp(1, session.maxPlayers);
        }
      }
    });
  }
  
  /// Get filtered games
  List<FERGame> _getFilteredGames() {
    var filtered = _availableGames;
    
    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((game) => game.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((game) =>
        game.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        game.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  /// Handle search change
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  
  /// Filter by category
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }
  
  /// Show game details
  void _showGameDetails(FERGame game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(game.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              game.thumbnailUrl,
              height: 150.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(game.description),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('⭐ ${game.rating}'),
                Text('👥 ${game.minPlayers}-${game.maxPlayers}'),
                Text('🏷️ ${game.category}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchGame(game);
            },
            child: Text('Play Now'),
            style: ElevatedButton.styleFrom(backgroundColor: FERColors.primary),
          ),
        ],
      ),
    );
  }
  
  /// Show game options
  void _showGameOptions(FERGame game) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('Quick Play'),
              onTap: () {
                Navigator.of(context).pop();
                _quickPlayGame(game);
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Host Session'),
              onTap: () {
                Navigator.of(context).pop();
                _hostGameSession(game);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Add to Favorites'),
              onTap: () {
                Navigator.of(context).pop();
                debugPrint('Adding ${game.name} to favorites');
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share Game'),
              onTap: () {
                Navigator.of(context).pop();
                debugPrint('Sharing ${game.name}');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Launch game
  void _launchGame(FERGame game) {
    debugPrint('Launching game: ${game.name}');
    // Implement game launch logic with FER quantum protocol
  }
  
  /// Quick play game
  void _quickPlayGame(FERGame game) {
    debugPrint('Quick playing: ${game.name}');
    // Implement quick play logic
  }
  
  /// Host new game
  void _hostNewGame() {
    showDialog(
      context: context,
      builder: (context) => _buildHostGameDialog(),
    );
  }
  
  /// Build host game dialog
  Widget _buildHostGameDialog() {
    String selectedGameId = _availableGames.first.id;
    String sessionName = 'FER Game Session';
    int maxPlayers = 4;
    bool isPrivate = false;
    
    return AlertDialog(
      title: Text('Host New Game'),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game selection
            DropdownButtonFormField<String>(
              value: selectedGameId,
              decoration: InputDecoration(labelText: 'Select Game'),
              items: _availableGames.map((game) {
                return DropdownMenuItem(
                  value: game.id,
                  child: Text(game.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedGameId = value!),
            ),
            
            SizedBox(height: 12.0),
            
            // Session name
            TextField(
              decoration: InputDecoration(labelText: 'Session Name'),
              onChanged: (value) => sessionName = value,
            ),
            
            SizedBox(height: 12.0),
            
            // Max players
            Row(
              children: [
                Text('Max Players: '),
                SizedBox(width: 12.0),
                Expanded(
                  child: Slider(
                    value: maxPlayers.toDouble(),
                    min: 2.0,
                    max: 16.0,
                    divisions: 14,
                    onChanged: (value) => setState(() => maxPlayers = value.round()),
                  ),
                ),
                Text(maxPlayers.toString()),
              ],
            ),
            
            SizedBox(height: 12.0),
            
            // Private session
            Row(
              children: [
                Checkbox(
                  value: isPrivate,
                  onChanged: (value) => setState(() => isPrivate = value!),
                ),
                Text('Private Session'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _createGameSession(selectedGameId, sessionName, maxPlayers, isPrivate);
          },
          child: Text('Host'),
          style: ElevatedButton.styleFrom(backgroundColor: FERColors.primary),
        ),
      ],
    );
  }
  
  /// Create game session
  void _createGameSession(String gameId, String sessionName, int maxPlayers, bool isPrivate) {
    final game = _availableGames.firstWhere((g) => g.id == gameId);
    
    final newSession = GameSession(
      id: _generateSessionId(),
      gameId: gameId,
      gameName: game.name,
      gameThumbnail: game.thumbnailUrl,
      sessionName: sessionName,
      hostUserId: widget.userProfile?.id ?? '',
      hostName: widget.userProfile?.ferretId ?? 'AnonymousFerret',
      status: GameSessionStatus.waiting,
      maxPlayers: maxPlayers,
      currentPlayers: 1,
      isPrivate: isPrivate,
      startTime: DateTime.now(),
    );
    
    setState(() {
      _activeSessions.insert(0, newSession);
    });
    
    debugPrint('Created game session: $sessionName');
  }
  
  /// Host game session
  void _hostGameSession(FERGame game) {
    _createGameSession(game.id, '${game.name} Session', game.maxPlayers, false);
  }
  
  /// Join game session
  void _joinGameSession(GameSession session) {
    setState(() {
      session.currentPlayers = (session.currentPlayers + 1).clamp(1, session.maxPlayers);
    });
    
    debugPrint('Joined game session: ${session.sessionName}');
    
    if (session.currentPlayers == session.maxPlayers) {
      setState(() {
        session.status = GameSessionStatus.inProgress;
      });
    }
  }
  
  /// Manage game session
  void _manageGameSession(GameSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Session'),
              onTap: () {
                Navigator.of(context).pop();
                debugPrint('Editing session');
              },
            ),
            ListTile(
              leading: Icon(Icons.kick_out),
              title: Text('Kick Player'),
              onTap: () {
                Navigator.of(context).pop();
                debugPrint('Kick player');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('End Session', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _endGameSession(session);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// End game session
  void _endGameSession(GameSession session) {
    setState(() {
      _activeSessions.remove(session);
    });
    
    debugPrint('Ended game session: ${session.sessionName}');
  }
  
  /// Join tournament
  void _joinTournament(GameTournament tournament) {
    setState(() {
      tournament.currentParticipants = (tournament.currentParticipants + 1)
          .clamp(1, tournament.maxParticipants);
      
      if (tournament.currentParticipants >= tournament.maxParticipants) {
        tournament.canJoin = false;
      }
    });
    
    debugPrint('Joined tournament: ${tournament.name}');
  }
  
  /// Get status color
  Color _getStatusColor(GameSessionStatus status) {
    switch (status) {
      case GameSessionStatus.waiting:
        return Colors.orange;
      case GameSessionStatus.inProgress:
        return Colors.green;
      case GameSessionStatus.completed:
        return Colors.blue;
      case GameSessionStatus.cancelled:
        return Colors.red;
    }
  }
  
  /// Format duration
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Started';
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  /// Generate session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}

/// FER Game model
class FERGame {
  final String id;
  final String name;
  final String description;
  final String category;
  final String thumbnailUrl;
  final int minPlayers;
  final int maxPlayers;
  final double rating;
  final bool hasActiveSessions;
  final bool canQuickPlay;
  
  FERGame({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.minPlayers,
    required this.maxPlayers,
    required this.rating,
    this.hasActiveSessions = false,
    this.canQuickPlay = false,
  });
}

/// Game session model
class GameSession {
  final String id;
  final String gameId;
  final String gameName;
  final String gameThumbnail;
  final String sessionName;
  final String hostUserId;
  final String hostName;
  final GameSessionStatus status;
  final int maxPlayers;
  int currentPlayers;
  final bool isPrivate;
  final DateTime startTime;
  
  GameSession({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.gameThumbnail,
    required this.sessionName,
    required this.hostUserId,
    required this.hostName,
    required this.status,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.isPrivate,
    required this.startTime,
  });
}

/// Game tournament model
class GameTournament {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final int maxParticipants;
  int currentParticipants;
  final int entryFee;
  final int prizePool;
  bool canJoin;
  
  GameTournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.entryFee,
    required this.prizePool,
    this.canJoin = true,
  });
}

/// Game session status
enum GameSessionStatus {
  waiting,
  inProgress,
  completed,
  cancelled,
}
]]>