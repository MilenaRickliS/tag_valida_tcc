// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class EmptyBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyBox({super.key, 
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.16)
              : Colors.black.withOpacity(0.07),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 42,
            color: isDark
                ? const Color(0xFFD4AF37)
                : Colors.black.withOpacity(0.75),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFFD6D6D6)
                  : Colors.black.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }
}