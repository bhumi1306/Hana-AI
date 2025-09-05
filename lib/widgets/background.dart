import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget? child;
  final bool isRegister;

  const CustomBackground({super.key, this.child, this.isRegister = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: isRegister?
        LinearGradient(
          colors: [
            theme.colorScheme.primary,
            Color(0xFFB39DDB),
            Color(0xFFD1C4E9), // soft lavender
            Color(0xFFFFE0F0), // top pinkish
            theme.colorScheme.onPrimary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
        : LinearGradient(
          colors: [
            theme.colorScheme.onPrimary,
            Color(0xFFFFE0F0), // top pinkish
            Color(0xFFD1C4E9), // soft lavender
            Color(0xFFB39DDB), // purple
            theme.colorScheme.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          /// Curved painter
          CustomPaint(
            size: Size.infinite,
            painter: WavePainter(isRegister: isRegister),
            //CurvePainter(),
          ),

          /// Stars
          const Positioned(
            top: 60,
            left: 50,
            child: Star(size: 40,),
          ),
          const Positioned(
            top: 120,
            right: 80,
            child: Star(size: 30,),
          ),
          const Positioned(
            bottom: 180,
            left: 90,
            child: Star(),
          ),
          const Positioned(
            bottom: 100,
            right: 40,
            child: Star(size: 25,),
          ),

          /// Content goes here
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Painter for soft curved stroke
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final center = Offset(size.width / 2, size.height/2);

    // More oval shape (wider horizontally)
    final radiusX = size.width * 0.35;
    final radiusY = size.height * 0.05;

    final rect = Rect.fromCenter(center: center, width: radiusX * 2.2, height: radiusY * 1.2);

    // First oval (horizontal)
    canvas.drawOval(rect, paint);

    // Second oval (rotated, same size)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 10.5); // rotated ~51°
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
/// Painter for soft wave layers at the bottom
class WavePainter extends CustomPainter {
  final bool isRegister;
  const WavePainter({this.isRegister=false});
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = isRegister?Color(0xFFB39DDB).withOpacity(0.3):Colors.white.withOpacity(0.3);
    final paint2 = Paint()..color = isRegister?Color(0xFFB39DDB).withOpacity(0.3):Colors.white.withOpacity(0.3);
    final paint3 = Paint()..color = isRegister?Color(0xFFB39DDB).withOpacity(0.6):Colors.white.withOpacity(0.6);

    final path1 = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.80, size.width * 0.5, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.96, size.width, size.height * 0.90)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.95, size.width * 0.5, size.height * 0.87)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.79, size.width, size.height * 0.86)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path3 = Path()
      ..moveTo(0, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.85, size.width * 0.5, size.height * 0.93)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.89)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path3, paint3);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// Small shining star
class Star extends StatelessWidget {
  final double size;
  const Star({super.key, this.size=15});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(AssetImage('assets/icons/star.png'),
    size: size,
      color: Colors.white,
    );
  }
}
