import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuTap;

  const HomeHeader({
    super.key,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.paddingHorizontal(context),
        vertical: Responsive.spacing(context, 12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nav icon di kiri
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onMenuTap,
              child: Image.asset(
                'assets/icons2/Nav.png',
                width: Responsive.iconSize(context, 24),
                height: Responsive.iconSize(context, 24),
              ),
            ),
          ),
          // Title "Daily tasks" di tengah (benar-benar tengah)
          Text(
            'Daily tasks',
            style: GoogleFonts.jost(
              fontSize: Responsive.fontSize(context, 20),
              color: const Color(0xFF9183DE), // Light purple
              fontWeight: FontWeight.w400, // Regular
            ),
          ),
        ],
      ),
    );
  }
}

