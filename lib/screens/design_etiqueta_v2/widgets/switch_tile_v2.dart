// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const _lightText = Color(0xFF2B2B2B);
const _orange = Color(0xFFED7227);

Widget switchTileV2({
  required bool isDark,
  required bool value,
  required String title,
  required ValueChanged<bool> onChanged,
}) {
  return SwitchListTile.adaptive(
    dense: true,
    value: value,
    contentPadding: EdgeInsets.zero,
    activeColor: _orange,
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : _lightText,
      ),
    ),
    onChanged: onChanged,
  );
}