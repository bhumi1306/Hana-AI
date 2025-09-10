import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double radius;
  final List<Color> background; // gradient

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.radius = 40,
    this.background = const [Color(0xFFB39DDB), Color(0xFF8B5CF6)],
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late final AnimationController _borderCtrl; // sweeps border
  late final AnimationController _floatCtrl; // moves text + stars
  late final AnimationController _pressCtrl; // press bounce + fade
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _borderCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _floatCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    _opacity = Tween(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _borderCtrl.dispose();
    _floatCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.forward(),
          onTapCancel: () => _pressCtrl.reverse(),
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onPressed();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_borderCtrl, _floatCtrl]),
            builder: (context, _) {
              return CustomPaint(
                painter: _SweepBorderPainter(
                  progress: _borderCtrl.value,
                  radius: widget.radius,
                  glowColor: Colors.white,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.background),
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  child: _FloatingContent(
                    progress: _floatCtrl.value,
                    text: widget.text,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Text + sparkles move together
class _FloatingContent extends StatelessWidget {
  final double progress;
  final String text;
  const _FloatingContent({required this.progress, required this.text});

  @override
  Widget build(BuildContext context) {
    // gentle orbital motion
    final dx = math.sin(progress * 2 * math.pi) * 4; // ±4 px
    final dy = math.cos(progress * 2 * math.pi) * 1.5;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // sparkles bundle (moves WITH the text)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(
                angle: progress * 2 * math.pi,
                child: const Icon(Icons.auto_awesome,
                    size: 18, color: Colors.white),
              ),
              Positioned(
                left: -8,
                top: -6,
                child: Opacity(
                  opacity: 0.9,
                  child: Transform.rotate(
                    angle: -progress * 2 * math.pi,
                    child: const Icon(Icons.auto_awesome,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Border painter with a single glowing segment sweeping around the rounded rect.
class _SweepBorderPainter extends CustomPainter {
  final double progress; // 0..1
  final double radius;
  final Color glowColor;

  _SweepBorderPainter({
    required this.progress,
    required this.radius,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final length = metric.length;

    // Base subtle border
    final base = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, base);

    // Moving highlight segment (wraps around)
    final segmentLen = length * 0.22; // visible size of highlight
    final start = progress * length;
    final end = start + segmentLen;

    Paint glow = Paint()
      ..color = glowColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    Paint core = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    Path drawSegment(double a, double b) => metric.extractPath(a, b);

    if (end <= length) {
      final seg = drawSegment(start, end);
      canvas.drawPath(seg, glow);
      canvas.drawPath(seg, core);
    } else {
      // wrap-around: draw tail + head
      final seg1 = drawSegment(start, length);
      final seg2 = drawSegment(0, end - length);
      canvas.drawPath(seg1, glow);
      canvas.drawPath(seg1, core);
      canvas.drawPath(seg2, glow);
      canvas.drawPath(seg2, core);
    }
  }

  @override
  bool shouldRepaint(covariant _SweepBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.radius != radius ||
          oldDelegate.glowColor != glowColor;
}
