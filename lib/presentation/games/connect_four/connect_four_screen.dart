import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectFourScreen extends StatefulWidget {
  const ConnectFourScreen({super.key});

  @override
  State<ConnectFourScreen> createState() => _ConnectFourScreenState();
}

class _ConnectFourScreenState extends State<ConnectFourScreen>
    with TickerProviderStateMixin {
  late List<List<String>> board;
  late String currentPlayer;
  late String winner;
  late bool gameActive;
  late int player1Wins;
  late int player2Wins;
  late int draws;

  late AnimationController _dropController;
  late Animation<double> _dropAnimation;

  @override
  void initState() {
    super.initState();
    board = List.generate(6, (_) => List.filled(7, ''));
    currentPlayer = '🟦';
    winner = '';
    gameActive = true;
    player1Wins = 0;
    player2Wins = 0;
    draws = 0;

    _dropController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _dropAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _dropController.dispose();
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
          '🦦 Connect Four',
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
          // Game Status
          _buildGameStatus(),
          SizedBox(height: 2.h),
          // Game Board
          _buildGameBoard(),
          SizedBox(height: 3.h),
          // Reset Button
          _buildResetButton(),
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
          _buildScoreItem('🟦 P1 Wins', player1Wins, const Color(0xFF448AFF)),
          _buildScoreItem('🟥 P2 Wins', player2Wins, const Color(0xFFFF5252)),
          _buildScoreItem('Draws', draws, const Color(0xFF7B61FF)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
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
        SizedBox(height: 0.5.h),
        Text(
          '$score',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatus() {
    String statusText;
    Color statusColor;

    if (winner.isNotEmpty) {
      statusText = winner == '🟦' ? '🎉 Player 1 Wins!' : '🎉 Player 2 Wins!';
      statusColor = winner == '🟦' ? const Color(0xFF448AFF) : const Color(0xFFFF5252);
    } else if (!gameActive) {
      statusText = "🤝 It's a Draw!";
      statusColor = const Color(0xFF7B61FF);
    } else {
      statusText = currentPlayer == '🟦' ? "Player 1's Turn (🟦)" : "Player 2's Turn (🟥)";
      statusColor =
          currentPlayer == '🟦' ? const Color(0xFF448AFF) : const Color(0xFFFF5252);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF), width: 3),
      ),
      child: Column(
        children: [
          // Column indicators (tap to drop)
          Row(
            children: List.generate(7, (col) => _buildColumnIndicator(col)),
          ),
          SizedBox(height: 1.h),
          // Game board
          ...List.generate(6, (row) {
            return Row(
              children:
                  List.generate(7, (col) => _buildCell(row, col)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColumnIndicator(int col) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _dropPiece(col),
        child: Container(
          height: 6.h,
          margin: EdgeInsets.all(0.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFF39FF14).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF39FF14), width: 2),
          ),
          child: Icon(
            Icons.arrow_downward,
            color: const Color(0xFF39FF14),
            size: 4.w,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final cellValue = board[row][col];
    final isNotEmpty = cellValue.isNotEmpty;

    return Expanded(
      child: GestureDetector(
        onTap: () => _dropPiece(col),
        child: Container(
          height: 9.h,
          margin: EdgeInsets.all(0.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: isNotEmpty
              ? AnimatedBuilder(
                  animation: _dropAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _dropAnimation.value * 20),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cellValue == '🟦'
                              ? const Color(0xFF448AFF)
                              : const Color(0xFFFF5252),
                          boxShadow: [
                            BoxShadow(
                              color: (cellValue == '🟦'
                                          ? const Color(0xFF448AFF)
                                          : const Color(0xFFFF5252))
                                      .withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : null,
        ),
      ),
    );
  }

  void _dropPiece(int col) {
    if (!gameActive) return;

    // Find the lowest empty row in this column
    int? targetRow;
    for (int row = 5; row >= 0; row--) {
      if (board[row][col].isEmpty) {
        targetRow = row;
        break;
      }
    }

    if (targetRow == null) {
      // Column is full
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Column is full!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      board[targetRow!][col] = currentPlayer;
      _dropController.forward(from: 0.0);

      if (_checkWinner()) {
        gameActive = false;
        winner = currentPlayer;
        if (currentPlayer == '🟦') {
          player1Wins++;
        } else {
          player2Wins++;
        }
      } else if (_checkDraw()) {
        gameActive = false;
        draws++;
      } else {
        currentPlayer = currentPlayer == '🟦' ? '🟥' : '🟦';
      }
    });
  }

  bool _checkWinner() {
    // Check horizontal
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col].isNotEmpty &&
            board[row][col] == board[row][col + 1] &&
            board[row][col] == board[row][col + 2] &&
            board[row][col] == board[row][col + 3]) {
          return true;
        }
      }
    }

    // Check vertical
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 7; col++) {
        if (board[row][col].isNotEmpty &&
            board[row][col] == board[row + 1][col] &&
            board[row][col] == board[row + 2][col] &&
            board[row][col] == board[row + 3][col]) {
          return true;
        }
      }
    }

    // Check diagonal (down-right)
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col].isNotEmpty &&
            board[row][col] == board[row + 1][col + 1] &&
            board[row][col] == board[row + 2][col + 2] &&
            board[row][col] == board[row + 3][col + 3]) {
          return true;
        }
      }
    }

    // Check diagonal (up-right)
    for (int row = 3; row < 6; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col].isNotEmpty &&
            board[row][col] == board[row - 1][col + 1] &&
            board[row][col] == board[row - 2][col + 2] &&
            board[row][col] == board[row - 3][col + 3]) {
          return true;
        }
      }
    }

    return false;
  }

  bool _checkDraw() {
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        if (board[row][col].isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void _resetGame() {
    setState(() {
      board = List.generate(6, (_) => List.filled(7, ''));
      currentPlayer = '🟦';
      winner = '';
      gameActive = true;
    });
  }

  Widget _buildResetButton() {
    return ElevatedButton.icon(
      onPressed: _resetGame,
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
    );
  }
}