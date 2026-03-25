// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  final TextInputType? type;
  final String? Function(String?)? validator;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  final FocusNode? focusNode;

  final bool isDark;
  final Color textColor;
  final Color borderColor;

  const ProfileFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.isDark,
    required this.textColor,
    required this.borderColor,
    this.type,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark
        ? const Color(0xFF161616)
        : const Color(0xFFFAF7F1);

    final prefixColor =
        isDark ? const Color(0xFFD4AF37) : textColor;

    final labelColor = isDark
        ? const Color(0xFFD6D6D6)
        : textColor.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        inputFormatters: inputFormatters,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
          ),
          floatingLabelStyle: TextStyle(
            color: isDark
                ? const Color(0xFFD4AF37)
                : textColor,
            fontWeight: FontWeight.w900,
          ),
          filled: true,
          fillColor: fill,
          prefixIcon: prefixIcon != null
              ? IconTheme(
                  data: IconThemeData(color: prefixColor),
                  child: prefixIcon!,
                )
              : null,
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark
                  ? const Color(0xFFD4AF37)
                  : textColor,
              width: 1.6,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        validator: validator,
      ),
    );
  }
}