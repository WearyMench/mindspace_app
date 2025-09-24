import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double? borderRadius;
  final double? elevation;
  final BoxShadow? shadow;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradientColors,
    this.borderRadius,
    this.elevation,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: (gradientColors != null && !isLight)
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        color: (isLight || gradientColors == null)
            ? (backgroundColor ?? Theme.of(context).colorScheme.surface)
            : null,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: isLight
            ? Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
                width: 1,
              )
            : null,
        boxShadow: !isLight
            ? [
                shadow ??
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: elevation ?? 8,
                      offset: const Offset(0, 2),
                    ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
