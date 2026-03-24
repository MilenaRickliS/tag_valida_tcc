// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './active_filter_chip.dart';

class ActiveChip {
  final String text;
  final VoidCallback? onRemove;
  ActiveChip({required this.text, this.onRemove});
}

class ActiveChipsRow extends StatelessWidget {
  final List<ActiveChip> chips;
  final VoidCallback onClearAll;

  const ActiveChipsRow({super.key, 
    required this.chips,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clearColor = isDark ? const Color(0xFFD4AF37) : Colors.black;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in chips) ...[
                  ActiveFilterChip(
                    text: c.text,
                    onRemove: c.onRemove,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onClearAll,
          icon: Icon(Icons.clear_all_rounded, size: 18, color: clearColor),
          label: Text("Limpar", style: TextStyle(color: clearColor)),
        ),
      ],
    );
  }
}