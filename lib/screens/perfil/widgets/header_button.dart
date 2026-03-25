// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HeaderButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const HeaderButtons({super.key, required this.onEdit, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final outlineColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.35)
        : Colors.black.withOpacity(0.12);
    final editIconColor = isDark
        ? const Color(0xFFD4AF37)
        : Colors.black;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onEdit,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: outlineColor, width: 1.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : null,
          ),
          icon: Icon(Icons.edit_rounded, size: 18, color: editIconColor,),
          label: Text(
            "Editar",
            style: TextStyle(fontWeight: FontWeight.w900, color: textColor,),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white,),
          label: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}