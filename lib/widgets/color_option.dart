import 'package:flutter/material.dart';

class ColorOption extends StatelessWidget {
  final int color;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorOption({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(color),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

