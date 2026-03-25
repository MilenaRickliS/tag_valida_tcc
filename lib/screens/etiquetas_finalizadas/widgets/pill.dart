// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const Pill({super.key, 
    required this.icon,
    required this.text,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.16)
              : Colors.black.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? const Color(0xFFD4AF37)
                : Colors.black.withOpacity(0.70),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFFD6D6D6)
                  : Colors.black.withOpacity(0.80),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}