// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ResumoLinha extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const ResumoLinha({super.key, 
    required this.label,
    required this.value,
    this.valueColor,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final text = _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);
    final muted = _isDark(context)
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.52);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: valueColor ?? text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}