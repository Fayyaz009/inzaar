import 'package:flutter/material.dart';
import 'package:inzaar/core/animation_helper.dart';

/// A customizable animated button with smooth micro-interactions
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool disabled;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final Widget? loadingWidget;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isLoading = false,
    this.disabled = false,
    this.animationDuration,
    this.animationCurve,
    this.loadingWidget,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.disabled && !widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _controller.forward() : null,
        onTapUp: isEnabled
            ? (_) => Future.delayed(
                  const Duration(milliseconds: 100),
                  () => _controller.reverse(),
                )
            : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        onTap: isEnabled ? widget.onPressed : null,
        onLongPress: isEnabled ? widget.onLongPress : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    (isEnabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                boxShadow: widget.elevation != 0
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
                border: Border.all(
                  color: isEnabled
                      ? Colors.transparent
                      : theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Center(
                child: widget.isLoading
                    ? (widget.loadingWidget ??
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.foregroundColor ??
                                (widget.backgroundColor == null
                                    ? theme.colorScheme.onPrimary
                                    : null),
                          ),
                        ))
                    : DefaultTextStyle(
                        style: TextStyle(
                          color: widget.foregroundColor ??
                              (widget.backgroundColor == null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onPrimary),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        child: widget.child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A floating action button with enhanced animations
class AnimatedFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;
  final bool isLoading;
  final String? tooltip;

  const AnimatedFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimationHelper.scaleIn(
      child: FloatingActionButton(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        elevation: 8,
        highlightElevation: 0,
        tooltip: tooltip,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor ?? theme.colorScheme.onPrimary,
                ),
              )
            : child,
      ),
      duration: const Duration(milliseconds: 250),
      beginScale: 0.8,
      endScale: 1.0,
    );
  }
}

/// A toggle button with smooth animations
class AnimatedToggleButton extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  final VoidCallback? onPressed;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedToggleButton({
    super.key,
    required this.isSelected,
    required this.child,
    this.onPressed,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimationHelper.scaleIn(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (selectedColor ??
                    theme.colorScheme.primary.withValues(alpha: 0.12))
                : (unselectedColor ?? theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            border: Border.all(
              color: borderColor ??
                  (isSelected
                      ? (selectedColor ?? theme.colorScheme.primary)
                      : theme.colorScheme.outlineVariant),
              width: 2,
            ),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: isSelected
                    ? (selectedColor ?? theme.colorScheme.primary)
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              child: child,
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 200),
      beginScale: 0.9,
      endScale: 1.0,
    );
  }
}

/// A card with hover-like effects for mobile
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool disabled;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius,
    this.margin,
    this.padding,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !disabled;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      onLongPress: isEnabled ? onLongPress : null,
      child: AnimationHelper.scaleIn(
        child: Container(
          margin: margin,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? theme.cardColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
        duration: const Duration(milliseconds: 250),
        beginScale: 0.95,
        endScale: 1.0,
      ),
    );
  }
}
