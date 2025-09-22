import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class MicroInteractionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isEnabled;
  final bool showShimmer;
  final Duration shimmerDuration;

  const MicroInteractionCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.isEnabled = true,
    this.showShimmer = false,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<MicroInteractionCard> createState() => _MicroInteractionCardState();
}

class _MicroInteractionCardState extends State<MicroInteractionCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shimmerAnimation;

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
    _shimmerController = AnimationController(
      duration: widget.shimmerDuration,
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

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? AppColors.surface,
      end: (widget.backgroundColor ?? AppColors.surface).withOpacity(0.95),
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _shimmerController.dispose();
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
            onLongPress: widget.isEnabled ? widget.onLongPress : null,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _elevationAnimation,
                _colorAnimation,
                _shimmerAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorAnimation.value,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value / 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.isEnabled ? widget.onTap : null,
                        onLongPress: widget.isEnabled
                            ? widget.onLongPress
                            : null,
                        borderRadius: borderRadius,
                        child: Stack(
                          children: [
                            Padding(padding: padding, child: widget.child),
                            if (widget.showShimmer)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: borderRadius,
                                  child: AnimatedBuilder(
                                    animation: _shimmerAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                            stops: [
                                              _shimmerAnimation.value - 0.3,
                                              _shimmerAnimation.value,
                                              _shimmerAnimation.value + 0.3,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, duration: 300.ms)
        .shimmer(duration: 1000.ms, delay: 200.ms);
  }
}

class MicroInteractionButton extends StatefulWidget {
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

  const MicroInteractionButton({
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
  State<MicroInteractionButton> createState() => _MicroInteractionButtonState();
}

class _MicroInteractionButtonState extends State<MicroInteractionButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rippleAnimation;

  bool _isPressed = false;
  bool _isHovered = false;
  Offset? _rippleCenter;

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
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handlePressStart(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() {
        _isPressed = true;
        _rippleCenter = details.localPosition;
      });
      _pressController.forward();
      _rippleController.forward();
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
            onTapDown: _handlePressStart,
            onTapUp: (_) => _handlePressEnd(),
            onTapCancel: () => _handlePressEnd(),
            onTap: widget.isEnabled && !widget.isLoading
                ? widget.onPressed
                : null,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _elevationAnimation,
                _rippleAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.isEnabled
                          ? backgroundColor
                          : backgroundColor.withOpacity(0.5),
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.3),
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
                        child: Stack(
                          children: [
                            Padding(
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              textColor,
                                            ),
                                      ),
                                    )
                                  else if (widget.icon != null) ...[
                                    Icon(
                                      widget.icon,
                                      color: textColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_rippleCenter != null)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: borderRadius,
                                  child: AnimatedBuilder(
                                    animation: _rippleAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: RipplePainter(
                                          center: _rippleCenter!,
                                          progress: _rippleAnimation.value,
                                          color: textColor.withOpacity(0.3),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, duration: 300.ms)
        .shimmer(duration: 1000.ms, delay: 200.ms);
  }
}

class RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;
  final Color color;

  RipplePainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final radius = progress * size.width;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MicroInteractionSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;
  final bool isEnabled;

  const MicroInteractionSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.label,
    this.isEnabled = true,
  });

  @override
  State<MicroInteractionSwitch> createState() => _MicroInteractionSwitchState();
}

class _MicroInteractionSwitchState extends State<MicroInteractionSwitch>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MicroInteractionSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primaryPurple;
    final inactiveColor = widget.inactiveColor ?? AppColors.surfaceVariant;

    return GestureDetector(
          onTap: widget.isEnabled
              ? () => widget.onChanged?.call(!widget.value)
              : null,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    inactiveColor,
                    activeColor,
                    _animation.value,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: _animation.value * 20,
                      top: 2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 300.ms);
  }
}
