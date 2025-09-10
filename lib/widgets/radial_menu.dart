import 'dart:math' as math;
import 'package:flutter/material.dart';

class ArcMenu extends StatefulWidget {
  final List<IconData> icons;
  final Function(int) onIconPressed;
  final double radius; // how far items fly out
  final Color mainColor;
  final Color itemColor;
  final IconData mainIcon;
  final double mainSize;
  final double itemSize;
  final Duration duration;

  const ArcMenu({
    super.key,
    required this.icons,
    required this.onIconPressed,
    this.radius = 120,
    this.mainColor = Colors.red,
    this.itemColor = Colors.blue,
    this.mainIcon = Icons.add,
    this.mainSize = 80,
    this.itemSize = 56,
    this.duration = const Duration(milliseconds: 320),
  });

  @override
  State<ArcMenu> createState() => _ArcMenuState();
}

class _ArcMenuState extends State<ArcMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool get isOpen => _controller.status == AnimationStatus.completed;

  // angles for the 3 items (degrees). These point to top-right quadrant.
  // You can tweak these values to move the arc.
  List<double> _generateAngles(int count, {double start = -75, double step = 30}) {
    return List.generate(count, (i) => start + i * step);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _buildItem(int index, IconData icon) {
    final List<double> defaultAngles = _generateAngles(widget.icons.length);
    final angleDeg = (index < defaultAngles.length)
        ? defaultAngles[index]
        : -35 + index * -20; // fallback
    final angle = angleDeg * (math.pi / 150);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final radius = widget.radius * _controller.value;
        final dx = math.cos(angle) * radius;
        final dy = math.sin(angle) * radius;
        // dy will be negative for the negative angles -> moves upward
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: _controller.value,
            child: Transform.scale(
              scale: 0.5 + 0.3 * _controller.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.itemSize,
        height: widget.itemSize,
        decoration: BoxDecoration(
          color: widget.itemColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        alignment: Alignment.center,
        child: GestureDetector
          (
            onTap: () {
              widget.onIconPressed(index);
              // close the menu after tap
              _toggle();
            },
            child: Icon(icon, color: theme.colorScheme.primary)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // a comfortable sized box so items have room to translate
    final width = widget.radius + widget.mainSize + 20;
    final height = widget.radius.abs() / 1.6 + widget.mainSize;

    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // transparent tap-catcher when menu is open so a tap outside closes it
          // if (!(_controller.status == AnimationStatus.dismissed))
          //   Positioned.fill(
          //     child: GestureDetector(
          //       behavior: HitTestBehavior.translucent,
          //       onTap: _toggle,
          //       child: const SizedBox.expand(),
          //     ),
          //   ),

          // items
          ...List.generate(widget.icons.length, (i) {
            return Positioned(
              left: 0,
              top: (height - widget.itemSize) / 2,
              child: _buildItem(i, widget.icons[i]),
            );
          }),

          // main big round button (left origin)
          Positioned(
            left: 0,
            top: (height - widget.mainSize) / 2,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                width: widget.mainSize,
                height: widget.mainSize,
                decoration: BoxDecoration(
                  color: widget.mainColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.mainIcon,
                  color: Colors.white,
                  size: widget.mainSize * 0.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
