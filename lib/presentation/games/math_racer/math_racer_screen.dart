import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

class MathRacerScreen extends StatefulWidget {
  const MathRacerScreen({super.key});

  @override
  State<MathRacerScreen> createState() => _MathRacerScreenState();
}

class _MathRacerScreenState extends State<MathRacerScreen>
    with TickerProviderStateMixin {
  String question;
  int correctAnswer;
  List<int> options;
  int score;
  int streak;
  double timeLeft;
  int totalTime;
  bool gameActive;
  Timer? gameTimer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initGame();

    _progressController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );
  }

  void _initGame() {
    score = 0;
    streak = 0;
    totalTime = 60;
    timeLeft = totalTime;
    gameActive = true;
    _generateQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      if (gameActive && timeLeft > 0) {
        setState(() {
          timeLeft -= 0.1;
          if (timeLeft <= 0) {
            timeLeft = 0;
            _endGame();
          }
        });
      }
    });
  }

  void _endGame() {
    gameActive = false;
    gameTimer?.cancel();
    setState(() {});
  }

  void _generateQuestion() {
    final operators = ['+', '-', '×'];
    final operator = operators[random.nextInt(operators.length)];
    int num1, num2, answer;

    switch (operator) {
      case '+':
        num1 = random.nextInt(50) + 1;
        num2 = random.nextInt(50) + 1;
        answer = num1 + num2;
        break;
      case '-':
        num1 = random.nextInt(50) + 20;
        num2 = random.nextInt(20) + 1;
        answer = num1 - num2;
        break;
      case '×':
        num1 = random.nextInt(12) + 1;
        num2 = random.nextInt(12) + 1;
        answer = num1 * num2;
        break;
      default:
        num1 = 1;
        num2 = 1;
        answer = 2;
    }

    question = '$num1 $operator $num2 = ?';
    correctAnswer = answer;

    // Generate options
    options = [answer];
    while (options.length < 4) {
      final wrongAnswer = answer + (random.nextInt(21) - 10);
      if (wrongAnswer != answer && wrongAnswer >= 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle();
  }

  void _checkAnswer(int selectedAnswer) {
    if (!gameActive) return;

    if (selectedAnswer == correctAnswer) {
      setState(() {
        streak++;
        score += 10 + (streak * 2);
        // Add bonus time for streak bonuses
        if (streak % 5 == 0) {
          timeLeft += 5;
        }
      });
      _showFeedback(true);
    } else {
      setState(() {
        streak = 0;
        timeLeft -= 3; // Penalty for wrong answer
        if (timeLeft < 0) timeLeft = 0;
      });
      _showFeedback(false);
    }

    if (gameActive) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && gameActive) {
          setState(() {
            _generateQuestion();
          });
        }
      });
    }
  }

  void _showFeedback(bool correct) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              correct ? '✓ Correct!' : '✗ Wrong!',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            if (correct && streak > 1) ...[
              SizedBox(width: 2.w),
              Text(
                'Streak: $streak',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: correct ? const Color(0xFF39FF14) : const Color(0xFFFF5252),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          '🦦 Math Racer',
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
          // Stats Bar
          _buildStatsBar(),
          SizedBox(height: 2.h),
          // Progress Bar
          _buildProgressBar(),
          SizedBox(height: 3.h),
          // Question
          if (gameActive) _buildQuestion() else _buildGameOver(),
          SizedBox(height: 4.h),
          // Options
          if (gameActive) _buildOptions(),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
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
          _buildStatItem('Streak', '$streak', const Color(0xFFFFD740)),
          _buildStatItem('Time', '${timeLeft.toStringAsFixed(1)}s', const Color(0xFF00E5FF)),
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = timeLeft / totalTime;
    final color = progress > 0.5
        ? const Color(0xFF39FF14)
        : progress > 0.2
            ? const Color(0xFFFFD740)
            : const Color(0xFFFF5252);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      height: 1.5.h,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 1.5.h,
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.2),
            const Color(0xFF39FF14).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 3.h,
            childAspectRatio: 1.5,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return _buildOptionButton(options[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOptionButton(int value) {
    return GestureDetector(
      onTap: () => _checkAnswer(value),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2A2A),
              const Color(0xFF1E1E1E),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF39FF14),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF39FF14).withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$value',
            style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF5252).withOpacity(0.2),
            const Color(0xFF39FF14).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF5252), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '⏱️ Time\'s Up!',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF5252),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Final Score: $score',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Best Streak: $streak',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _initGame();
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
    );
  }
}

class Random {
  final _random = math.Random();

  int nextInt(int max) => _random.nextInt(max);
}