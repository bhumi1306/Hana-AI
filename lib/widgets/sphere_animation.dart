// file: widgets/flowing_liquid_orb.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// A reusable liquid-like orb widget with flowing multi-color blobs
/// and edge bubbles. Put text in the center via `text`.
class FlowingLiquidOrb extends StatefulWidget {
  final String text;
  final double size;
  final List<Color> palette;
  final int blobCount;
  final int bubbleCount;
  final Duration duration;

  const FlowingLiquidOrb({
    super.key,
    required this.text,
    this.size = 260,
    this.palette = const [
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
      Color(0xFF60A5FA),
      Color(0xFFC084FC),
      Color(0xFFFB7185),
    ],
    this.blobCount = 6,
    this.bubbleCount = 28,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<FlowingLiquidOrb> createState() => _FlowingLiquidOrbState();
}

class _FlowingLiquidOrbState extends State<FlowingLiquidOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rand = Random();
  late final List<_Blob> _blobs;
  late final List<_EdgeBubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    // create blobs (soft, blurred color lights that flow inside the orb)
    _blobs = List.generate(widget.blobCount, (i) {
      final color = widget.palette[i % widget.palette.length];
      final base = Offset(
        0.5 + (_rand.nextDouble() - 0.5) * 0.26, // slightly off-center
        0.5 + (_rand.nextDouble() - 0.5) * 0.26,
      );
      return _Blob(
        color: color,
        base: base,
        amp1: Offset(0.20 + _rand.nextDouble() * 0.18, 0.20 + _rand.nextDouble() * 0.18),
        amp2: Offset(0.08 + _rand.nextDouble() * 0.12, 0.08 + _rand.nextDouble() * 0.12),
        rFrac: 0.20 + _rand.nextDouble() * 0.38,
        phase1: _rand.nextDouble() * 2 * pi,
        phase2: _rand.nextDouble() * 2 * pi,
        freq1: 0.4 + _rand.nextDouble() * 1.1,
        freq2: 0.7 + _rand.nextDouble() * 1.3,
        opacity: 0.45 + _rand.nextDouble() * 0.35,
      );
    });

    // create edge bubbles (they pulse/fade)
    _bubbles = List.generate(widget.bubbleCount, (i) {
      return _EdgeBubble(
        angle: _rand.nextDouble() * 2 * pi,
        baseRadiusFrac: 0.48 + _rand.nextDouble() * 0.04,
        minSize: 2.5 + _rand.nextDouble() * 3.0,
        maxSize: 7.0 + _rand.nextDouble() * 7.0,
        phase: _rand.nextDouble() * 2 * pi,
        freq: 0.5 + _rand.nextDouble() * 1.4,
        drift: (_rand.nextDouble() - 0.5) * 0.18,
        alphaBase: 0.08 + _rand.nextDouble() * 0.28,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            size: Size(s, s),
            painter: _LiquidOrbPainter(
              t: _ctrl.value,
              blobs: _blobs,
              bubbles: _bubbles,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(s * 0.12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(blurRadius: 18, color: Colors.black26, offset: Offset(0, 3))
                      ],
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Models ----------------

class _Blob {
  _Blob({
    required this.color,
    required this.base,
    required this.amp1,
    required this.amp2,
    required this.rFrac,
    required this.phase1,
    required this.phase2,
    required this.freq1,
    required this.freq2,
    required this.opacity,
  });

  final Color color;
  final Offset base; // normalized center (0..1)
  final Offset amp1; // primary amplitude
  final Offset amp2; // secondary smaller amplitude
  final double rFrac; // blob visual radius fraction
  final double phase1;
  final double phase2;
  final double freq1;
  final double freq2;
  final double opacity;
}

class _EdgeBubble {
  _EdgeBubble({
    required this.angle,
    required this.baseRadiusFrac,
    required this.minSize,
    required this.maxSize,
    required this.phase,
    required this.freq,
    required this.drift,
    required this.alphaBase,
  });

  final double angle;
  final double baseRadiusFrac;
  final double minSize;
  final double maxSize;
  final double phase;
  final double freq;
  final double drift;
  final double alphaBase;
}

// ---------------- Painter ----------------

class _LiquidOrbPainter extends CustomPainter {
  final double t; // 0..1
  final List<_Blob> blobs;
  final List<_EdgeBubble> bubbles;

  _LiquidOrbPainter({
    required this.t,
    required this.blobs,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // ⭐ breathing pulse
    final tNorm = t * 2 * pi;
    final pulse = 1.0 + 0.025 * sin(tNorm * 0.6);
    final radius = min(w, h) / 2 * pulse;

    // circle clip
    final circleRect = Rect.fromCircle(center: center, radius: radius);
    final clipPath = Path()..addOval(circleRect);
    canvas.save();
    canvas.clipPath(clipPath);

    // background vignette
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.03),
          Colors.white.withOpacity(0.015),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(circleRect);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // ---------------- blobs (glowing plasma) ----------------
    canvas.saveLayer(circleRect, Paint());
    for (final b in blobs) {
      final dx = (sin(tNorm * b.freq1 + b.phase1) * b.amp1.dx +
          cos(tNorm * b.freq2 + b.phase2) * b.amp2.dx) *
          radius;
      final dy = (cos(tNorm * b.freq1 + b.phase1) * b.amp1.dy +
          sin(tNorm * b.freq2 + b.phase2) * b.amp2.dy) *
          radius;
      final pos = Offset(center.dx + (b.base.dx - 0.5) * w + dx,
          center.dy + (b.base.dy - 0.5) * h + dy);

      final r = radius *
          b.rFrac *
          (0.9 + 0.12 * sin(tNorm * (b.freq1 + b.freq2) + b.phase1));

      // outer aura
      final glowPaint = Paint()
        ..blendMode = BlendMode.plus
        ..color = b.color.withOpacity(b.opacity * 0.7)
        ..maskFilter =
        MaskFilter.blur(BlurStyle.normal, radius * 0.25); // stronger glow
      canvas.drawCircle(pos, r * 1.1, glowPaint);

      // inner bright core
      final corePaint = Paint()
        ..blendMode = BlendMode.plus
        ..color = b.color.withOpacity(0.9);
      canvas.drawCircle(pos, r * 0.6, corePaint);
    }
    canvas.restore();

    // ---------------- dynamic sweep highlight ----------------
    final sweep = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: GradientRotation(tNorm * 0.1),
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.transparent,
        Colors.white.withOpacity(0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final sweepPaint = Paint()
      ..blendMode = BlendMode.softLight
      ..shader = sweep.createShader(circleRect);
    canvas.drawCircle(center, radius, sweepPaint);

    canvas.restore(); // restore clip

    // ---------------- rim bubbles ----------------
    final bubblePaint = Paint()..isAntiAlias = true;
    for (final eb in bubbles) {
      final progress = (sin(tNorm * eb.freq + eb.phase) + 1) / 2.0;
      final a = eb.angle + tNorm * eb.drift;
      final rpos = radius * eb.baseRadiusFrac;
      final pos = Offset(center.dx + cos(a) * rpos, center.dy + sin(a) * rpos);
      final sizePx = eb.minSize + (eb.maxSize - eb.minSize) * progress;
      final alpha = eb.alphaBase + (0.5 * progress);

      bubblePaint
        ..color = Colors.white.withOpacity(alpha.clamp(0.0, 0.9))
        ..blendMode = BlendMode.screen // ⭐ glowing plasma sparks
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(pos, sizePx / 2, bubblePaint);
    }

    // ---------------- soft rim stroke ----------------
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, radius * 0.012)
      ..color = Colors.white.withOpacity(0.22);
    canvas.drawCircle(center, radius - rim.strokeWidth / 2, rim);
  }


  @override
  bool shouldRepaint(covariant _LiquidOrbPainter oldDelegate) => true;
}
