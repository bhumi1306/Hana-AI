import 'package:flutter/material.dart';

class BouncingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final FocusNode focusNode;

  const BouncingIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.focusNode,
    this.onTap,
  });

  @override
  State<BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Trigger bounce once on focus
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _controller.forward(from: 0.0).then((_) => _controller.reverse());
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
    Widget icon = ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, color: widget.color),
    );
    return icon;
  }
}
