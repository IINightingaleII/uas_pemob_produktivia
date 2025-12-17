import 'package:flutter/material.dart';

class MusicPlayerWidget extends StatefulWidget {
  final Color accentColor;

  const MusicPlayerWidget({super.key, required this.accentColor});

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  bool _isPlaying = false;
  int _currentTrackIndex = 0;

  final List<String> _tracks = [
    'Loafy Building - Glistening',
    'Focus Beats - Chill Study',
    'Lofi Vibes - Calm Night',
  ];

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _nextTrack() {
    setState(() {
      _currentTrackIndex =
          (_currentTrackIndex + 1) % _tracks.length;
      _isPlaying = true; // otomatis play
    });
  }

  void _previousTrack() {
    setState(() {
      _currentTrackIndex =
          (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cover / artwork
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.music_note,
              size: 50,
              color: widget.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Track title
        Text(
          _tracks[_currentTrackIndex],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 36,
              color: Colors.white,
              icon: const Icon(Icons.skip_previous),
              onPressed: _previousTrack,
            ),
            const SizedBox(width: 20),
            IconButton(
              iconSize: 48,
              color: Colors.white,
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              onPressed: _togglePlay,
            ),
            const SizedBox(width: 20),
            IconButton(
              iconSize: 36,
              color: Colors.white,
              icon: const Icon(Icons.skip_next),
              onPressed: _nextTrack,
            ),
          ],
        ),
      ],
    );
  }
}
