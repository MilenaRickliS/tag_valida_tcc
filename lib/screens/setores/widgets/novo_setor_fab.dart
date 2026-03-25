// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NovoSetorFab extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;
  final Color brand;
  final Color border;

  const NovoSetorFab({
    super.key,
    required this.onPressed,
    required this.isDark,
    required this.brand,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFD4AF37) : brand,
        elevation: 0,
        onPressed: onPressed,
        icon: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: brand,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add,
            color: isDark ? Colors.black : Colors.white,
            size: 20,
          ),
        ),
        label: Text(
          "Novo setor",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFFD4AF37) : null,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}