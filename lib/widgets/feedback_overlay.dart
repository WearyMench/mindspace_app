import 'package:flutter/material.dart';

class FeedbackOverlay extends StatefulWidget {
  final Widget child;
  final String? message;
  final FeedbackType type;
  final Duration duration;
  final VoidCallback? onDismiss;

  const FeedbackOverlay({
    super.key,
    required this.child,
    this.message,
    this.type = FeedbackType.success,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    if (widget.message != null) {
      _showFeedback();
    }
  }

  @override
  void didUpdateWidget(FeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != null && widget.message != oldWidget.message) {
      _showFeedback();
    }
  }

  void _showFeedback() {
    if (!mounted) {
      return;
      ;
    }

    setState(() => _isVisible = true);
    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _hideFeedback();
      }
    });
  }

  void _hideFeedback() {
    if (!mounted) {
      return;
      ;
    }

    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible && widget.message != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 16,
            right: 16,
            child: _buildFeedbackCard(),
          ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    final colors = _getFeedbackColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(colors.icon, color: colors.iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message!,
              style: TextStyle(
                color: colors.textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: _hideFeedback,
            child: Icon(
              Icons.close,
              color: colors.textColor.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  FeedbackColors _getFeedbackColors() {
    switch (widget.type) {
      case FeedbackType.success:
        return FeedbackColors(
          backgroundColor: Colors.green.shade50,
          textColor: Colors.green.shade800,
          iconColor: Colors.green.shade600,
          borderColor: Colors.green.shade200,
          icon: Icons.check_circle,
        );
      case FeedbackType.error:
        return FeedbackColors(
          backgroundColor: Colors.red.shade50,
          textColor: Colors.red.shade800,
          iconColor: Colors.red.shade600,
          borderColor: Colors.red.shade200,
          icon: Icons.error,
        );
      case FeedbackType.warning:
        return FeedbackColors(
          backgroundColor: Colors.orange.shade50,
          textColor: Colors.orange.shade800,
          iconColor: Colors.orange.shade600,
          borderColor: Colors.orange.shade200,
          icon: Icons.warning,
        );
      case FeedbackType.info:
        return FeedbackColors(
          backgroundColor: Colors.blue.shade50,
          textColor: Colors.blue.shade800,
          iconColor: Colors.blue.shade600,
          borderColor: Colors.blue.shade200,
          icon: Icons.info,
        );
    }
  }
}

class FeedbackColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;
  final IconData icon;

  FeedbackColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.borderColor,
    required this.icon,
  });
}

enum FeedbackType { success, error, warning, info }

// Widget helper para mostrar feedback fácilmente
class FeedbackHelper {
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFeedback(
      context,
      message: message,
      type: FeedbackType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showFeedback(
      context,
      message: message,
      type: FeedbackType.error,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFeedback(
      context,
      message: message,
      type: FeedbackType.warning,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFeedback(
      context,
      message: message,
      type: FeedbackType.info,
      duration: duration,
    );
  }

  static void _showFeedback(
    BuildContext context, {
    required String message,
    required FeedbackType type,
    required Duration duration,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: FeedbackOverlay(
          message: message,
          type: type,
          duration: duration,
          child: Container(),
        ),
      ),
    );
  }
}
