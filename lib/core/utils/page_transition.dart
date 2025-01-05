import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTransitions {
  static const Duration duration = Duration(milliseconds: 300);

  static Page<dynamic> Function(
    BuildContext,
    GoRouterState,
    Widget,
  ) slideTransition = (context, state, child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  };

  static Page<dynamic> Function(
    BuildContext,
    GoRouterState,
    Widget,
  ) fadeTransition = (context, state, child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  };

  static Page<dynamic> Function(
    BuildContext,
    GoRouterState,
    Widget,
  ) scaleTransition = (context, state, child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  };
}
