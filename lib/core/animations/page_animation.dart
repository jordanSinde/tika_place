import 'package:flutter/material.dart';

class PageAnimations {
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }

  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }
}
