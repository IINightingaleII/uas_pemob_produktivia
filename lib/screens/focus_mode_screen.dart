import 'package:flutter/material.dart';
import '../widgets/real_time_clock.dart';
import '../widgets/music_player_widget.dart';
import '../models/task_model.dart';

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  static const Color primaryColor = Color(0xFF5A189A);
  static const Color accentColor = Color(0xFFF7B538);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Current Task',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(),
            const SizedBox(height: 40),

            /// ⏰ JAM ANALOG REAL TIME
            const Center(
              child: RealTimeClock(
                tasks: [], // ✅ FIX: sesuai constructor
              ),
            ),

            const SizedBox(height: 40),
            _buildDescription(),
            const SizedBox(height: 20),
            const MusicPlayerWidget(accentColor: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Study',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
              style: const TextStyle(
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Handpicked by Produktivia Team.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        SizedBox(height: 5),
        Text(
          'Just sit back, relax and do your task.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
