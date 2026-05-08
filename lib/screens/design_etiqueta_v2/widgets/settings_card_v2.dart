// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const _lightText = Color(0xFF2B2B2B);
const _darkSoft = Color(0xFF232323);
const _gold = Color(0xFFD4AF37);

Widget settingsCardV2({
  required String title,
  required Widget child,
  required bool isDark,
}) {
  return Container(
    width: 290,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? _darkSoft : const Color(0xFFFFFBF5),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? _gold.withOpacity(0.12)
            : Colors.black.withOpacity(0.06),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : _lightText,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}