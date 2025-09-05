import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Utility/icon_animation.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final void Function(String)? onChanged;
  final AutovalidateMode? autoValidateMode;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines,
    this.textCapitalization,
    this.onChanged,
    this.autoValidateMode,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines ?? 1,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      autovalidateMode: widget.autoValidateMode,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus(); // Closes the keyboard
      },
      decoration: InputDecoration(
        errorText: widget.errorText,
        errorStyle: TextStyle(height: 0),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.6)),
        labelText: widget.labelText,
        labelStyle: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.6),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: theme.colorScheme.primary,
        ),
        prefixIcon: widget.prefixIcon != null
            ? BouncingIcon(
          icon: widget.prefixIcon!,
          color: theme.colorScheme.primary,
          focusNode: _focusNode,
        )
            : null,
        suffixIcon: widget.suffixIcon != null ?
        GestureDetector( onTap: widget.onSuffixTap,
          child: Icon(widget.suffixIcon, color: theme.colorScheme.primary), )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        counterText: '',
        counterStyle: const TextStyle(color: Colors.transparent),
      ),
      style: TextStyle(
        color: theme.colorScheme.onSecondary,
        fontSize: 16,
      ),
        onChanged: widget.onChanged
    );
  }
}
