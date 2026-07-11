import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic container that adapts to both light and dark themes.
/// - In dark mode: translucent white overlay (classic glass effect).
/// - In light mode (useWhiteBlend=true): white fill with soft shadow for clarity.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? borderColor;
  final Color? fillColor;
  /// When true, fills with white to stand out on light backgrounds.
  final bool useWhiteBlend;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.07,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = const EdgeInsets.all(0.0),
    this.borderColor,
    this.fillColor,
    this.useWhiteBlend = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = fillColor ?? (useWhiteBlend ? Colors.white : Colors.white);
    final effectiveOpacity = useWhiteBlend ? 0.95 : opacity;
    final effectiveBorderColor = (borderColor ?? Colors.white).withValues(
      alpha: useWhiteBlend ? 0.35 : 0.15,
    );
    final shadowColor = useWhiteBlend ? Colors.black : Colors.black;
    final shadowOpacity = useWhiteBlend ? 0.07 : 0.14;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowOpacity),
            blurRadius: useWhiteBlend ? 12 : 20.0,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: useWhiteBlend ? 4 : blur,
            sigmaY: useWhiteBlend ? 4 : blur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  base.withValues(alpha: effectiveOpacity + 0.03),
                  base.withValues(alpha: effectiveOpacity - 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
