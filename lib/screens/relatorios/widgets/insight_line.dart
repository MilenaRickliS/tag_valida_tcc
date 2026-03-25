// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class InsightLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? chipBg;
  final Color? chipFg;

  const InsightLine({super.key, 
    required this.label,
    required this.value,
    this.chipBg,
    this.chipFg,
  });

  @override
  Widget build(BuildContext context) {
    final hasChip = chipBg != null && chipFg != null;
    final labelColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD6D6D6)
        : const Color(0xFF6B5E4B);
    final valueColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (!hasChip)
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: chipFg!.withOpacity(0.25)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: chipFg,
              ),
            ),
          ),
      ],
    );
  }
}
