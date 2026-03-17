import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A utility class for consistent animations across the Inzaar app
class AnimationHelper {
  /// Page transition animations
  static PageRouteBuilder pageTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Scale in animation for buttons and interactive elements
  static Animate scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 250),
    double beginScale = 0.9,
    double endScale = 1.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    return child.animate().scale(
          begin: Offset(beginScale, beginScale),
          end: Offset(endScale, endScale),
          duration: duration,
          curve: curve,
        );
  }

  /// Fade in with slide animation for list items
  static Animate fadeInWithSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double slideOffset = 0.1,
    Curve curve = Curves.easeOutCubic,
  }) {
    return child.animate().fadeIn(duration: duration).slideY(
          begin: slideOffset,
          end: 0.0,
          curve: curve,
        );
  }

  /// Bounce animation for buttons on tap
  static Animate bounceOnTap({
    required Widget child,
    Duration duration = const Duration(milliseconds: 150),
    double bounceScale = 0.95,
  }) {
    return child.animate().scale(
          begin: const Offset(1.0, 1.0),
          end: Offset(bounceScale, bounceScale),
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  /// Pulse animation for loading indicators and highlights
  static Animate pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double maxScale = 1.05,
  }) {
    return child.animate().scale(
          begin: const Offset(1.0, 1.0),
          end: Offset(maxScale, maxScale),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  /// Shake animation for error states
  static Animate shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return child.animate().shake(
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  /// Slide up animation for bottom sheets and modals
  static Animate slideUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double slideOffset = 0.3,
  }) {
    return child.animate().slideY(
          begin: slideOffset,
          end: 0.0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  /// Fade in with rotation for special elements
  static Animate fadeInWithRotation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double rotation = 0.05,
  }) {
    return child.animate().fadeIn(duration: duration).rotate(
          begin: rotation,
          end: 0.0,
          duration: duration,
          curve: Curves.easeOutBack,
        );
  }

  /// Staggered animation for multiple elements
  static List<Widget> staggeredAnimation({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 300),
    double delayFactor = 0.1,
    double slideOffset = 0.1,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;

      return child
          .animate()
          .fadeIn(
            duration: duration,
            delay:
                Duration(milliseconds: (index * (delayFactor * 100)).toInt()),
          )
          .slideY(
            begin: slideOffset,
            end: 0.0,
            duration: duration,
            curve: Curves.easeOutCubic,
          );
    }).toList();
  }

  /// Ripple effect animation
  static Animate ripple({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    double maxScale = 1.5,
  }) {
    return child
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: Offset(maxScale, maxScale),
          duration: duration,
          curve: Curves.easeOutExpo,
        )
        .fade(
          begin: 1.0,
          end: 0.0,
          duration: duration,
          curve: Curves.easeOutExpo,
        );
  }

  /// Color transition animation
  static Animate colorTransition({
    required Widget child,
    required Color fromColor,
    required Color toColor,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return child.animate().color(
          begin: fromColor,
          end: toColor,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}
