import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// FerretTerminal - CLI/Terminal Interface
/// Placeholder implementation for AIFER v11 integration
class FerretTerminalScreen extends StatefulWidget {
  const FerretTerminalScreen({Key? key}) : super(key: key);

  @override
  State<FerretTerminalScreen> createState() => _FerretTerminalScreenState();
}

class _FerretTerminalScreenState extends State<FerretTerminalScreen> {
  final List<TerminalLine> _lines = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String _currentDirectory = '/home/ferret';
  bool _isCommandRunning = false;
  int _commandHistoryIndex = -1;
  final List<String> _commandHistory = [];

  @override
  void initState() {
    super.initState();
    _printWelcomeMessage();
    _focusNode.requestFocus();
  }

  void _printWelcomeMessage() {
    _addLine(
      TerminalLine(
        text: '''
╔════════════════════════════════════════════════════════════╗
║  ╔══╗╔═╗╔═╗╔═╗╔═╗  ╔═╗╔══╗╔═╗╔╗╔╔═╗╔═╗╔═╗                  ║
║  ║╬╬╠╣╠╣╬║║╬╚╝╠╗╚╗╠╣╠╣║╬╬╠╣╠╣║╚╝║╬╬╚╗╔╝║                  ║
║  ╚╗╔╣╔╩╗╔╣║╔╗╔╩╗╔╝╚╗╔╣╠╗╔╣╔╗╗╔╩╗╔╩╗╔╝╚╝                    ║
║   ╚╝╚╝ ╚╝╚╝╚╝ ╚╝  ╚╝╚╝╚╝╚╝╚╝╚╝ ╚╝ ╚╝╚╝                     ║
╠════════════════════════════════════════════════════════════╣
║  AiFER OS v11 • Neon Ferret Terminal                    ║
║  Type 'help' for available commands                       ║
╚════════════════════════════════════════════════════════════╝''',
        type: TerminalLineType.system,
      ),
    );
    _addLine(
      TerminalLine(
        text: 'Welcome, Ferret! 🦦',
        type: TerminalLineType.info,
      ),
    );
  }

