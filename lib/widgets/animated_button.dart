import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isEnabled;
  final String? tooltip;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handlePressStart() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _handlePressEnd() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _handleHoverEnter() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isHovered = true);
      _hoverController.forward();
    }
  }

  void _handleHoverExit() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.primaryPurple;
    final textColor = widget.textColor ?? Colors.white;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final padding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    return MouseRegion(
      onEnter: (_) => _handleHoverEnter(),
      onExit: (_) => _handleHoverExit(),
      child: GestureDetector(
        onTapDown: (_) => _handlePressStart(),
        onTapUp: (_) => _handlePressEnd(),
        onTapCancel: () => _handlePressEnd(),
        onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.isEnabled
                      ? backgroundColor
                      : backgroundColor.withValues(alpha: 0.5),
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.3),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isEnabled && !widget.isLoading
                        ? widget.onPressed
                        : null,
                    borderRadius: borderRadius,
                    child: Container(
                      padding: padding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  textColor,
                                ),
                              ),
                            ),
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: textColor, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }
}

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;
  final bool isLoading;
  final bool isEnabled;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 24,
    this.tooltip,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handlePressStart() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _handlePressEnd() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _handleHoverEnter() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isHovered = true);
      _hoverController.forward();
    }
  }

  void _handleHoverExit() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.surfaceVariant;
    final iconColor = widget.iconColor ?? AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => _handleHoverEnter(),
      onExit: (_) => _handleHoverExit(),
      child: GestureDetector(
        onTapDown: (_) => _handlePressStart(),
        onTapUp: (_) => _handlePressEnd(),
        onTapCancel: () => _handlePressEnd(),
        onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isEnabled
                        ? backgroundColor
                        : backgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: iconColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.isEnabled && !widget.isLoading
                          ? widget.onPressed
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: widget.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    iconColor,
                                  ),
                                ),
                              )
                            : Icon(
                                widget.icon,
                                color: iconColor,
                                size: widget.size,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool isEnabled;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.isEnabled = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleHoverEnter() {
    if (widget.isEnabled) {
      setState(() => _isHovered = true);
      _hoverController.forward();
    }
  }

  void _handleHoverExit() {
    if (widget.isEnabled) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  void _handlePressStart() {
    if (widget.isEnabled) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _handlePressEnd() {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.surface;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final padding = widget.padding ?? const EdgeInsets.all(16);

    return MouseRegion(
      onEnter: (_) => _handleHoverEnter(),
      onExit: (_) => _handleHoverExit(),
      child: GestureDetector(
        onTapDown: (_) => _handlePressStart(),
        onTapUp: (_) => _handlePressEnd(),
        onTapCancel: () => _handlePressEnd(),
        onTap: widget.isEnabled ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                  boxShadow:
                      widget.boxShadow ??
                      [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value / 2),
                        ),
                      ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isEnabled ? widget.onTap : null,
                    borderRadius: borderRadius,
                    child: Padding(padding: padding, child: widget.child),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }
}
