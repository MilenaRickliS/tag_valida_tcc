// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class IconSquareButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const IconSquareButton({super.key, 
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

 @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.12);
    final iconColor = isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.75);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Icon(icon, color: iconColor),
          ),
        ),
      ),
    );
  }
}


