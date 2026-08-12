import 'package:flutter/material.dart';

/// Material Design 风格的按压反馈：
/// 按下时卡片轻微缩小、上浮现阴影，松开后回弹（弹簧动画）。
/// 模仿 Google 系应用（YouTube / Play Store）的触感。
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.shadow,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BoxShadow? shadow;
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isDown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down() {
    _isDown = true;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _up({required bool tap}) {
    if (!_isDown) return;
    _isDown = false;
    _controller.reverse();
    if (tap) widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(tap: true),
      onTapCancel: () => _up(tap: false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 按下时缩小 + 轻微上浮 + 阴影增强
          final double t = Curves.easeOut.transform(_controller.value);
          final double scale = 1.0 - (1.0 - widget.scale) * t;
          return Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: widget.shadow == null
                    ? null
                    : [
                        widget.shadow!.copyWith(
                          offset: Offset(widget.shadow!.offset.dx,
                              widget.shadow!.offset.dy * (1 + t)),
                          blurRadius:
                              widget.shadow!.blurRadius * (1 + t * 2),
                        ),
                      ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}