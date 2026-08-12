import 'package:flutter/material.dart';

/// 列表项逐条渐入动画（谷歌 Material List 风格）
/// 当列表首次加载时，子项依次从底部滑入 + 淡入，产生自然的"浮现"感。
/// 使用 [index] 控制延迟，保证先进先出的错落节奏。
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.offset = 20,
    this.curve = Curves.easeOutCubic,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final double offset;
  final Curve curve;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    // 每条错开 50ms，最多 300ms 的总延迟
    final delay = Duration(milliseconds: (widget.index * 50).clamp(0, 300));
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}