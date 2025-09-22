import 'package:flutter/material.dart';

class EnhancedLoadingWidget extends StatefulWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double? size;

  const EnhancedLoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.color,
    this.size,
  });

  @override
  State<EnhancedLoadingWidget> createState() => _EnhancedLoadingWidgetState();
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final size = widget.size ?? 40.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(color, size),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(Color color, double size) {
    switch (widget.type) {
      case LoadingType.circular:
        return _buildCircularLoading(color, size);
      case LoadingType.dots:
        return _buildDotsLoading(color, size);
      case LoadingType.pulse:
        return _buildPulseLoading(color, size);
      case LoadingType.wave:
        return _buildWaveLoading(color, size);
    }
  }

  Widget _buildCircularLoading(Color color, double size) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 3),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsLoading(Color color, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = (1.0 - (animationValue - 0.5).abs() * 2).clamp(
              0.3,
              1.0,
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size / 4,
                  height: size / 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulseLoading(Color color, double size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveLoading(Color color, double size) {
    return SizedBox(
      width: size,
      height: size / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = (_controller.value - delay).clamp(
                0.0,
                1.0,
              );
              final height =
                  (0.3 + 0.7 * (1.0 - (animationValue - 0.5).abs() * 2)).clamp(
                    0.3,
                    1.0,
                  );

              return Container(
                width: size / 12,
                height: (size / 3) * height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(size / 24),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

enum LoadingType { circular, dots, pulse, wave }

// Widget de carga con overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final LoadingType loadingType;
  final Color? loadingColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.loadingType = LoadingType.circular,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: EnhancedLoadingWidget(
                  message: loadingMessage,
                  type: loadingType,
                  color: loadingColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget de carga con shimmer effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final baseColor =
        widget.baseColor ??
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3);
    final highlightColor =
        widget.highlightColor ??
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
