import 'package:flutter/material.dart';
import '../widgets/real_time_clock.dart';
import '../widgets/music_player_widget.dart';
import '../models/task_model.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusModeScreen extends StatelessWidget {
  final TaskModel? task;

  const FocusModeScreen({super.key, this.task});

  static const Color defaultPrimaryColor = Color(0xFF5A189A);
  static const Color defaultAccentColor = Color(0xFFF7B538);

  @override
  Widget build(BuildContext context) {
    // Use task color if available, otherwise default
    // Note: TaskModel.color is an int (0xFF...), we might need to process it
    final Color backgroundColor = task != null 
        ? Color(task!.color).withOpacity(0.9) // Slightly darker for background
        : defaultPrimaryColor;
        
    final Color accentColor = defaultAccentColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Current Task',
          style: GoogleFonts.jost(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(accentColor),
            const SizedBox(height: 40),

            /// ⏰ JAM ANALOG REAL TIME
            Center(
              child: RealTimeClock(
                tasks: task != null ? [task!] : [], 
              ),
            ),

            const SizedBox(height: 40),
            _buildDescription(),
            const SizedBox(height: 20),
            MusicPlayerWidget(accentColor: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            task?.title ?? 'General Focus',
            style: GoogleFonts.jost(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder<DateTime>(
          stream: Stream.periodic(
            const Duration(seconds: 1),
            (_) => DateTime.now(),
          ),
          builder: (_, snapshot) {
            final now = snapshot.data ?? DateTime.now();
            final time =
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

            return Text(
              time,
              style: GoogleFonts.jost(
                color: accentColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Handpicked by Produktivia Team.',
          style: GoogleFonts.jost(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          'Just sit back, relax and do your task.',
          style: GoogleFonts.jost(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
