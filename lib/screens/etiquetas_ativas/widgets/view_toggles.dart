// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ViewToggles extends StatelessWidget {
  final bool showTop;
  final bool showFooter;
  final VoidCallback onToggleTop;
  final VoidCallback onToggleFooter;

  const ViewToggles({
    super.key,
    required this.showTop,
    required this.showFooter,
    required this.onToggleTop,
    required this.onToggleFooter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget pill({
      required IconData icon,
      required String label,
      required bool on,
      required VoidCallback tap,
    }) {
      final bg = isDark
          ? (on ? const Color(0xFFD4AF37) : const Color(0xFF1E1E1E))
          : (on ? Colors.white : Colors.black);

      final fg = isDark
          ? (on ? Colors.black : const Color(0xFFD4AF37))
          : (on ? Colors.black : Colors.white);

      final border = isDark
          ? const Color(0xFFD4AF37).withOpacity(0.20)
          : (on ? Colors.black.withOpacity(0.35) : Colors.white);

      return Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: tap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.18 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        pill(
          icon: showTop
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
          label: showTop ? "Esconder topo" : "Mostrar topo",
          on: showTop,
          tap: onToggleTop,
        ),
        pill(
          icon: showFooter
              ? Icons.expand_more_rounded
              : Icons.expand_less_rounded,
          label: showFooter ? "Esconder estoque" : "Mostrar estoque",
          on: showFooter,
          tap: onToggleFooter,
        ),
      ],
    );
  }
}