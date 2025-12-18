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
  double _sliderValue = 0.3; // Dummy progress

  final List<String> _tracks = [
    'Loafy Building - Glistening',
    'Focus Beats - Chill Study',
    'Lofi Vibes - Calm Night',
  ];

  final List<String> _artists = [
    'David Manson - The ways to live',
    'Chill Guy - Relaxing',
    'Lofi Girl - Studying',
  ];

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _nextTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
      _isPlaying = true;
      _sliderValue = 0.0;
    });
  }

  void _previousTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
      _isPlaying = true;
      _sliderValue = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track Info Rows
        _buildTrackInfoRow("Playing now", _tracks[_currentTrackIndex], Colors.white70, Colors.white),
        const SizedBox(height: 8),
        _buildTrackInfoRow("Playing next", _artists[_currentTrackIndex], Colors.white38, Colors.white70),
        
        const SizedBox(height: 12),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.accentColor,
            inactiveTrackColor: Colors.white24,
            thumbColor: widget.accentColor,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
          ),
          child: Slider(
            value: _sliderValue,
            onChanged: (value) {
              setState(() {
                 _sliderValue = value;
              });
            },
          ),
        ),
        
        // Time
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "00:00",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        
        const SizedBox(height: 10),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 32,
              color: widget.accentColor,
              icon: const Icon(Icons.skip_previous),
              onPressed: _previousTrack,
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 24),
             IconButton(
              iconSize: 32,
              color: widget.accentColor,
              icon: const Icon(Icons.skip_next),
              onPressed: _nextTrack,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackInfoRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
