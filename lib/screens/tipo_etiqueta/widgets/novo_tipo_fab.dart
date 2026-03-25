// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NovoTipoFab extends StatelessWidget {
  final bool isDark;
  final Color brand;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onPressed;

  const NovoTipoFab({
    super.key,
    required this.isDark,
    required this.brand,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
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
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            "Novo tipo",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: foregroundColor,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}