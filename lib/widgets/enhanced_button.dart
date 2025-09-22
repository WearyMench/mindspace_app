import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool fullWidth;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.fullWidth = false,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
      _rippleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final colors = _getButtonColors(theme, isEnabled);
    final dimensions = _getButtonDimensions();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: dimensions.height,
              padding: widget.padding ?? dimensions.padding,
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? dimensions.borderRadius,
                ),
                border: widget.type == ButtonType.outline
                    ? Border.all(color: colors.borderColor, width: 1.5)
                    : null,
                boxShadow: widget.type == ButtonType.primary
                    ? [
                        BoxShadow(
                          color: colors.backgroundColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Ripple effect
                  if (_rippleAnimation.value > 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? dimensions.borderRadius,
                          ),
                          color: colors.rippleColor.withOpacity(
                            (1 - _rippleAnimation.value) * 0.3,
                          ),
                        ),
                      ),
                    ),

                  // Button content
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: dimensions.iconSize,
                            color: colors.textColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: dimensions.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }

  ButtonColors _getButtonColors(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return ButtonColors(
        backgroundColor: theme.colorScheme.surfaceVariant,
        textColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        borderColor: theme.colorScheme.outline.withOpacity(0.3),
        rippleColor: theme.colorScheme.onSurfaceVariant,
      );
    }

    switch (widget.type) {
      case ButtonType.primary:
        return ButtonColors(
          backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
          textColor: widget.textColor ?? theme.colorScheme.onPrimary,
          borderColor: Colors.transparent,
          rippleColor: theme.colorScheme.onPrimary,
        );
      case ButtonType.secondary:
        return ButtonColors(
          backgroundColor: theme.colorScheme.secondary,
          textColor: theme.colorScheme.onSecondary,
          borderColor: Colors.transparent,
          rippleColor: theme.colorScheme.onSecondary,
        );
      case ButtonType.outline:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: widget.textColor ?? theme.colorScheme.primary,
          borderColor: theme.colorScheme.primary,
          rippleColor: theme.colorScheme.primary,
        );
      case ButtonType.text:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: widget.textColor ?? theme.colorScheme.primary,
          borderColor: Colors.transparent,
          rippleColor: theme.colorScheme.primary,
        );
    }
  }

  ButtonDimensions _getButtonDimensions() {
    switch (widget.size) {
      case ButtonSize.small:
        return ButtonDimensions(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: 16,
          fontSize: 12,
          iconSize: 14,
        );
      case ButtonSize.medium:
        return ButtonDimensions(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 20,
          fontSize: 14,
          iconSize: 16,
        );
      case ButtonSize.large:
        return ButtonDimensions(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          borderRadius: 24,
          fontSize: 16,
          iconSize: 20,
        );
    }
  }
}

class ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color rippleColor;

  ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.rippleColor,
  });
}

class ButtonDimensions {
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final double iconSize;

  ButtonDimensions({
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
    required this.iconSize,
  });
}

enum ButtonType { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }
