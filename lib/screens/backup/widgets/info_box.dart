// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _text(BuildContext context) =>
    _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

Color _muted(BuildContext context) =>
    _isDark(context)
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.60);

Color _border(BuildContext context) =>
    _isDark(context)
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.07);

Widget infoBox(
  BuildContext context, {
  required String title,
  required String value,
}) {
  final textColor = _text(context);
  final mutedColor = _muted(context);
  final borderColor = _border(context);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}