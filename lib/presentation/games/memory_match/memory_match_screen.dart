import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen>
    with TickerProviderStateMixin {
  List<MemoryCard> cards;
  List<int> flippedCards;
  bool isChecking;
  bool gameActive;
  int moves;
  int matches;
  int attempts;
  int bestScore;
  bool showAllCards;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    initGame();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  void initGame() {
    final emojis = ['🦦', '🎮', '🚀', '⭐', '🌟', '💎', '🔥', '💻'];
    cards = [];
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < emojis.length; j++) {
        cards.add(MemoryCard(
          id: cards.length,
          emoji: emojis[j],
          isFlipped: false,
          isMatched: false,
        ));
      }
    }
    cards.shuffle();
    flippedCards = [];
    isChecking = false;
    gameActive = true;
    moves = 0;
    matches = 0;
    attempts = 0;
    bestScore = 999;
    showAllCards = false;

    // Show all cards briefly at start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showAllCards = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          showAllCards = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
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
          '🦦 Memory Match',
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
          // Game Status
          gameActive ? _buildGameStatus() : _buildGameOver(),
          SizedBox(height: 2.h),
          // Game Board
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
          ),
          // Reset Button
          _buildResetButton(),
          SizedBox(height: 2.h),
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
          _buildStatItem('Moves', '$moves', const Color(0xFF00E5FF)),
          _buildStatItem('Matches', '$matches/8', const Color(0xFF39FF14)),
          _buildStatItem('Best', bestScore == 999 ? '-' : '$bestScore', const Color(0xFFFF5252)),
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
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatus() {
    double progress = matches / 8;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$matches/8 Matches',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF39FF14),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
              minHeight: 1.5.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    String resultText;
    Color resultColor;

    if (moves < bestScore) {
      resultText = '🏆 New Best Score!';
      resultColor = const Color(0xFFFFD740);
    } else {
      resultText = '🎉 Game Complete!';
      resultColor = const Color(0xFF39FF14);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            resultColor.withOpacity(0.2),
            resultColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            resultText,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: resultColor,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Moves: $moves',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Attempts: $attempts',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = cards[index];
    final isFlipped = card.isFlipped || card.isMatched || showAllCards;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(
              isFlipped ? 3.14159 : 0,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: card.isMatched
                      ? [
                          const Color(0xFF39FF14).withOpacity(0.3),
                          const Color(0xFF00E5FF).withOpacity(0.3),
                        ]
                      : isFlipped
                          ? [
                              const Color(0xFF2A2A2A),
                              const Color(0xFF1E1E1E),
                            ]
                          : [
                              const Color(0xFF39FF14).withOpacity(0.2),
                              const Color(0xFF00E5FF).withOpacity(0.2),
                            ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: card.isMatched
                      ? const Color(0xFF39FF14)
                      : isFlipped
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF39FF14),
                  width: card.isMatched ? 3 : 2,
                ),
                boxShadow: card.isMatched
                    ? [
                        BoxShadow(
                          color: const Color(0xFF39FF14).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isFlipped
                    ? Text(
                        card.emoji,
                        style: TextStyle(fontSize: 14.w),
                      )
                    : Icon(
                        Iconspsychology,
                        color: const Color(0xFF39FF14).withOpacity(0.5),
                        size: 8.w,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCardTap(int index) {
    if (!gameActive || isChecking) return;

    final card = cards[index];
    if (card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
      flippedCards.add(index);
      _flipController.forward(from: 0.0);
    });

    if (flippedCards.length == 2) {
      isChecking = true;
      attempts++;
      moves++;
      
      final card1 = cards[flippedCards[0]];
      final card2 = cards[flippedCards[1]];

      if (card1.emoji == card2.emoji) {
        // Match found
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            card1.isMatched = true;
            card2.isMatched = true;
            matches++;
            flippedCards.clear();
            isChecking = false;

            if (matches == 8) {
              gameActive = false;
              if (attempts < bestScore) {
                bestScore = attempts;
              }
            }
          });
        });
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            card1.isFlipped = false;
            card2.isFlipped = false;
            flippedCards.clear();
            isChecking = false;
          });
        });
      }
    }
  }

  Widget _buildResetButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            initGame();
          });
        },
        icon: Icon(Icons.refresh, size: 5.w, color: Colors.black),
        label: Text(
          'New Game',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF39FF14),
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}