// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ActiveFilterChip extends StatelessWidget {
  final String text;
  final VoidCallback? onRemove;

  const ActiveFilterChip({super.key, 
    required this.text,
    this.onRemove,
  });

 @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.10);
    final textColor = isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.80);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: textColor,
              fontSize: 12.5,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: textColor,
              ),
            )
          ],
        ],
      ),
    );
  }
}