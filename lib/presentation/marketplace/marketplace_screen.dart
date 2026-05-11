import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  final List<AppCategory> _categories = [
    AppCategory('All', Icons.apps, true),
    AppCategory('Games', Icons.sports_esports, false),
    AppCategory('Productivity', Icons.work, false),
    AppCategory('Social', Icons.people, false),
    AppCategory('Finance', Icons.account_balance, false),
    AppCategory('Tools', Icons.build, false),
  ];

  final List<MarketplaceApp> _apps = [
    MarketplaceApp(
      id: 'fer.wallet',
      name: 'FER Wallet',
      category: 'Finance',
      developer: 'FER Network',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF39FF14),
      description: 'Quantum-secure decentralized wallet',
      rating: 4.8,
      downloads: '50K+',
      price: 0.0,
      featured: true,
    ),
    MarketplaceApp(
      id: 'fer.chat',
      name: 'FER Chat',
      category: 'Social',
      developer: 'FER Network',
      icon: Icons.chat,
      color: const Color(0xFF00E5FF),
      description: 'End-to-end encrypted messaging via mesh',
      rating: 4.7,
      downloads: '35K+',
      price: 0.0,
      featured: true,
    ),
    MarketplaceApp(
      id: 'fer.storage',
      name: 'FER Storage',
      category: 'Tools',
      developer: 'FER Network',
      icon: Icons.cloud,
      color: const Color(0xFF7B61FF),
      description: 'Decentralized storage with IPFS integration',
      rating: 4.6,
      downloads: '28K+',
      price: 0.0,
      featured: true,
    ),
    MarketplaceApp(
      id: 'fer.games.tic',
      name: 'Tic Tac Toe',
      category: 'Games',
      developer: 'FER Network',
      icon: Icons.grid_3x3,
      color: const Color(0xFFFF4081),
      description: 'Classic puzzle game',
      rating: 4.5,
      downloads: '45K+',
      price: 0.0,
      featured: false,
    ),
    MarketplaceApp(
      id: 'fer.games.snake',
      name: 'Snake',
      category: 'Games',
      developer: 'FER Network',
      icon: Icons.stars,
      color: const Color(0xFF76FF03),
      description: 'Classic snake game with ferret twist',
      rating: 4.6,
      downloads: '52K+',
      price: 0.0,
      featured: false,
    ),
    MarketplaceApp(
      id: 'fer.nft',
      name: 'FER NFT Gallery',
      category: 'Social',
      developer: 'FER Network',
      icon: Icons.image,
      color: const Color(0xFFFFD740),
      description: 'Browse and trade quantum-secured NFTs',
      rating: 4.4,
      downloads: '18K+',
      price: 0.0,
      featured: false,
    ),
    MarketplaceApp(
      id: 'fer.voice',
      name: 'FER Voice',
      category: 'Social',
      developer: 'FER Network',
      icon: Icons.mic,
      color: const Color(0xFF69F0AE),
      description: 'Encrypted voice calls via mesh network',
      rating: 4.5,
      downloads: '22K+',
      price: 0.0,
      featured: false,
    ),
    MarketplaceApp(
      id: 'fer.calculator',
      name: 'FER Calculator',
      category: 'Tools',
      developer: 'FER Network',
      icon: Icons.calculate,
      color: const Color(0xFF80D8FF),
      description: 'Advanced scientific calculator',
      rating: 4.3,
      downloads: '38K+',
      price: 0.0,
      featured: false,
    ),
    MarketplaceApp(
      id: 'fer.exchange',
      name: 'FER Exchange',
      category: 'Finance',
      developer: 'FER Network',
      icon: Icons.currency_exchange,
      color: const Color(0xFFFF5252),
      description: 'Decentralized exchange with low fees',
      rating: 4.6,
      downloads: '15K+',
      price: 0.0,
      featured: true,
    ),
    MarketplaceApp(
      id: 'fer.music',
      name: 'FER Music',
      category: 'Social',
      developer: 'FER Network',
      icon: Icons.music_note,
      color: const Color(0xFFEA80FC),
      description: 'Decentralized music streaming',
      rating: 4.4,
      downloads: '32K+',
      price: 0.0,
      featured: false,
    ),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() {
      for (int i = 0; i < _categories.length; i++) {
        _categories[i].isSelected = i == index;
      }
    });
  }

  List<MarketplaceApp> get _filteredApps {
    final selectedCategory = _categories.firstWhere((c) => c.isSelected).name;
    if (selectedCategory == 'All') return _apps;
    return _apps.where((app) => app.category == selectedCategory).toList();
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
              'FER Marketplace',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF39FF14),
              ),
            ),
            Text(
              'Decentralized App Store',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExploreTab(),
                _buildMyAppsTab(),
                _buildUpdatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          Tab(text: 'Explore'),
          Tab(text: 'My Apps'),
          Tab(text: 'Updates'),
        ],
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategories(),
        Expanded(
          child: _buildFeaturedApps(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF39FF14)),
          SizedBox(width: 3.w),
          Expanded(
            child: TextField(
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search apps, games, tools...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12.sp,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.mic, color: Color(0xFF00E5FF)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () => _selectCategory(index),
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: category.isSelected
                    ? const Color(0xFF39FF14)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: category.isSelected
                      ? const Color(0xFF39FF14)
                      : const Color(0xFF39FF14).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 14.sp,
                    color: category.isSelected
                        ? Colors.black
                        : const Color(0xFF39FF14),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    category.name,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: category.isSelected ? FontWeight.bold : FontWeight.normal,
                      color: category.isSelected ? Colors.black : const Color(0xFF39FF14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedApps() {
    final featuredApps = _filteredApps.where((app) => app.featured).toList();
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featuredApps.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                'Featured Apps',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...featuredApps.map((app) => _buildFeaturedAppCard(app)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                'All Apps',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          ..._filteredApps.map((app) => _buildAppCard(app)),
        ],
      ),
    );
  }

  Widget _buildFeaturedAppCard(MarketplaceApp app) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            app.color.withOpacity(0.2),
            const Color(0xFF1E1E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app.color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: app.color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(app.icon, color: Colors.black, size: 8.w),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          app.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39FF14),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'FEATURED',
                            style: GoogleFonts.inter(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      app.developer,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: const Color(0xFFFFD740), size: 14.sp),
                  SizedBox(width: 0.5.w),
                  Text(
                    app.rating.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            app.description,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFFBDBDBD),
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.download, size: 12.sp, color: const Color(0xFF9E9E9E)),
                  SizedBox(width: 0.5.w),
                  Text(
                    app.downloads,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showInstallDialog(app),
                icon: const Icon(Icons.download, size: 16),
                label: Text(
                  'Install',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39FF14),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(MarketplaceApp app) {
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
              color: app.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: app.color.withOpacity(0.5)),
            ),
            child: Icon(app.icon, color: app.color, size: 6.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  app.developer,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: const Color(0xFFFFD740), size: 12.sp),
                  SizedBox(width: 0.3.w),
                  Text(
                    app.rating.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                app.price == 0 ? 'FREE' : '\$${app.price.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF69F0AE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyAppsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_special,
            size: 20.w,
            color: const Color(0xFF39FF14),
          ),
          SizedBox(height: 2.h),
          Text(
            'No installed apps yet',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Browse the marketplace to install apps',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF39FF14),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Browse Apps',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.system_update,
            size: 20.w,
            color: const Color(0xFF00E5FF),
          ),
          SizedBox(height: 2.h),
          Text(
            'All apps are up to date',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'No updates available at this time',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  void _showInstallDialog(MarketplaceApp app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: app.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(app.icon, color: Colors.black, size: 5.w),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                app.name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.developer,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              app.description,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFFBDBDBD),
              ),
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Icon(Icons.star, color: const Color(0xFFFFD740), size: 14.sp),
                SizedBox(width: 0.5.w),
                Text(
                  app.rating.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.download, color: const Color(0xFF9E9E9E), size: 14.sp),
                SizedBox(width: 0.5.w),
                Text(
                  app.downloads,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF39FF14).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF39FF14)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: const Color(0xFF39FF14), size: 14.sp),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      'Quantum-verified • Decentralized',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: const Color(0xFF39FF14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${app.name} will be installed via mesh network',
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
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, size: 16),
                SizedBox(width: 1.w),
                Text(
                  'Install',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppCategory {
  final String name;
  final IconData icon;
  bool isSelected;

  AppCategory(this.name, this.icon, this.isSelected);
}

class MarketplaceApp {
  final String id;
  final String name;
  final String category;
  final String developer;
  final IconData icon;
  final Color color;
  final String description;
  final double rating;
  final String downloads;
  final double price;
  final bool featured;

  MarketplaceApp({
    required this.id,
    required this.name,
    required this.category,
    required this.developer,
    required this.icon,
    required this.color,
    required this.description,
    required this.rating,
    required this.downloads,
    required this.price,
    required this.featured,
  });
}