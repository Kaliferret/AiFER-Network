<![CDATA[import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/offline_first_database.dart';
import '../../widgets/unified_sliding_menu.dart';
import '../../core/aif_package_format.dart';

/// FERExplorer Screen - Secure file management system
/// Blockchain-verified file storage and sharing
class FERExplorerScreen extends StatefulWidget {
  final AiFERiDUserProfile? userProfile;
  final Function(FERAppType) onAppSelected;
  
  const FERExplorerScreen({
    Key? key,
    this.userProfile,
    required this.onAppSelected,
  }) : super(key: key);
  
  @override
  _FERExplorerScreenState createState() => _FERExplorerScreenState();
}

class _FERExplorerScreenState extends State<FERExplorerScreen> 
    with TickerProviderStateMixin {
  
  final OfflineFirstDatabase _database = OfflineFirstDatabase.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<FERFile> _files = [];
  List<FERFolder> _folders = [];
  List<FERFileTransfer> _activeTransfers = [];
  FERFolder? _currentFolder;
  String _viewMode = 'grid'; // grid, list
  String _sortBy = 'name'; // name, date, size, type
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  
  late TabController _tabController;
  
  // Storage statistics
  double _totalStorage = 100.0; // GB
  double _usedStorage = 0.0;
  double _freeStorage = 100.0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFileManager();
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
          // Header with search and actions
          _buildExplorerHeader(),
          
          // Tab bar for different views
          _buildTabBar(),
          
          // Main content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyFilesView(),
                _buildSharedFilesView(),
                _buildRecentFilesView(),
                _buildTransfersView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }
  
  /// Build explorer header
  Widget _buildExplorerHeader() {
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
          // First row: breadcrumbs and actions
          Row(
            children: [
              // Breadcrumb navigation
              Expanded(
                child: _buildBreadcrumbNavigation(),
              ),
              
              // View mode toggle
              Row(
                children: [
                  IconButton(
                    onPressed: () => _toggleViewMode('grid'),
                    icon: Icon(Icons.grid_view),
                    color: _viewMode == 'grid' ? FERColors.primary : Colors.grey,
                    tooltip: 'Grid View',
                  ),
                  IconButton(
                    onPressed: () => _toggleViewMode('list'),
                    icon: Icon(Icons.list),
                    color: _viewMode == 'list' ? FERColors.primary : Colors.grey,
                    tooltip: 'List View',
                  ),
                ],
              ),
              
              // Sort options
              PopupMenuButton<String>(
                icon: Icon(Icons.sort),
                onSelected: _sortFiles,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'name', child: Text('Name')),
                  PopupMenuItem(value: 'date', child: Text('Date Modified')),
                  PopupMenuItem(value: 'size', child: Text('Size')),
                  PopupMenuItem(value: 'type', child: Text('Type')),
                ],
                tooltip: 'Sort Files',
              ),
            ],
          ),
          
          SizedBox(height: 12.0),
          
          // Second row: storage overview
          _buildStorageOverview(),
        ],
      ),
    );
  }
  
  /// Build breadcrumb navigation
  Widget _buildBreadcrumbNavigation() {
    return Row(
      children: [
        InkWell(
          onTap: () => _navigateToFolder(null),
          child: Text(
            'My Files',
            style: TextStyle(
              color: FERColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_currentFolder != null) ...[
          Icon(Icons.chevron_right, size: 16.0, color: Colors.grey),
          Text(_currentFolder!.name),
        ],
      ],
    );
  }
  
  /// Build storage overview
  Widget _buildStorageOverview() {
    final usedPercentage = _usedStorage / _totalStorage;
    
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FER Storage',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_usedStorage.toStringAsFixed(1)} GB / ${_totalStorage.toStringAsFixed(1)} GB',
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: usedPercentage,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              usedPercentage > 0.8 ? Colors.red : FERColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build tab bar
  Widget _buildTabBar() {
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
          Tab(text: 'My Files'),
          Tab(text: 'Shared'),
          Tab(text: 'Recent'),
          Tab(text: 'Transfers'),
        ],
      ),
    );
  }
  
  /// Build My Files view
  Widget _buildMyFilesView() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Files and folders
          Expanded(
            child: _viewMode == 'grid'
              ? _buildFilesGrid()
              : _buildFilesList(),
          ),
        ],
      ),
    );
  }
  
  /// Build files grid view
  Widget _buildFilesGrid() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _folders.length + _files.length,
      itemBuilder: (context, index) {
        if (index < _folders.length) {
          return _buildFolderGridItem(_folders[index]);
        } else {
          final fileIndex = index - _folders.length;
          return _buildFileGridItem(_files[fileIndex]);
        }
      },
    );
  }
  
  /// Build files list view
  Widget _buildFilesList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _folders.length + _files.length,
      itemBuilder: (context, index) {
        if (index < _folders.length) {
          return _buildFolderListItem(_folders[index]);
        } else {
          final fileIndex = index - _folders.length;
          return _buildFileListItem(_files[fileIndex]);
        }
      },
    );
  }
  
  /// Build folder grid item
  Widget _buildFolderGridItem(FERFolder folder) {
    return GestureDetector(
      onTap: () => _navigateToFolder(folder),
      onLongPress: () => _showFolderContextMenu(folder),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).dividerColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              size: 48.0,
              color: FERColors.primary,
            ),
            SizedBox(height: 8.0),
            Text(
              folder.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.0),
            Text(
              '${folder.itemCount} items',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build folder list item
  Widget _buildFolderListItem(FERFolder folder) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToFolder(folder),
          onLongPress: () => _showFolderContextMenu(folder),
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.folder,
                  size: 32.0,
                  color: FERColors.primary,
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${folder.itemCount} items • ${_formatFileSize(folder.totalSize)}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build file grid item
  Widget _buildFileGridItem(FERFile file) {
    return GestureDetector(
      onTap: () => _openFile(file),
      onLongPress: () => _showFileContextMenu(file),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: file.isShared ? FERColors.primary : Theme.of(context).dividerColor,
            width: file.isShared ? 2.0 : 1.0,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // File thumbnail or icon
            _buildFileThumbnail(file),
            
            SizedBox(height: 8.0),
            
            // File name
            Text(
              file.fileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 4.0),
            
            // File size and sharing indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (file.isShared)
                  Icon(
                    Icons.share,
                    size: 12.0,
                    color: FERColors.primary,
                  ),
                Text(
                  _formatFileSize(file.fileSize),
                  style: TextStyle(
                    fontSize: 9.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build file list item
  Widget _buildFileListItem(FERFile file) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openFile(file),
          onLongPress: () => _showFileContextMenu(file),
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                // File icon
                _buildFileIcon(file),
                
                SizedBox(width: 12.0),
                
                // File details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.fileName,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.0),
                      Row(
                        children: [
                          Text(
                            _formatFileSize(file.fileSize),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                          if (file.isShared) ...[
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.share,
                              size: 12.0,
                              color: FERColors.primary,
                            ),
                            Text(
                              'Shared',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: FERColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (file.isDownloading)
                      SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 16.0),
                      onSelected: (value) => _handleFileAction(value, file),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'open', child: Text('Open')),
                        PopupMenuItem(value: 'share', child: Text('Share')),
                        PopupMenuItem(value: 'download', child: Text('Download')),
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build file thumbnail
  Widget _buildFileThumbnail(FERFile file) {
    switch (file.fileType) {
      case FERFileType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            file.thumbnailUrl ?? 'https://via.placeholder.com/60x60',
            width: 48.0,
            height: 48.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48.0,
                height: 48.0,
                child: Icon(Icons.image, size: 24.0, color: Colors.grey),
              );
            },
          ),
        );
      
      case FERFileType.video:
        return Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  file.thumbnailUrl ?? 'https://via.placeholder.com/60x60',
                  width: 48.0,
                  height: 48.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 48.0,
                      height: 48.0,
                      color: Colors.grey.withOpacity(0.1),
                    );
                  },
                ),
              ),
              Icon(
                Icons.play_circle_outline,
                size: 24.0,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ],
          ),
        );
      
      case FERFileType.document:
        return Icon(Icons.description, size: 48.0, color: Colors.blue);
      
      case FERFileType.archive:
        return Icon(Icons.archive, size: 48.0, color: Colors.orange);
      
      case FERFileType.audio:
        return Icon(Icons.audio_file, size: 48.0, color: Colors.purple);
      
      default:
        return Icon(Icons.insert_drive_file, size: 48.0, color: Colors.grey);
    }
  }
  
  /// Build file icon
  Widget _buildFileIcon(FERFile file) {
    switch (file.fileType) {
      case FERFileType.image:
        return Icon(Icons.image, size: 32.0, color: Colors.blue);
      case FERFileType.video:
        return Icon(Icons.videocam, size: 32.0, color: Colors.red);
      case FERFileType.document:
        return Icon(Icons.description, size: 32.0, color: Colors.blue);
      case FERFileType.archive:
        return Icon(Icons.archive, size: 32.0, color: Colors.orange);
      case FERFileType.audio:
        return Icon(Icons.audio_file, size: 32.0, color: Colors.purple);
      default:
        return Icon(Icons.insert_drive_file, size: 32.0, color: Colors.grey);
    }
  }
  
  /// Build Shared Files view
  Widget _buildSharedFilesView() {
    final sharedFiles = _files.where((file) => file.isShared).toList();
    
    if (sharedFiles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.share,
        title: 'No Shared Files',
        subtitle: 'Share files with other FER users',
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16.0),
      child: _viewMode == 'grid'
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: sharedFiles.length,
            itemBuilder: (context, index) => _buildFileGridItem(sharedFiles[index]),
          )
        : ListView.builder(
            itemCount: sharedFiles.length,
            itemBuilder: (context, index) => _buildFileListItem(sharedFiles[index]),
          ),
    );
  }
  
  /// Build Recent Files view
  Widget _buildRecentFilesView() {
    final recentFiles = _files.take(20).toList();
    
    if (recentFiles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Recent Files',
        subtitle: 'Your recently accessed files will appear here',
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: recentFiles.length,
        itemBuilder: (context, index) => _buildFileListItem(recentFiles[index]),
      ),
    );
  }
  
  /// Build Transfers view
  Widget _buildTransfersView() {
    if (_activeTransfers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.cloud_upload,
        title: 'No Active Transfers',
        subtitle: 'Upload and download transfers will appear here',
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _activeTransfers.length,
        itemBuilder: (context, index) => _buildTransferItem(_activeTransfers[index]),
      ),
    );
  }
  
  /// Build transfer item
  Widget _buildTransferItem(FERFileTransfer transfer) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                transfer.type == TransferType.upload ? Icons.cloud_upload : Icons.cloud_download,
                size: 20.0,
                color: FERColors.primary,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  transfer.fileName,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (transfer.status == TransferStatus.inProgress)
                Text(
                  '${(transfer.progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: FERColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (transfer.status == TransferStatus.completed)
                Icon(Icons.check_circle, color: Colors.green, size: 16.0)
              else if (transfer.status == TransferStatus.failed)
                Icon(Icons.error, color: Colors.red, size: 16.0),
            ],
          ),
          SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: transfer.progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              transfer.status == TransferStatus.failed ? Colors.red : FERColors.primary,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            _formatFileSize(transfer.transferredBytes) + ' / ' + _formatFileSize(transfer.totalBytes),
            style: TextStyle(fontSize: 11.0, color: Colors.grey),
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
  
  /// Build floating action buttons
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Upload progress indicator
        if (_isUploading)
          Container(
            margin: EdgeInsets.only(bottom: 8.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: FERColors.primary,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    value: _uploadProgress,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        // New folder button
        FloatingActionButton(
          heroTag: 'new_folder',
          onPressed: _createNewFolder,
          mini: true,
          child: Icon(Icons.create_new_folder),
          backgroundColor: FERColors.secondary,
          tooltip: 'New Folder',
        ),
        
        SizedBox(height: 8.0),
        
        // Upload button
        FloatingActionButton.extended(
          heroTag: 'upload',
          onPressed: _uploadFile,
          icon: Icon(Icons.cloud_upload),
          label: Text('Upload'),
          backgroundColor: FERColors.primary,
          foregroundColor: Colors.white,
        ),
      ],
    );
  }
  
  /// Initialize file manager
  Future<void> _initializeFileManager() async {
    setState(() => _isLoading = true);
    
    try {
      await _database.initialize();
      await _loadFilesAndFolders();
      await _loadActiveTransfers();
      await _updateStorageStats();
    } catch (e) {
      debugPrint('Failed to initialize file manager: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// Load files and folders
  Future<void> _loadFilesAndFolders() async {
    try {
      // In real implementation, load from database
      final files = [
        FERFile(
          id: '1',
          ownerId: widget.userProfile?.id ?? '',
          fileName: 'FER_Documentation.pdf',
          fileSize: 2048576, // 2MB
          fileType: FERFileType.document,
          fileHash: 'hash123',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          isShared: true,
          isDownloading: false,
        ),
        FERFile(
          id: '2',
          ownerId: widget.userProfile?.id ?? '',
          fileName: 'vacation_photo.jpg',
          fileSize: 5242880, // 5MB
          fileType: FERFileType.image,
          fileHash: 'hash456',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          isShared: false,
          isDownloading: false,
          thumbnailUrl: 'https://picsum.photos/60/60',
        ),
        FERFile(
          id: '3',
          ownerId: widget.userProfile?.id ?? '',
          fileName: 'game_recording.mp4',
          fileSize: 10485760, // 10MB
          fileType: FERFileType.video,
          fileHash: 'hash789',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          isShared: true,
          isDownloading: false,
          thumbnailUrl: 'https://picsum.photos/60/60',
        ),
      ];
      
      final folders = [
        FERFolder(
          id: '1',
          name: 'Documents',
          itemCount: 12,
          totalSize: 15728640, // 15MB
        ),
        FERFolder(
          id: '2',
          name: 'Images',
          itemCount: 45,
          totalSize: 52428800, // 50MB
        ),
        FERFolder(
          id: '3',
          name: 'Videos',
          itemCount: 8,
          totalSize: 209715200, // 200MB
        ),
      ];
      
      setState(() {
        _files = files;
        _folders = folders;
      });
    } catch (e) {
      debugPrint('Failed to load files and folders: $e');
    }
  }
  
  /// Load active transfers
  Future<void> _loadActiveTransfers() async {
    // Simulate active transfers
    final transfers = [
      FERFileTransfer(
        id: '1',
        fileName: 'large_file.zip',
        type: TransferType.upload,
        status: TransferStatus.inProgress,
        progress: 0.65,
        totalBytes: 52428800, // 50MB
        transferredBytes: 34078720, // ~32.5MB
      ),
      FERFileTransfer(
        id: '2',
        fileName: 'shared_document.pdf',
        type: TransferType.download,
        status: TransferStatus.completed,
        progress: 1.0,
        totalBytes: 2097152, // 2MB
        transferredBytes: 2097152,
      ),
    ];
    
    setState(() {
      _activeTransfers = transfers;
    });
  }
  
  /// Update storage statistics
  Future<void> _updateStorageStats() async {
    final totalSize = _files.fold<int>(0, (sum, file) => sum + file.fileSize);
    
    setState(() {
      _usedStorage = totalSize / (1024 * 1024 * 1024); // Convert to GB
      _freeStorage = _totalStorage - _usedStorage;
    });
  }
  
  /// Setup realtime updates
  void _setupRealtimeUpdates() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _updateTransferProgress();
        _updateStorageStats();
      }
    });
  }
  
  /// Update transfer progress
  void _updateTransferProgress() {
    setState(() {
      for (final transfer in _activeTransfers) {
        if (transfer.status == TransferStatus.inProgress) {
          transfer.progress = (transfer.progress + 0.1).clamp(0.0, 1.0);
          transfer.transferredBytes = (transfer.totalBytes * transfer.progress).round();
          
          if (transfer.progress >= 1.0) {
            transfer.status = TransferStatus.completed;
          }
        }
      }
    });
  }
  
  /// Toggle view mode
  void _toggleViewMode(String mode) {
    setState(() {
      _viewMode = mode;
    });
  }
  
  /// Sort files
  void _sortFiles(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      
      switch (sortBy) {
        case 'name':
          _files.sort((a, b) => a.fileName.compareTo(b.fileName));
          break;
        case 'date':
          _files.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'size':
          _files.sort((a, b) => b.fileSize.compareTo(a.fileSize));
          break;
        case 'type':
          _files.sort((a, b) => a.fileType.toString().compareTo(b.fileType.toString()));
          break;
      }
    });
  }
  
  /// Navigate to folder
  void _navigateToFolder(FERFolder? folder) {
    setState(() {
      _currentFolder = folder;
    });
    
    // Load folder contents
    if (folder != null) {
      debugPrint('Navigating to folder: ${folder.name}');
    } else {
      debugPrint('Navigating to root folder');
    }
  }
  
  /// Open file
  void _openFile(FERFile file) {
    debugPrint('Opening file: ${file.fileName}');
    // Implement file opening logic
  }
  
  /// Upload file
  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await _processFileUpload(file);
      }
    } catch (e) {
      debugPrint('Failed to pick file: $e');
    }
  }
  
  /// Process file upload
  Future<void> _processFileUpload(platform.FilePickerResult file) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    // Simulate upload progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        _uploadProgress = i / 100.0;
      });
    }
    
    // Add file to list
    final newFile = FERFile(
      id: _generateFileId(),
      ownerId: widget.userProfile?.id ?? '',
      fileName: file.name ?? 'unknown_file',
      fileSize: file.size ?? 0,
      fileType: _getFileTypeFromFile(file),
      fileHash: _generateFileHash(file),
      createdAt: DateTime.now(),
      isShared: false,
      isDownloading: false,
    );
    
    await _database.storeFile(newFile);
    
    setState(() {
      _files.insert(0, newFile);
      _isUploading = false;
      _uploadProgress = 0.0;
    });
    
    await _updateStorageStats();
    
    // Add to transfers
    final transfer = FERFileTransfer(
      id: _generateTransferId(),
      fileName: newFile.fileName,
      type: TransferType.upload,
      status: TransferStatus.completed,
      progress: 1.0,
      totalBytes: newFile.fileSize,
      transferredBytes: newFile.fileSize,
    );
    
    setState(() {
      _activeTransfers.insert(0, transfer);
    });
  }
  
  /// Create new folder
  void _createNewFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Folder'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (name) {
            Navigator.of(context).pop();
            _createFolder(name);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Get folder name from text field and create
              Navigator.of(context).pop();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
  
  /// Create folder
  void _createFolder(String name) {
    final newFolder = FERFolder(
      id: _generateFolderId(),
      name: name,
      itemCount: 0,
      totalSize: 0,
    );
    
    setState(() {
      _folders.insert(0, newFolder);
    });
    
    debugPrint('Created folder: $name');
  }
  
  /// Show folder context menu
  void _showFolderContextMenu(FERFolder folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Rename'),
              onTap: () {
                Navigator.of(context).pop();
                _renameFolder(folder);
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share Folder'),
              onTap: () {
                Navigator.of(context).pop();
                _shareFolder(folder);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Folder', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteFolder(folder);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show file context menu
  void _showFileContextMenu(FERFile file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text('Open'),
              onTap: () {
                Navigator.of(context).pop();
                _openFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
                _shareFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Download'),
              onTap: () {
                Navigator.of(context).pop();
                _downloadFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Rename'),
              onTap: () {
                Navigator.of(context).pop();
                _renameFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handle file action
  void _handleFileAction(String action, FERFile file) {
    switch (action) {
      case 'open':
        _openFile(file);
        break;
      case 'share':
        _shareFile(file);
        break;
      case 'download':
        _downloadFile(file);
        break;
      case 'rename':
        _renameFile(file);
        break;
      case 'delete':
        _deleteFile(file);
        break;
    }
  }
  
  /// Share file
  void _shareFile(FERFile file) {
    setState(() {
      file.isShared = true;
    });
    
    debugPrint('Sharing file: ${file.fileName}');
    // Implement file sharing logic with AIF packaging
  }
  
  /// Download file
  void _downloadFile(FERFile file) {
    final transfer = FERFileTransfer(
      id: _generateTransferId(),
      fileName: file.fileName,
      type: TransferType.download,
      status: TransferStatus.inProgress,
      progress: 0.0,
      totalBytes: file.fileSize,
      transferredBytes: 0,
    );
    
    setState(() {
      _activeTransfers.insert(0, transfer);
      file.isDownloading = true;
    });
    
    // Simulate download
    _simulateTransfer(transfer, file);
  }
  
  /// Rename file
  void _renameFile(FERFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename File'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'New name',
            border: OutlineInputBorder(),
          ),
          initialValue: file.fileName,
          onSubmitted: (newName) {
            Navigator.of(context).pop();
            setState(() {
              file.fileName = newName;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }
  
  /// Delete file
  void _deleteFile(FERFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete ${file.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _files.remove(file);
              });
              _updateStorageStats();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// Rename folder
  void _renameFolder(FERFolder folder) {
    // Implement folder renaming
    debugPrint('Renaming folder: ${folder.name}');
  }
  
  /// Share folder
  void _shareFolder(FERFolder folder) {
    // Implement folder sharing
    debugPrint('Sharing folder: ${folder.name}');
  }
  
  /// Delete folder
  void _deleteFolder(FERFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Folder'),
        content: Text('Are you sure you want to delete ${folder.name} and all its contents?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _folders.remove(folder);
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// Simulate file transfer
  void _simulateTransfer(FERFileTransfer transfer, FERFile file) {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        transfer.progress = (transfer.progress + 0.05).clamp(0.0, 1.0);
        transfer.transferredBytes = (transfer.totalBytes * transfer.progress).round();
        
        if (transfer.progress >= 1.0) {
          transfer.status = TransferStatus.completed;
          file.isDownloading = false;
          timer.cancel();
        }
      });
    });
  }
  
  /// Get file type from picked file
  FERFileType _getFileTypeFromFile(platform.FilePickerResult file) {
    final extension = file.name?.split('.').last.toLowerCase() ?? '';
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return FERFileType.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return FERFileType.video;
      case 'mp3':
      case 'wav':
      case 'flac':
        return FERFileType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
        return FERFileType.document;
      case 'zip':
      case 'rar':
      case '7z':
        return FERFileType.archive;
      default:
        return FERFileType.other;
    }
  }
  
  /// Generate file hash (simulated)
  String _generateFileHash(platform.FilePickerResult file) {
    return 'hash_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
  
  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Generate file ID
  String _generateFileId() {
    return 'file_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
  
  /// Generate folder ID
  String _generateFolderId() {
    return 'folder_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
  
  /// Generate transfer ID
  String _generateTransferId() {
    return 'transfer_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}

/// FER Folder model
class FERFolder {
  final String id;
  final String name;
  int itemCount;
  int totalSize;
  
  FERFolder({
    required this.id,
    required this.name,
    this.itemCount = 0,
    this.totalSize = 0,
  });
}

/// File transfer model
class FERFileTransfer {
  final String id;
  final String fileName;
  final TransferType type;
  TransferStatus status;
  double progress;
  final int totalBytes;
  int transferredBytes;
  
  FERFileTransfer({
    required this.id,
    required this.fileName,
    required this.type,
    required this.status,
    required this.progress,
    required this.totalBytes,
    required this.transferredBytes,
  });
}

/// Transfer types
enum TransferType {
  upload,
  download,
}

/// Transfer status
enum TransferStatus {
  pending,
  inProgress,
  completed,
  failed,
  paused,
}

/// Import file types
import '../../services/offline_first_database.dart';
import 'dart:io' as platform;
]]>