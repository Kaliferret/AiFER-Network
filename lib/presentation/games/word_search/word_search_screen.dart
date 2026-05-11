import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  static const int gridSize = 10;
  late List<List<String>> grid;
  late List<String> wordsToFind;
  late List<String> foundWords;
  List<Point> selectedCells;
  bool isSelecting;
  
  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    wordsToFind = [
      'FERRET',
      'NEON',
      'QUANTUM',
      'MESH',
      'CRYPTO',
      'BLOCK',
      'FER',
      'AI',
    ];
    foundWords = [];
    selectedCells = [];
    isSelecting = false;
    _placeWords();
    _fillEmptyCells();
  }

  void _placeWords() {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (var word in wordsToFind) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 100) {
        final direction = (random + word.length + attempts) % 3; // 0: horizontal, 1: vertical, 2: diagonal
        final startRow = (random + word.length * attempts) % gridSize;
        final startCol = (random + word.length * attempts * 2) % gridSize;
        
        if (_canPlaceWord(word, startRow, startCol, direction)) {
          _placeWord(word, startRow, startCol, direction);
          placed = true;
        }
        attempts++;
      }
    }
  }

  bool _canPlaceWord(String word, int startRow, int startCol, int direction) {
    int dr = direction == 1 ? 1 : direction == 2 ? 1 : 0;
    int dc = direction == 0 ? 1 : direction == 2 ? 1 : -1;
    
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * dr;
      final col = startCol + i * dc;
      
      if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
        return false;
      }
      if (grid[row][col].isNotEmpty && grid[row][col] != word[i]) {
        return false;
      }
    }
    return true;
  }

  void _placeWord(String word, int startRow, int startCol, int direction) {
    int dr = direction == 1 ? 1 : direction == 2 ? 1 : 0;
    int dc = direction == 0 ? 1 : direction == 2 ? 1 : -1;
    
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * dr;
      final col = startCol + i * dc;
      grid[row][col] = word[i];
    }
  }

  void _fillEmptyCells() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col].isEmpty) {
          grid[row][col] = letters[(random + row * gridSize + col) % 26];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          '🦦 Word Search',
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
          // Word List
          _buildWordList(),
          SizedBox(height: 2.h),
          // Game Board
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: _buildGrid(),
            ),
          ),
          // Progress
          _buildProgress(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildWordList() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Words to find: ${wordsToFind.length}',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: wordsToFind.map((word) {
              final isFound = foundWords.contains(word);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isFound
                      ? const Color(0xFF39FF14).withOpacity(0.2)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFound ? const Color(0xFF39FF14) : Colors.grey[600]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  word,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isFound
                        ? const Color(0xFF39FF14)
                        : Colors.grey[400],
                    decoration:
                        isFound ? TextDecoration.lineThrough : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        crossAxisSpacing: 0.5.w,
        mainAxisSpacing: 0.5.h,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        final row = index ~/ gridSize;
        final col = index % gridSize;
        final isSelected = selectedCells.any((p) => p.x == col && p.y == row);
        final isPartOfFoundWord = _isPartOfFoundWord(row, col);
        
        return GestureDetector(
          onTapDown: (details) => _onCellTap(row, col),
          onTapUp: (_) => _onCellRelease(),
          onTapCancel: () => _onCellRelease(),
          child: _buildCell(row, col, grid[row][col], isSelected, isPartOfFoundWord),
        );
      },
    );
  }

  Widget _buildCell(int row, int col, String letter, bool isSelected, bool isFound) {
    Color bgColor;
    Color textColor;
    
    if (isFound) {
      bgColor = const Color(0xFF39FF14).withOpacity(0.3);
      textColor = const Color(0xFF39FF14);
    } else if (isSelected) {
      bgColor = const Color(0xFF00E5FF).withOpacity(0.3);
      textColor = const Color(0xFF00E5FF);
    } else {
      bgColor = const Color(0xFF2A2A2A);
      textColor = Colors.white;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFound
              ? const Color(0xFF39FF14)
              : isSelected
                  ? const Color(0xFF00E5FF)
                  : Colors.grey[700]!,
          width: isFound ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final progress = foundWords.length / wordsToFind.length;
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
                '${foundWords.length}/${wordsToFind.length}',
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
          if (foundWords.length == wordsToFind.length) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
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
                    '🎉 All Words Found!',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF39FF14),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _initGame();
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
          ],
        ],
      ),
    );
  }

  void _onCellTap(int row, int col) {
    setState(() {
      isSelecting = true;
      selectedCells = [Point(col, row)];
    });
  }

  void _onCellRelease() {
    if (selectedCells.length < 2) {
      setState(() {
        selectedCells = [];
        isSelecting = false;
      });
      return;
    }

    final word = selectedCells.map((p) => grid[p.y][p.x]).join();
    final reversedWord = word.split('').reversed.join('');
    
    if (wordsToFind.contains(word) && !foundWords.contains(word)) {
      setState(() {
        foundWords.add(word);
      });
    } else if (wordsToFind.contains(reversedWord) && !foundWords.contains(reversedWord)) {
      setState(() {
        foundWords.add(reversedWord);
      });
    }

    setState(() {
      selectedCells = [];
      isSelecting = false;
    });
  }

  bool _isPartOfFoundWord(int row, int col) {
    for (var word in foundWords) {
      final points = _getWordPoints(word);
      if (points.any((p) => p.x == col && p.y == row)) {
        return true;
      }
    }
    return false;
  }

  List<Point> _getWordPoints(String word) {
    final points = <Point>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == word[0]) {
          // Try all directions
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              if (dr == 0 && dc == 0) continue;
              
              final wordPoints = <Point>[];
              bool match = true;
              
              for (int i = 0; i < word.length; i++) {
                final r = row + i * dr;
                final c = col + i * dc;
                
                if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) {
                  match = false;
                  break;
                }
                
                if (grid[r][c] != word[i]) {
                  match = false;
                  break;
                }
                
                wordPoints.add(Point(c, r));
              }
              
              if (match && wordPoints.length == word.length) {
                return wordPoints;
              }
            }
          }
        }
      }
    }
    return points;
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