import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen>
    with TickerProviderStateMixin {
  late List<List<int>> board;
  late int score;
  late int bestScore;
  late bool gameOver;

  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initGame();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  void _initGame() {
    board = List.generate(4, (_) => List.filled(4, 0));
    score = 0;
    bestScore = 0;
    gameOver = false;
    _addRandomTile();
    _addRandomTile();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          '🦦 2048',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 6.w, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 5.w, color: const Color(0xFF39FF14)),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score Board
          _buildScoreBoard(),
          SizedBox(height: 2.h),
          // Game Board
          Expanded(
            child: Center(
              child: _buildGameBoard(),
            ),
          ),
          // Controls Info
          _buildControlsInfo(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E1E),
            const Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF14).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Score', '$score', const Color(0xFF39FF14)),
          _buildScoreItem('Best', '$bestScore', const Color(0xFFFFD740)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Container(
      width: 85.w,
      height: 85.w,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background grid
          GridView.builder(
            padding: EdgeInsets.all(1.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 1.w,
              mainAxisSpacing: 1.w,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
          // Tiles
          Padding(
            padding: EdgeInsets.all(1.w),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1.w,
                mainAxisSpacing: 1.w,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                final row = index ~/ 4;
                final col = index % 4;
                return _buildTile(board[row][col]);
              },
            ),
          ),
          // Game Over Overlay
          if (gameOver) _buildGameOverOverlay(),
        ],
      ),
    );
  }

  Widget _buildTile(int value) {
    if (value == 0) {
      return const SizedBox.shrink();
    }

    final tileColor = _getTileColor(value);
    final textColor = value <= 4 ? const Color(0xFF1E1E1E) : Colors.white;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _slideAnimation.value,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tileColor,
                  tileColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: tileColor.withOpacity(0.4),
                  blurRadius: value >= 512 ? 20 : 10,
                  spreadRadius: value >= 512 ? 5 : 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$value',
                style: GoogleFonts.poppins(
                  fontSize: value >= 1024 ? 10.sp : value >= 128 ? 14.sp : 18.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFF40C4FF);
      case 4:
        return const Color(0xFF00E5FF);
      case 8:
        return const Color(0xFF69F0AE);
      case 16:
        return const Color(0xFF39FF14);
      case 32:
        return const Color(0xFFB2FF59);
      case 64:
        return const Color(0xFFFFEE58);
      case 128:
        return const Color(0xFFFFD740);
      case 256:
        return const Color(0xFFFFAB40);
      case 512:
        return const Color(0xFFFF6E40);
      case 1024:
        return const Color(0xFFFF5252);
      case 2048:
        return const Color(0xFFE040FB);
      default:
        return const Color(0xFF7B61FF);
    }
  }

  Widget _buildGameOverOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gameOver && _canMove() ? '🎮 Game Continue!' : '💥 Game Over!',
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: gameOver && _canMove()
                    ? const Color(0xFF39FF14)
                    : const Color(0xFFFF5252),
              ),
            ),
            if (!gameOver || !_canMove()) ...[
              SizedBox(height: 2.h),
              Text(
                'Score: $score',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: _resetGame,
                icon: Icon(Icons.play_arrow, size: 5.w, color: Colors.black),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39FF14),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlsInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Swipe in any direction to move tiles',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[300],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _moveLeft() {
    bool moved = false;
    for (int row = 0; row < 4; row++) {
      var newRow = board[row].where((v) => v != 0).toList();
      for (int i = 0; i < newRow.length - 1; i++) {
        if (newRow[i] == newRow[i + 1]) {
          newRow[i] *= 2;
          score += newRow[i];
          newRow.removeAt(i + 1);
        }
      }
      while (newRow.length < 4) {
        newRow.add(0);
      }
      for (int col = 0; col < 4; col++) {
        if (board[row][col] != newRow[col]) {
          moved = true;
        }
        board[row][col] = newRow[col];
      }
    }
    if (moved) {
      _slideController.forward(from: 0.0);
      _afterMove();
    }
  }

  void _moveRight() {
    bool moved = false;
    for (int row = 0; row < 4; row++) {
      var newRow = board[row].where((v) => v != 0).toList().reversed.toList();
      for (int i = 0; i < newRow.length - 1; i++) {
        if (newRow[i] == newRow[i + 1]) {
          newRow[i] *= 2;
          score += newRow[i];
          newRow.removeAt(i + 1);
        }
      }
      while (newRow.length < 4) {
        newRow.add(0);
      }
      newRow = newRow.reversed.toList();
      for (int col = 0; col < 4; col++) {
        if (board[row][col] != newRow[col]) {
          moved = true;
        }
        board[row][col] = newRow[col];
      }
    }
    if (moved) {
      _slideController.forward(from: 0.0);
      _afterMove();
    }
  }

  void _moveUp() {
    bool moved = false;
    for (int col = 0; col < 4; col++) {
      var newCol = <int>[];
      for (int row = 0; row < 4; row++) {
        if (board[row][col] != 0) {
          newCol.add(board[row][col]);
        }
      }
      for (int i = 0; i < newCol.length - 1; i++) {
        if (newCol[i] == newCol[i + 1]) {
          newCol[i] *= 2;
          score += newCol[i];
          newCol.removeAt(i + 1);
        }
      }
      while (newCol.length < 4) {
        newCol.add(0);
      }
      for (int row = 0; row < 4; row++) {
        if (board[row][col] != newCol[row]) {
          moved = true;
        }
        board[row][col] = newCol[row];
      }
    }
    if (moved) {
      _slideController.forward(from: 0.0);
      _afterMove();
    }
  }

  void _moveDown() {
    bool moved = false;
    for (int col = 0; col < 4; col++) {
      var newCol = <int>[];
      for (int row = 3; row >= 0; row--) {
        if (board[row][col] != 0) {
          newCol.add(board[row][col]);
        }
      }
      for (int i = 0; i < newCol.length - 1; i++) {
        if (newCol[i] == newCol[i + 1]) {
          newCol[i] *= 2;
          score += newCol[i];
          newCol.removeAt(i + 1);
        }
      }
      while (newCol.length < 4) {
        newCol.add(0);
      }
      newCol = newCol.reversed.toList();
      for (int row = 0; row < 4; row++) {
        if (board[row][col] != newCol[row]) {
          moved = true;
        }
        board[row][col] = newCol[row];
      }
    }
    if (moved) {
      _slideController.forward(from: 0.0);
      _afterMove();
    }
  }

  void _afterMove() {
    _addRandomTile();
    if (score > bestScore) {
      bestScore = score;
    }
    if (!_canMove()) {
      gameOver = true;
    }
    setState(() {});
  }

  void _addRandomTile() {
    final emptySpots = <Point>[];
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] == 0) {
          emptySpots.add(Point(col, row));
        }
      }
    }
    if (emptySpots.isNotEmpty) {
      final spot = emptySpots[(DateTime.now().millisecondsSinceEpoch) % emptySpots.length];
      board[spot.y][spot.x] = (DateTime.now().millisecond % 10 < 9) ? 2 : 4;
    }
  }

  bool _canMove() {
    // Check for empty cells
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] == 0) return true;
      }
    }
    // Check for adjacent equal cells
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (col < 3 && board[row][col] == board[row][col + 1]) return true;
        if (row < 3 && board[row][col] == board[row + 1][col]) return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      _initGame();
    });
  }
}

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}