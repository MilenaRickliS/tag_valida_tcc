// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PdfButton extends StatelessWidget {
  final VoidCallback onPressed;
  const PdfButton({super.key, required this.onPressed});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final bg =
        _isDark(context) ? const Color(0xFFD4AF37) : const Color(0xFF2E7D32);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      onPressed: onPressed,
     icon: Icon(
        Icons.picture_as_pdf_rounded,
        color: Colors.black.withOpacity(0.78)
            
      ),
      label: const Text(
        "Gerar PDF",
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}