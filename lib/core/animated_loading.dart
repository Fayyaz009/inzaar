import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inzaar/core/animation_helper.dart';
import 'package:inzaar/core/animated_button.dart';

/// A customizable animated loading indicator with modern design
class AnimatedLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;
  final double? textSize;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const AnimatedLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.text,
    this.textSize,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              strokeWidth: 3,
            ),
          ),
          if (text != null) ...[
            const SizedBox(height: 16),
            Text(
              text!,
              style: TextStyle(
                color: textColor ?? theme.colorScheme.onSurfaceVariant,
                fontSize: textSize ?? 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A shimmer effect for loading content
class AnimatedShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const AnimatedShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerBaseColor = baseColor ?? theme.colorScheme.surface;
    final shimmerHighlightColor = highlightColor ??
        (theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.3));

    return Animate(
      effects: [
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: duration ?? const Duration(milliseconds: 800),
        ),
        SlideEffect(
          begin: const Offset(-1.0, 0.0),
          end: const Offset(1.0, 0.0),
          duration: duration ?? const Duration(milliseconds: 1200),
        ),
      ],
      child: Shimmer(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        duration: duration ?? const Duration(milliseconds: 1500),
        child: child,
      ),
    );
  }
}

/// A shimmer effect widget
class Shimmer extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final Widget child;

  const Shimmer({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: -1.0, end: 2.0),
      duration: duration,
      builder: (context, position, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(position, 0),
              end: Alignment(position - 1.0, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A skeleton loader for content
class AnimatedSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AnimatedSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 8,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: margin,
      padding: padding,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: const SizedBox.shrink(),
    ).animate().shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Colors.white.withValues(alpha: 0.6),
        );
  }
}

/// A list of skeleton loaders
class AnimatedSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double borderRadius;
  final double? itemWidth;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const AnimatedSkeletonList({
    super.key,
    required this.itemCount,
    this.itemHeight = 60,
    this.borderRadius = 8,
    this.itemWidth,
    this.spacing = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) => AnimatedSkeleton(
        height: itemHeight,
        width: itemWidth ?? double.infinity,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// A custom progress bar with animations
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final String? label;
  final double? labelSize;
  final Color? labelColor;
  final EdgeInsetsGeometry? padding;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.label,
    this.labelSize,
    this.labelColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barBackgroundColor = backgroundColor ??
        theme.colorScheme.outlineVariant.withValues(alpha: 0.2);
    final barProgressColor = progressColor ?? theme.colorScheme.primary;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                color: labelColor ?? theme.colorScheme.onSurfaceVariant,
                fontSize: labelSize ?? 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            height: height,
            decoration: BoxDecoration(
              color: barBackgroundColor,
              borderRadius: BorderRadius.circular(height),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(barProgressColor),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
}

/// A pulse animation for attention-grabbing elements
class AnimatedPulse extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Duration? duration;
  final int? repeats;

  const AnimatedPulse({
    super.key,
    required this.child,
    this.color,
    this.duration,
    this.repeats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pulseColor = color ?? theme.colorScheme.primary;

    return AnimationHelper.pulse(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: pulseColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: child,
      ),
      duration: duration ?? const Duration(milliseconds: 1000),
      maxScale: 1.1,
    );
  }
}

/// A floating action button with loading state
class AnimatedLoadingButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;

  const AnimatedLoadingButton({
    super.key,
    required this.isLoading,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedButton(
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: textColor ?? theme.colorScheme.onPrimary,
      borderRadius: 12,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            isLoading ? 'Loading...' : text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
