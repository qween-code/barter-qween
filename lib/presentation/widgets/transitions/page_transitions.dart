import 'package:flutter/material.dart';

/// Smooth page transition animations inspired by Trendyol, Spotify, Airbnb
class SmoothPageTransition extends PageRouteBuilder {
  final Widget child;
  final Curve curve;

  SmoothPageTransition({
    required this.child,
    this.curve = Curves.easeInOutCubic,
  }) : super(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

/// Fade page transition
class FadePageTransition extends PageRouteBuilder {
  final Widget child;

  FadePageTransition({required this.child})
      : super(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// Scale page transition
class ScalePageTransition extends PageRouteBuilder {
  final Widget child;

  ScalePageTransition({required this.child})
      : super(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// Rotation page transition
class RotationPageTransition extends PageRouteBuilder {
  final Widget child;

  RotationPageTransition({required this.child})
      : super(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);

      return RotationTransition(
        turns: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.5)),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    },
  );
}
