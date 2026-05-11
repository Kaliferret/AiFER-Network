import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class DecentralizedStorageScreen extends StatefulWidget {
  const DecentralizedStorageScreen({super.key});

  @override
  State<DecentralizedStorageScreen> createState() => _DecentralizedStorageScreenState();
}

class _DecentralizedStorageScreenState extends State<DecentralizedStorageScreen>
    with SingleTickerProviderStateMixin {
  double _storageUsed = 45.2;
  double _storageTotal = 100.0;
  List<StorageFile> _files = [
    StorageFile(
      name: 'ferret_identity.json',
      size: 24.5,
      type: 'Document',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
      cid: 'QmXxx...7aB',
      pinned: true,
    ),
    StorageFile(
      name: 'backup_wallet.dat',
      size: 1024.0,
      type: 'Encrypted',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      cid: 'QmXyy...9cD',
      pinned: true,
    ),
    StorageFile(
      name: 'mesh_network_logs.csv',
      size: 156.8,
      type: 'Data',
      uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
      cid: 'QmXzz...1eF',
      pinned: false,
    ),
    StorageFile(
      name: 'ferret_avatar.png',
      size: 2048.0,
      type: 'Image',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      cid: 'QmXaa...2gH',
      pinned: true,
    ),
  ];

  int _get replicationFactor => 3;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF39FF14)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Decentralized Storage',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF39FF14),
              ),
            ),
            Text(
              'IPFS + Walrus Protocol',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: Color(0xFF39FF14)),
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStorageOverview(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilesTab(),
                _buildNetworkTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageOverview() {
    final usedGB = (_storageUsed / 1024).toStringAsFixed(2);
    final totalGB = (_storageTotal / 1024).toStringAsFixed(2);
    final percentage = (_storageUsed / _storageTotal * 100).toInt();

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF39FF14).withOpacity(0.15),
            const Color(0xFF1E1E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF39FF14).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.cloud_queue, color: const Color(0xFF39FF14), size: 5.w),
                  ),
                  SizedBox(width: 2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage Usage',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$percentage% of $totalGB GB',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.speed, color: const Color(0xFF00E5FF), size: 4.w),
                  SizedBox(width: 0.5.w),
                  Text(
                    'High Speed',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _storageUsed / _storageTotal,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
              minHeight: 1.h,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStorageMetric('Used', '$usedGB GB', Icons.storage),
              _buildStorageMetric('Free', '${(totalGB - usedGB).toStringAsFixed(2)} GB', Icons.folder_open),
              _buildStorageMetric('Replicas', '$_replicationFactor', Icons.content_copy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 4.w, color: const Color(0xFF39FF14)),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF39FF14),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF9E9E9E),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Files'),
          Tab(text: 'Network'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        return _buildFileCard(_files[index]);
      },
    );
  }

  Widget _buildFileCard(StorageFile file) {
    Color typeColor;
    IconData typeIcon;
    
    switch (file.type) {
      case 'Document':
        typeColor = const Color(0xFF00E5FF);
        typeIcon = Icons.description;
        break;
      case 'Encrypted':
        typeColor = const Color(0xFFFFD740);
        typeIcon = Icons.lock;
        break;
      case 'Data':
        typeColor = const Color(0xFF7B61FF);
        typeIcon = Icons.table_chart;
        break;
      case 'Image':
        typeColor = const Color(0xFF69F0AE);
        typeIcon = Icons.image;
        break;
      default:
        typeColor = const Color(0xFF9E9E9E);
        typeIcon = Icons.insert_drive_file;
    }

    final sizeText = file.size < 1024
        ? '${file.size.toStringAsFixed(1)} KB'
        : '${(file.size / 1024).toStringAsFixed(2)} MB';

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: typeColor.withOpacity(0.5)),
            ),
            child: Icon(typeIcon, color: typeColor, size: 6.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (file.pinned) ...[
                      Icon(Icons.push_pin, size: 12.sp, color: const Color(0xFFFFD740)),
                      SizedBox(width: 1.w),
                    ],
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        file.type,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: typeColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      sizeText,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(Icons.link, size: 10.sp, color: const Color(0xFF39FF14)),
                    SizedBox(width: 0.5.w),
                    Expanded(
                      child: Text(
                        file.cid,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: const Color(0xFF39FF14),
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: const Color(0xFF9E9E9E), size: 4.w),
            color: const Color(0xFF1E1E1E),
            onSelected: (value) {
              if (value == 'download') {
                _downloadFile(file);
              } else if (value == 'pin') {
                _togglePin(file);
              } else if (value == 'delete') {
                _deleteFile(file);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 14.sp, color: const Color(0xFF39FF14)),
                    SizedBox(width: 2.w),
                    Text('Download', style: GoogleFonts.inter(fontSize: 12.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                      file.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 14.sp,
                      color: const Color(0xFFFFD740),
                    ),
                    SizedBox(width: 2.w),
                    Text(file.pinned ? 'Unpin' : 'Pin', style: GoogleFonts.inter(fontSize: 12.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 14.sp, color: const Color(0xFFFF5252)),
                    SizedBox(width: 2.w),
                    Text('Delete', style: GoogleFonts.inter(fontSize: 12.sp)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              'Storage Network',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildNetworkCard('IPFS Nodes', 'Active', Icons.hub, const Color(0xFF39FF14),
              '247 nodes available'),
          _buildNetworkCard('Walrus Protocol', 'Synced', Icons.cloud_sync, const Color(0xFF00E5FF),
              '3-way redundancy active'),
          _buildNetworkCard('Bandwidth', 'High', Icons.speed, const Color(0xFF7B61FF),
              '150 Mbps upload'),
          _buildNetworkCard('Latency', 'Low', Icons.timer, const Color(0xFFFFD740),
              '45ms average'),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'Protocol Details',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProtocolDetail('IPFS Version', 'v0.25.0', Icons.info),
                _buildProtocolDetail('Walrus Version', 'v2.1.0', Icons.info),
                _buildProtocolDetail('Encryption', 'AES-256-GCM', Icons.lock),
                _buildProtocolDetail('Replication', '$_replicationFactor-way', Icons.content_copy),
                _buildProtocolDetail('Sharding', 'Enabled', Icons.grid_view),
                _buildProtocolDetail('Compression', 'ZSTD Level 9', Icons.compress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(String title, String status, IconData icon, Color color, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolDetail(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF39FF14)),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              'Storage Settings',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildSettingItem('Auto-pin uploads', true, Icons.push_pin),
          _buildSettingItem('Enable sharding', true, Icons.grid_view),
          _buildSettingItem('Background sync', true, Icons.sync),
          _buildSettingItem('Compress before upload', false, Icons.compress),
          _buildSettingItem('Show hidden files', false, Icons.visibility_off),
          _buildSettingItem('Encrypted storage only', true, Icons.lock),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'Storage Limits',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildLimitCard('Maximum File Size', '50 GB', Icons.insert_drive_file,
              const Color(0xFF39FF14)),
          _buildLimitCard('Total Storage', '100 GB', Icons.storage,
              const Color(0xFF00E5FF)),
          _buildLimitCard('Monthly Bandwidth', '1 TB', Icons.data_usage,
              const Color(0xFF7B61FF)),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF39FF14).withOpacity(0.1),
                  const Color(0xFF1E1E1E),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF39FF14)),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: const Color(0xFF39FF14), size: 5.w),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'All data is encrypted client-side before upload using AES-256-GCM. Decentralized storage ensures no single point of failure.',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFFBDBDBD),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, bool value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF39FF14), size: 4.w),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              setState(() {}); // Will be implemented with actual storage
            },
            activeColor: const Color(0xFF39FF14),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitCard(String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 4.w),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    final fileNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(Icons.cloud_upload, color: const Color(0xFF39FF14), size: 5.w),
            SizedBox(width: 2.w),
            Text(
              'Upload File',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 15.h,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 6.w, color: const Color(0xFF39FF14)),
                    SizedBox(height: 1.h),
                    Text(
                      'Tap to select file',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: fileNameController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'File Name (optional)',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF39FF14).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(Icons.check_circle, color: const Color(0xFF39FF14), size: 14.sp),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    'Files will be encrypted and replicated across storage nodes',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'File upload simulated in decentralized storage',
                    style: GoogleFonts.inter(fontSize: 11.sp),
                  ),
                  backgroundColor: const Color(0xFF39FF14),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF39FF14),
              foregroundColor: Colors.black,
            ),
            child: Text('Upload', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _downloadFile(StorageFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${file.name}...', style: GoogleFonts.inter(fontSize: 11.sp)),
        backgroundColor: const Color(0xFF39FF14),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _togglePin(StorageFile file) {
    setState(() {
      file.pinned = !file.pinned;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          file.pinned ? 'Pinned ${file.name}' : 'Unpinned ${file.name}',
          style: GoogleFonts.inter(fontSize: 11.sp),
        ),
        backgroundColor: const Color(0xFF39FF14),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteFile(StorageFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Delete File?',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete ${file.name}?',
          style: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _files.remove(file);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${file.name}', style: GoogleFonts.inter(fontSize: 11.sp)),
                  backgroundColor: const Color(0xFFFF5252),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class StorageFile {
  final String name;
  final double size;
  final String type;
  final DateTime uploadedAt;
  final String cid;
  bool pinned;

  StorageFile({
    required this.name,
    required this.size,
    required this.type,
    required this.uploadedAt,
    required this.cid,
    required this.pinned,
  });
}