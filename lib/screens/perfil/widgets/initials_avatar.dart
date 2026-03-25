// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final String text;
  const InitialsAvatar({super.key, required this.text});

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "U";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    final a = parts.first.substring(0, 1).toUpperCase();
    final b = parts.last.substring(0, 1).toUpperCase();
    return "$a$b";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.black.withOpacity(0.06);
    final color = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF2B2B2B);

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      child: Center(
        child: Text(
          _initials(text),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}
