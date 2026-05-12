import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({super.key});

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen>
    with TickerProviderStateMixin {
  static const int gridSize = 10;
  static const colors = [
    Color(0xFFFF5252), // Red
    Color(0xFF40C4FF), // Blue
    Color(0xFF69F0AE), // Green
    Color(0xFFFFD740), // Yellow
    Color(0xFFE040FB), // Purple
    Color(0xFFFF6E40), // Orange
  ];
  
  late List<List<String>> board;
  late int score;
  late int bubblesPopped;
  late GameState gameState;
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initGame();

    _popController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _popAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOut),
    );
  }

  void _initGame() {
    board = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    score = 0;
    bubblesPopped = 0;
    gameState = GameState.playing;
    _fillBoard();
  }

  void _fillBoard() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        board[row][col] = (random.nextInt(colors.length)).toString();
      }
    }
  }

  @override
  void dispose() {
    _popController.dispose();
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
          '🦦 Bubble Pop',
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
            onPressed: () {
              setState(() {
                _initGame();
              });
            },
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
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: _buildGrid(),
            ),
          ),
          // Game Over
          if (gameState == GameState.over) _buildGameOver(),
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
          _buildStatItem('Score', '$score', const Color(0xFF39FF14)),
          _buildStatItem('Popped', '$bubblesPopped', const Color(0xFF00E5FF)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Container(
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
      child: GridView.builder(
        padding: EdgeInsets.all(1.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 0.5.w,
          mainAxisSpacing: 0.5.h,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ gridSize;
          final col = index % gridSize;
          return _buildBubble(row, col, board[row][col]);
        },
      ),
    );
  }

  Widget _buildBubble(int row, int col, String colorIndex) {
    if (colorIndex.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final color = colors[int.parse(colorIndex)];

    return AnimatedBuilder(
      animation: _popAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _onBubbleTap(row, col),
          child: Transform.scale(
            scale: _popAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '🫧',
                  style: TextStyle(fontSize: 6.w, color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOver() {
    return Container(
      margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF39FF14).withOpacity(0.2),
            const Color(0xFF00E5FF).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF39FF14), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '🎉 Game Complete!',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF39FF14),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Score: $score',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Popped: $bubblesPopped',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _initGame();
              });
            },
            icon: Icon(Icons.refresh, size: 5.w, color: Colors.black),
            label: Text(
              'Play Again',
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
      ),
    );
  }

  void _onBubbleTap(int row, int col) {
    if (gameState != GameState.playing) return;
    if (board[row][col].isEmpty) return;

    final colorIndex = board[row][col];
    final connectedBubbles = _findConnectedBubbles(row, col, colorIndex);

    if (connectedBubbles.length >= 2) {
      _popBubbles(connectedBubbles);
    }
  }

  List<Point> _findConnectedBubbles(int row, int col, String colorIndex) {
    final connected = <Point>[];
    final visited = <Point>{};
    final queue = <Point>[Point(col, row)];
    visited.add(Point(col, row));

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      connected.add(current);

      final neighbors = [
        Point(current.x, current.y - 1), // Up
        Point(current.x, current.y + 1), // Down
        Point(current.x - 1, current.y), // Left
        Point(current.x + 1, current.y), // Right
      ];

      for (var neighbor in neighbors) {
        if (neighbor.x >= 0 &&
            neighbor.x < gridSize &&
            neighbor.y >= 0 &&
            neighbor.y < gridSize &&
            !visited.contains(neighbor) &&
            board[neighbor.y][neighbor.x] == colorIndex) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    return connected;
  }

  void _popBubbles(List<Point> bubbles) {
    setState(() {
      final points = bubbles.length * 10 + (bubbles.length - 2) * 20; // Bonus for larger groups
      score += points;
      bubblesPopped += bubbles.length;

      // Remove bubbles
      for (var bubble in bubbles) {
        board[bubble.y][bubble.x] = '';
      }

      // Play animation
      _popController.forward(from: 0.0);

      // Apply gravity
      _applyGravity();

      // Check if game is over
      if (!_hasMoves()) {
        gameState = GameState.over;
      }
    });
  }

  void _applyGravity() {
    for (int col = 0; col < gridSize; col++) {
      final column = <String>[];
      for (int row = 0; row < gridSize; row++) {
        if (board[row][col].isNotEmpty) {
          column.add(board[row][col]);
        }
      }

      // Fill from bottom
      for (int row = gridSize - 1; row >= 0; row--) {
        final index = row - (gridSize - column.length);
        if (index >= 0) {
          board[row][col] = column[index];
        } else {
          board[row][col] = '';
        }
      }
    }
  }

  bool _hasMoves() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col].isNotEmpty) {
          final connected = _findConnectedBubbles(row, col, board[row][col]);
          if (connected.length >= 2) {
            return true;
          }
        }
      }
    }
    return false;
  }
}

enum GameState { playing, over }

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Random {
  final _random = math.Random();

  int nextInt(int max) => _random.nextInt(max);
}