
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool danger;
  final bool warn;

  const MiniPill({super.key, 
    required this.icon,
    required this.text,
    this.danger = false,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = danger
        ? Colors.red.withOpacity(0.30)
        : warn
            ? Colors.orange.withOpacity(0.30)
            : isDark
                ? const Color(0xFFD4AF37).withOpacity(0.20)
                : Colors.black.withOpacity(0.12);

    final bg = danger
        ? Colors.red.withOpacity(0.07)
        : warn
            ? Colors.orange.withOpacity(0.07)
            : isDark
                ? const Color(0xFFD4AF37).withOpacity(0.10)
                : Colors.black.withOpacity(0.04);

    final fg = danger
        ? Colors.red
        : warn
            ? Colors.orange
            : isDark
                ? const Color(0xFFD4AF37)
                : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

