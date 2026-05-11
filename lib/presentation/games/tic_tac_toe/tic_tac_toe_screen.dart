import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> with TickerProviderStateMixin {
  List<String> board;
  String currentPlayer;
  String winner;
  bool gameActive;
  int xWins;
  int oWins;
  int draws;

  late AnimationController _cellController;
  late Animation<double> _cellAnimation;

  @override
  void initState() {
    super.initState();
    board = List.filled(9, '');
    currentPlayer = 'X';
    winner = '';
    gameActive = true;
    xWins = 0;
    oWins = 0;
    draws = 0;

    _cellController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cellAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cellController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cellController.dispose();
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
          '🦦 Tic-Tac-Toe',
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
          SizedBox(height: 3.h),
          // Game Status
          _buildGameStatus(),
          SizedBox(height: 3.h),
          // Game Board
          _buildGameBoard(),
          SizedBox(height: 4.h),
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
          _buildScoreItem('X Wins', xWins, const Color(0xFF00E5FF)),
          _buildScoreItem('O Wins', oWins, const Color(0xFFFF5252)),
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
            fontSize: 20.sp,
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
      statusText = '🎉 Player $winner Wins!';
      statusColor = winner == 'X' ? const Color(0xFF00E5FF) : const Color(0xFFFF5252);
    } else if (!gameActive) {
      statusText = "🤝 It's a Draw!";
      statusColor = const Color(0xFF7B61FF);
    } else {
      statusText = "Player $currentPlayer's Turn";
      statusColor = currentPlayer == 'X' ? const Color(0xFF00E5FF) : const Color(0xFFFF5252);
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
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1.w,
          mainAxisSpacing: 1.w,
          childAspectRatio: 1.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return _buildCell(index);
        },
      ),
    );
  }

  Widget _buildCell(int index) {
    final isWinnerCell = _checkWinningLine(index);
    final cellValue = board[index];
    final isNotEmpty = cellValue.isNotEmpty;

    return GestureDetector(
      onTap: () => _onCellTapped(index),
      child: AnimatedBuilder(
        animation: isNotEmpty ? _cellAnimation : AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: isNotEmpty ? _cellAnimation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: isWinnerCell
                    ? const Color(0xFF39FF14).withOpacity(0.3)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isWinnerCell
                      ? const Color(0xFF39FF14)
                      : const Color(0xFF39FF14).withOpacity(0.3),
                  width: isWinnerCell ? 3 : 1,
                ),
              ),
              child: Center(
                child: isNotEmpty
                    ? Text(
                        cellValue,
                        style: GoogleFonts.inter(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: cellValue == 'X'
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFFFF5252),
                        ),
                      )
                    : Icon(
                        Icons.expand,
                        size: 4.w,
                        color: const Color(0xFF39FF14).withOpacity(0.3),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCellTapped(int index) {
    if (!gameActive || board[index].isNotEmpty) return;

    setState(() {
      board[index] = currentPlayer;
      _cellController.forward(from: 0.0);

      if (_checkWinner()) {
        gameActive = false;
        winner = currentPlayer;
        if (currentPlayer == 'X') {
          xWins++;
        } else {
          oWins++;
        }
      } else if (!board.contains('')) {
        gameActive = false;
        draws++;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  bool _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return true;
      }
    }
    return false;
  }

  bool _checkWinningLine(int index) {
    if (winner.isEmpty) return false;

    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (pattern.contains(index) &&
          board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]] == winner) {
        return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
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