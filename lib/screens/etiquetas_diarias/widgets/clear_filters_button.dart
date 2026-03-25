// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class ClearFiltersButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const ClearFiltersButton({super.key, 
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.12);
    final fg = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.transparent;

    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
      label: const Text("Limpar"),
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        backgroundColor: bg,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
