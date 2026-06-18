import 'package:flutter/material.dart';

/// Minimal, dependency-free shimmer placeholder used for loading states.
class Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const Shimmer({Key? key, this.width = double.infinity, this.height = 12, this.borderRadius}) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade200;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.grey.shade100;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, child) {
          return ShaderMask(
            shaderCallback: (rect) {
              final double w = rect.width;
              final double slide = (w * 2) * _ctrl.value - w;
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [base, highlight, base],
                stops: const [0.0, 0.5, 1.0],
                transform: _SlidingGradientTransform(slide),
              ).createShader(Rect.fromLTWH(0, 0, w, rect.height));
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              decoration: BoxDecoration(
                color: base,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slide;
  const _SlidingGradientTransform(this.slide);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slide, 0.0, 0.0);
  }
}

/// Small helper to render multiple shimmer rows (useful for lists)
class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final double spacing;
  const ShimmerList({Key? key, this.count = 5, this.itemHeight = 78, this.spacing = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) => Padding(
        padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : spacing),
        child: Shimmer(height: itemHeight, borderRadius: BorderRadius.circular(12)),
      )),
    );
  }
}
