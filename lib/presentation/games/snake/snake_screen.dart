import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SnakeScreen extends StatefulWidget {
  const SnakeScreen({super.key});

  @override
  State<SnakeScreen> createState() => _SnakeScreenState();
}

class _SnakeScreenState extends State<SnakeScreen> with TickerProviderStateMixin {
  static const int gridSize = 20;
  late List<Point> snake;
  late Point food;
  late Direction direction;
  late Timer gameTimer;
  late bool gameActive;
  late bool gameOver;
  late int score;
  late int highScore;

  final int rows = 20;
  final int columns = 10;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    initGame();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void initGame() {
    snake = [Point(5, 10), Point(4, 10), Point(3, 10)];
    direction = Direction.right;
    score = 0;
    highScore = 0;
    gameOver = false;
    gameActive = true;
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;
      if (gameActive) {
        updateGame();
      }
    });
    generateFood();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    _pulseController.dispose();
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
          '🦦 Snake',
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
      ),
      body: Column(
        children: [
          // Score Board
          _buildScoreBoard(),
          SizedBox(height: 2.h),
          // Game Board
          Expanded(
            child: _buildGameBoard(),
          ),
          // Controls
          _buildControls(),
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
          _buildScoreItem('High Score', '$highScore', const Color(0xFFFFD740)),
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
      margin: EdgeInsets.symmetric(horizontal: 5.w),
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
      child: gameOver ? _buildGameOverOverlay() : _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(1.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 0.5.w,
        mainAxisSpacing: 0.5.h,
      ),
      itemCount: rows * columns,
      itemBuilder: (context, index) {
        final row = index ~/ columns;
        final col = index % columns;
        return _buildCell(row, col);
      },
    );
  }

  Widget _buildCell(int row, int col) {
    final point = Point(col, row);
    final isSnakeHead = snake.isNotEmpty && snake.first == point;
    final isSnakeBody = snake.contains(point) && !isSnakeHead;
    final isFood = point == food;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSnakeHead
            ? const Color(0xFF39FF14)
            : isSnakeBody
                ? const Color(0xFF39FF14).withOpacity(0.6)
                : isFood
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: isFood ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            if (isFood) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: const Text(
                  '🦦',
                  style: TextStyle(fontSize: 12),
                ),
              );
            } else if (isSnakeHead) {
              return const Text(
                '👀',
                style: TextStyle(fontSize: 10),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Stack(
      children: [
        _buildGrid(),
        Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '💀 Game Over',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF5252),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Score: $score',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      initGame();
                    });
                  },
                  icon: Icon(Icons.play_arrow, size: 5.w, color: Colors.black),
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
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Up
        _buildControlButton(Icons.keyboard_arrow_up, () {
          if (direction != Direction.down) {
            direction = Direction.up;
          }
        }),
        // Left, Down, Right
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(Icons.keyboard_arrow_left, () {
              if (direction != Direction.right) {
                direction = Direction.left;
              }
            }),
            SizedBox(width: 4.w),
            _buildControlButton(Icons.keyboard_arrow_down, () {
              if (direction != Direction.up) {
                direction = Direction.down;
              }
            }),
            SizedBox(width: 4.w),
            _buildControlButton(Icons.keyboard_arrow_right, () {
              if (direction != Direction.left) {
                direction = Direction.right;
              }
            }),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'Use arrow buttons or swipe to control',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF39FF14), width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF39FF14), size: 8.w),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.all(2.w),
        ),
      ),
    );
  }

  void updateGame() {
    if (snake.isEmpty) return;

    final head = Point(
      snake.first.x + direction.dx,
      snake.first.y + direction.dy,
    );

    // Check wall collision
    if (head.x < 0 || head.x >= columns || head.y < 0 || head.y >= rows) {
      endGame();
      return;
    }

    // Check self collision
    if (snake.contains(head)) {
      endGame();
      return;
    }

    snake.insert(0, head);

    // Check food collision
    if (head == food) {
      score += 10;
      if (score > highScore) {
        highScore = score;
      }
      generateFood();
    } else {
      snake.removeLast();
    }

    setState(() {});
  }

  void generateFood() {
    final availableSpots = <Point>[];
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        final point = Point(x, y);
        if (!snake.contains(point)) {
          availableSpots.add(point);
        }
      }
    }
    if (availableSpots.isNotEmpty) {
      food = availableSpots[(DateTime.now().millisecondsSinceEpoch) % availableSpots.length];
    }
  }

  void endGame() {
    gameActive = false;
    gameOver = true;
    gameTimer.cancel();
    setState(() {});
  }
}

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

enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  final int dx;
  final int dy;

  const Direction(this.dx, this.dy);
}