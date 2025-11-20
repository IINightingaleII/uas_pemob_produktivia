import 'package:flutter/material.dart';

// Custom page route with no transition for seamless icon positioning
class NoTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  NoTransitionRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}

