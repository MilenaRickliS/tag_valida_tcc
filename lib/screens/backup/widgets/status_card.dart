// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _text(BuildContext context) =>
    _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

Widget statusCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  final textColor = _text(context); 

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.24)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.16),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withOpacity(0.75),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}