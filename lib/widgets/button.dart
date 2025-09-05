import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final FontWeight fontWeight;
  final IconData? icon; // optional icon
  final String? assetIcon;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderRadius = 50,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.icon,
    this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: textColor ?? theme.colorScheme.onPrimary,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(
          color: borderColor ?? Colors.transparent,
          width: 1, // thickness
        ),
        elevation: 3,
      ),
      child: icon == null && assetIcon == null
          ? Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? theme.colorScheme.onPrimary,
        ),
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!= null ?
          Icon(icon, color: textColor ?? theme.colorScheme.onPrimary)
          : Image.asset(assetIcon ?? 'aasets/icons/google-icon.png', scale: 2,),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor ?? theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
