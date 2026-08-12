import 'package:flutter/material.dart';

/// Material 风格的脉冲播放按钮：
/// 中心播放图标 + 一个不断扩散淡出的涟漪光环，吸引用户点击。
class PulsePlayButton extends StatefulWidget {
  const PulsePlayButton({
    super.key,
    required this.onTap,
    this.size = 60,
    this.color,
  });

  final VoidCallback onTap;
  final double size;
  final Color? color;

  @override
  State<PulsePlayButton> createState() => _PulsePlayButtonState();
}

class _PulsePlayButtonState extends State<PulsePlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Colors.white;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double t = _controller.value;
          // 光环：从小扩散到大并淡出
          return SizedBox(
            width: widget.size * 2,
            height: widget.size * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 第一道光环
                _halo(t),
                // 第二道光环（错开相位，更连续）
                _halo((t + 0.5) % 1.0),
                child!,
              ],
            ),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.black.withOpacity(0.8),
            size: widget.size * 0.62,
          ),
        ),
      ),
    );
  }

  Widget _halo(double t) {
    const radius = 1.0;
    // 从按钮圆向外扩散
    final double scale = radius + t * 1.6;
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: (1 - t) * 0.5,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}