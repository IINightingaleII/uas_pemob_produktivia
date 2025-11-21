import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../services/dummy_auth_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'focus_mode_screen.dart';
import 'history_screen.dart';
import 'leaderboards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dummy data untuk activities
  final List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'have dinner',
      time: '20:00',
      color: 0xFFFFB6C1, // Light pink
      isCompleted: false,
    ),
    TaskModel(
      id: '2',
      title: 'wake up',
      time: '7:00',
      color: 0xFF90EE90, // Light green
      isCompleted: false,
    ),
    TaskModel(
      id: '3',
      title: 'study',
      time: '9:00',
      color: 0xFFFFA500, // Light orange
      isCompleted: false,
    ),
    TaskModel(
      id: '4',
      title: 'Shopping',
      time: '12:30',
      color: 0xFFFFFFE0, // Light yellow
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = DummyAuthService();
    final currentUser = authService.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(currentUser),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(),
            // Clock Widget
            _buildClockWidget(),
            // Activities Section
            Expanded(
              child: _buildActivitiesSection(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder untuk add task (nanti)
        },
        backgroundColor: Colors.grey.shade300,
        child: const Icon(
          Icons.add,
          color: Color(0xFF9183DE), // Purple
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Nav icon di kiri
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Image.asset(
              'assets/icons2/Nav.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
          // Title "Daily tasks" di tengah
          Expanded(
            child: Center(
              child: Text(
                'Daily tasks',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: const Color(0xFF9183DE), // Light purple
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockWidget() {
    final hour = _currentTime.hour % 12;
    final minute = _currentTime.minute;
    final hourAngle = (hour * 30 + minute * 0.5) * (3.14159 / 180); // Convert to radians
    final minuteAngle = minute * 6 * (3.14159 / 180); // Convert to radians

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFB6C1), // Light pink
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Clock face
            Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: ClockPainter(
                    hourAngle: hourAngle,
                    minuteAngle: minuteAngle,
                  ),
                ),
              ),
            ),
            // Time display real-time di pojok kiri atas (posisi yang di-highlight merah)
            Positioned(
              top: 12,
              left: 12,
              child: Text(
                _formatTime(_currentTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Time display "20:00" di pojok kanan atas
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1), // Light pink
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '20:00',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header "Activities" dan "today"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'today',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        // Activities List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return _buildActivityItem(task, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(TaskModel task, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleTask(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(task.color),
                  width: 2,
                ),
                color: task.isCompleted ? Color(task.color) : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Activity name dalam colored rounded rectangle
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(task.color),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Time display
          Text(
            task.time,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(dynamic currentUser) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Header dengan back arrow
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                // Display name
                Text(
                  'Hello ${currentUser?.displayName ?? 'Produktivia'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  currentUser?.email ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: 'assets/icons2/edit.png',
                  title: 'Edit profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: 'assets/icons2/home-dailytask.png',
                  title: 'Daily tasks',
                  onTap: () {
                    Navigator.pop(context);
                    // Already on home screen
                  },
                ),
                _buildDrawerItem(
                  icon: 'assets/icons2/Focus-mode-star.png',
                  title: 'Focus Mode',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FocusModeScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: 'assets/icons2/history.png',
                  title: 'History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: 'assets/icons2/Leaderboards.png',
                  title: 'Leaderboards',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(
        icon,
        width: 24,
        height: 24,
        color: Colors.grey,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Custom Painter untuk Clock
class ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;

  ClockPainter({
    required this.hourAngle,
    required this.minuteAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw highlighted segment (pink arc dari 12 ke 2)
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFB6C1) // Light pink
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx, center.dy - radius)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // -90 degrees in radians (12 o'clock)
        math.pi / 3, // 60 degrees in radians (2 o'clock)
        false,
      )
      ..close();
    canvas.drawPath(highlightPath, highlightPaint);

    // Draw clock numbers 1-12
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * (math.pi / 180); // Convert to radians
      final x = center.dx + (radius - 20) * math.cos(angle);
      final y = center.dy + (radius - 20) * math.sin(angle);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw minute hand (long hand)
    final minuteHandPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final minuteHandLength = radius * 0.7;
    final minuteHandEndX = center.dx + minuteHandLength * math.sin(minuteAngle);
    final minuteHandEndY = center.dy - minuteHandLength * math.cos(minuteAngle);
    canvas.drawLine(
      center,
      Offset(minuteHandEndX, minuteHandEndY),
      minuteHandPaint,
    );

    // Draw hour hand (short hand)
    final hourHandPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final hourHandLength = radius * 0.5;
    final hourHandEndX = center.dx + hourHandLength * math.sin(hourAngle);
    final hourHandEndY = center.dy - hourHandLength * math.cos(hourAngle);
    canvas.drawLine(
      center,
      Offset(hourHandEndX, hourHandEndY),
      hourHandPaint,
    );

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return oldDelegate.hourAngle != hourAngle ||
        oldDelegate.minuteAngle != minuteAngle;
  }
}