  void _addLine(TerminalLine line) {
    setState(() {
      _lines.add(line);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executeCommand(String commandInput) async {
    if (_isCommandRunning || commandInput.trim().isEmpty) return;

    // Add command to output
    _addLine(
      TerminalLine(
        text: '$_currentDirectory > $commandInput',
        type: TerminalLineType.command,
      ),
    );

    // Add to history
    _commandHistory.add(commandInput);
    _commandHistoryIndex = _commandHistory.length;

    setState(() {
      _isCommandRunning = true;
    });

    // Parse and execute command
    final parts = commandInput.trim().split(' ');
    final command = parts[0].toLowerCase();
    final args = parts.skip(1).toList();

    await Future.delayed(Duration(milliseconds: 300)); // Simulate processing

    switch (command) {
      case 'help':
        _executeHelp();
        break;
      case 'clear':
        _executeClear();
        break;
      case 'ls':
        _executeLs(args);
        break;
      case 'cd':
        _executeCd(args);
        break;
      case 'pwd':
        _executePwd();
        break;
      case 'cat':
        _executeCat(args);
        break;
      case 'echo':
        _executeEcho(args);
        break;
      case 'date':
        _executeDate();
        break;
      case 'whoami':
        _executeWhoami();
        break;
      case 'uname':
        _executeUname(args);
        break;
      case 'neofetch':
        _executeNeofetch();
        break;
      case 'matrix':
        _executeMatrix();
        break;
      case 'ferret':
        _executeFerret(args);
        break;
      case 'exit':
        _executeExit();
        break;
      default:
        _addLine(
          TerminalLine(
            text: "Command not found: $command. Type 'help' for available commands.",
            type: TerminalLineType.error,
          ),
        );
    }

    setState(() {
      _isCommandRunning = false;
    });

    _scrollToBottom();
  }

  void _executeHelp() {
    _addLine(
      TerminalLine(
        text: '''
Available Commands:
  help     - Show this help message
  clear    - Clear terminal output
  ls       - List files in current directory
  cd <dir> - Change directory
  pwd      - Print working directory
  cat <file> - Print file contents
  echo <text> - Print text to terminal
  date     - Show current date and time
  whoami   - Show current user
  uname    - System information
  neofetch - Display system information (ASCII art)
  matrix   - Toggle matrix effect (demo)
  ferret   - Ferret-specific commands
    ferret status - Show system status
    ferret mesh - Show mesh network info
    ferret network - Show network statistics
  exit     - Close terminal

Tip: Use Tab for autocomplete and ↑/↓ for command history''',
        type: TerminalLineType.system,
      ),
    );
  }

  void _executeClear() {
    setState(() {
      _lines.clear();
      _printWelcomeMessage();
    });
  }

  void _executeLs(List<String> args) {
    final files = [
      {'name': 'documents', 'type': 'folder', 'size': '-' },
      {'name': 'downloads', 'type': 'folder', 'size': '-' },
      {'name': 'images', 'type': 'folder', 'size': '-' },
      {'name': 'videos', 'type': 'folder', 'size': '-' },
      {'name': 'config.json', 'type': 'file', 'size': '2.1 KB' },
      {'name': 'readme.txt', 'type': 'file', 'size': '1.5 KB' },
      {'name': 'ferret_os.exe', 'type': 'exec', 'size': '42.5 MB' },
      {'name': 'network.log', 'type': 'file', 'size': '8.2 KB' },
    ];

    _addLine(
      TerminalLine(
        text: args.contains('-l') ? '\n' + _formatFileListDetailed(files) : _formatFileListSimple(files),
        type: TerminalLineType.output,
      ),
    );
  }

  String _formatFileListSimple(List<Map<String, String>> files) {
    return files.map((file) {
      final icon = file['type'] == 'folder' ? '📁' : (file['type'] == 'exec' ? '⚡' : '📄');
      return '$icon  ${file['name']}';
    }).join('\n');
  }

  String _formatFileListDetailed(List<Map<String, String>> files) {
    return files.map((file) {
      return '${file['type'] == 'folder' ? 'drwxr-xr-x' : '-rw-r--r--'}   ${file['size']}   ${file['name']}';
    }).join('\n');
  }

  void _executeCd(List<String> args) {
    if (args.isEmpty) {
      _currentDirectory = '/home/ferret';
    } else {
      final dir = args[0];
      if (dir == '..') {
        if (_currentDirectory != '/') {
          _currentDirectory = _currentDirectory.substring(0, _currentDirectory.lastIndexOf('/')) || '/';
        }
      } else if (dir.startsWith('/')) {
        _currentDirectory = dir;
      } else {
        _currentDirectory += '/$dir';
      }
    }
    _addLine(
      TerminalLine(text: 'Changed to $_currentDirectory', type: TerminalLineType.output),
    );
  }

  void _executePwd() {
    _addLine(
      TerminalLine(text: _currentDirectory, type: TerminalLineType.output),
    );
  }

  void _executeCat(List<String> args) {
    if (args.isEmpty) {
      _addLine(
        TerminalLine(
          text: 'cat: missing file operand',
          type: TerminalLineType.error,
        ),
      );
    } else {
      _addLine(
        TerminalLine(
          text: '''
${args[0]}

────────────────────────────────────────────────────────────────────────
AiFER OS v11 Configuration File (Placeholder)

{
  "version": "11.0.0",
  "theme": "neon-ferret",
  "language": "en",
  "mesh_enabled": true,
  "ai_assistant": true,
  "quantum_encryption": true,
  "wallet_address": "0x7a3f...9c4e",
  "network_nodes": 42
}

────────────────────────────────────────────────────────────────────────
End of file''',
          type: TerminalLineType.output,
        ),
      );
    }
  }

  void _executeEcho(List<String> args) {
    _addLine(
      TerminalLine(
        text: args.join(' '),
        type: TerminalLineType.output,
      ),
    );
  }

  void _executeDate() {
    _addLine(
      TerminalLine(
        text: DateTime.now().toIso8601String(),
        type: TerminalLineType.output,
      ),
    );
  }

  void _executeWhoami() {
    _addLine(
      TerminalLine(
        text: 'ferret@neon-ferret',
        type: TerminalLineType.output,
      ),
    );
  }

  void _executeUname(List<String> args) {
    if (args.contains('-a')) {
      _addLine(
        TerminalLine(
          text: 'NeonFerret ferret-os 11.0.0 #1 SMP PREEMPT FerretOS GNU/Linux x86_64',
          type: TerminalLineType.output,
        ),
      );
    } else {
      _addLine(
        TerminalLine(text: 'FerretOS', type: TerminalLineType.output),
      );
    }
  }

  void _executeNeofetch() {
    _addLine(
      TerminalLine(
        text: '''
      ╔══════════╗      ferret@neon-ferret
      ║    🦦     ║      ──────────────────
      ║     ◣◢   ║      OS: AiFER OS v11 Neon Ferret
      ║     ◢◣   ║      Host: Virtual Machine
      ║    ◣◢◣◢   ║      Kernel: FerretOS 11.0.0
      ║   ◢◣◣◣◢   ║      Uptime: ${_calculateUptime()}
      ║  ◢◣◣◣◣◣◢   ║      Shell: FerretShell 1.0
      ╚══════════╝      Resolution: ${100.w.toInt()}x${100.h.toInt()}
                       DE: FerretDesktop
                       Theme: Neon Ferret
                       Terminal: FerretTerminal
                       CPU: Virtual Quantum Core @ 4.2GHz
                       Memory: 8.0GiB
                       Mesh Nodes: 42
                       Battery: 85%
                       ═════════════════════
                       🟢 Quantum Secure
                       🔗 42 Active Nodes
                       🦦 AiFER OS v11''',
        type: TerminalLineType.system,
      ),
    );
  }

  String _calculateUptime() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final uptime = now.difference(start);
    return '${uptime.inHours}h ${uptime.inMinutes % 60}m';
  }

  void _executeMatrix() {
    _addLine(
      TerminalLine(
        text: '''
Initiating Matrix Protocol...
🦦 Matrix Effect Active (Demo)
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓ ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
🦦 MATRIX PROTOCOL ENGAGED
Quantum Encryption: Active
Mesh Network: Connected
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓''',
        type: TerminalLineType.system,
      ),
    );
  }

  void _executeFerret(List<String> args) {
    if (args.isEmpty) {
      _addLine(
        TerminalLine(
          text: 'usage: ferret <command>\n\nFerret Commands:\n  status   - Show system status\n  mesh     - Show mesh network info\n  network  - Show network statistics',
          type: TerminalLineType.error,
        ),
      );
    } else {
      switch (args[0]) {
        case 'status':
          _addLine(
            TerminalLine(
              text: '''
╔════════════════════════════════════════════════════════════╗
║                    🦦 SYSTEM STATUS                         ║
╠════════════════════════════════════════════════════════════╣
║  OS Version        : AiFER OS v11.0.0                      ║
║  Battery           : 85% ████████████████░░░░               ║
║  Network           : Connected (Quantum Secure)             ║
║  Mesh Nodes        : 42 active                              ║
║  Encryption        : Enabled (Lattice-based)                ║
║  AI Assistant      : Online                                ║
║  Storage           : 64GB free / 256GB total                 ║
║  RAM               : 4.2GB / 8.0GB used                     ║
║  Temperature       : 42°C                                   ║
║  Uptime            : ${_calculateUptime()}                 ║
╠════════════════════════════════════════════════════════════╣
║  ✅ All systems operational                               ║
╚════════════════════════════════════════════════════════════╝''',
              type: TerminalLineType.output,
            ),
          );
          break;
        case 'mesh':
          _addLine(
            TerminalLine(
              text: '''
╔════════════════════════════════════════════════════════════╗
║                    🦦 MESH NETWORK                          ║
╠════════════════════════════════════════════════════════════╣
║  Node ID           : ferret-node-7a3f                       ║
║  Active Nodes      : 42                                     ║
║  Connected Peers   : 8                                      ║
║  Latency           : 12ms avg                               ║
║  Throughput        : 150 Mbps                               ║
║  Protocol          : WebRTC + Yjs CRDT                      ║
║  Encryption        : End-to-end (Quantum)                   ║
╠════════════════════════════════════════════════════════════╣
║  🟢 Mesh Operational                                      ║
╚════════════════════════════════════════════════════════════╝

Connected Peers:
  ● node-alpha (US-East) - 8ms
  ● node-beta (EU-West) - 45ms
  ● node-gamma (Asia-Pac) - 120ms
  ● node-delta (SA-East) - 85ms
  ● node-epsilon (AF-Central) - 140ms
  ● node-zeta (NA-West) - 25ms
  ● node-eta (OC-Pacific) - 180ms
  ● node-theta (ME-Central) - 95ms''',
              type: TerminalLineType.output,
            ),
          );
          break;
        case 'network':
          _addLine(
            TerminalLine(
              text: '''
╔════════════════════════════════════════════════════════════╗
║                    🦦 NETWORK STATS                         ║
╠════════════════════════════════════════════════════════════╣
║  Upload Speed     : 45.2 Mbps ████████████████░░░░░░░░░░░░ ║
║  Download Speed   : 120.8 Mbps ████████████████████████████ ║
║  Latency          : 12ms                                    ║
║  Packet Loss      : 0.01%                                   ║
║  Jitter           : 2ms                                     ║
║  Network Type     : Quantum Mesh                            ║
║  Security Level   : Lattice-Based Encryption                 ║
╠════════════════════════════════════════════════════════════╣
║  🟢 Network Excellent                                      ║
╚════════════════════════════════════════════════════════════╝''',
              type: TerminalLineType.output,
            ),
          );
          break;
        default:
          _addLine(
            TerminalLine(
              text: "Unknown ferret command: ${args[0]}",
              type: TerminalLineType.error,
            ),
          );
      }
    }
  }

  void _executeExit() {
    Navigator.pop(context);
  }

  void _navigateHistoryUp() {
    if (_commandHistoryIndex > 0) {
      _commandHistoryIndex--;
      _textController.text = _commandHistory[_commandHistoryIndex];
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  void _navigateHistoryDown() {
    if (_commandHistoryIndex < _commandHistory.length - 1) {
      _commandHistoryIndex++;
      _textController.text = _commandHistory[_commandHistoryIndex];
    } else {
      _commandHistoryIndex = _commandHistory.length;
      _textController.clear();
    }
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.terminal, color: Color(0xFF39FF14)),
            SizedBox(width: 2.w),
            Text('FerretTerminal'),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.grey[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _executeClear,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value coming soon!')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Save Output',
                child: Text('Save Output'),
              ),
              const PopupMenuItem(
                value: 'Import Script',
                child: Text('Import Script'),
              ),
              const PopupMenuItem(
                value: 'Terminal Settings',
                child: Text('Terminal Settings'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFF0A0A0A),
      body: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Column(
          children: [
            // Terminal output
            Expanded(
              child: Container(
                padding: EdgeInsets.all(2.w),
                color: Color(0xFF0A0A0A),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _lines.length,
                  itemBuilder: (context, index) {
                    return _buildTerminalLine(_lines[index]);
                  },
                ),
              ),
            ),

            // Command input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Color(0xFF0A0A0A),
                border: Border(
                  top: BorderSide(color: Color(0xFF39FF14).withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    child: Text(
                      '$_currentDirectory >',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13.sp,
                        color: Color(0xFF39FF14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: GoogleFonts.robotoMono(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter command...',
                        hintStyle: GoogleFonts.robotoMono(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        _textController.clear();
                        _executeCommand(value);
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalLine(TerminalLine line) {
    TextStyle textStyle;
    Color? bgColor;

    switch (line.type) {
      case TerminalLineType.command:
        textStyle = GoogleFonts.robotoMono(
          fontSize: 13.sp,
          color: Color(0xFF39FF14),
        );
        break;
      case TerminalLineType.output:
        textStyle = GoogleFonts.robotoMono(
          fontSize: 13.sp,
          color: Colors.white,
        );
        break;
      case TerminalLineType.info:
        textStyle = GoogleFonts.robotoMono(
          fontSize: 13.sp,
          color: Color(0xFF00E5FF),
        );
        break;
      case TerminalLineType.error:
        textStyle = GoogleFonts.robotoMono(
          fontSize: 13.sp,
          color: Color(0xFFFF5252),
        );
        break;
      case TerminalLineType.system:
        textStyle = GoogleFonts.robotoMono(
          fontSize: 12.sp,
          color: Color(0xFFB388FF),
          height: 1.3,
        );
        bgColor = Color(0xFFB388FF).withValues(alpha: 0.05);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.3.h, horizontal: 1.w),
      decoration: bgColor != null
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(1.w),
            )
          : null,
      child: Text(
        line.text,
        style: textStyle,
        strutStyle: StrutStyle(
          forceStrutHeight: true,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Terminal line data class
class TerminalLine {
  final String text;
  final TerminalLineType type;

  TerminalLine({
    required this.text,
    this.type = TerminalLineType.output,
  });
}

/// Terminal line type enum
enum TerminalLineType {
  command,
  output,
  info,
  error,
  system,
}