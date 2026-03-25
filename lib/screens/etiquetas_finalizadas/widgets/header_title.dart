// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) => _isDark(context)
      ? const Color(0xFFD6D6D6)
      : Colors.black.withOpacity(0.60);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Etiquetas finalizadas",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _text(context),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Vendidas e canceladas (arquivo). Abra para ver o preview ou reativar.",
            style: TextStyle(
              color: _muted(context),
              fontSize: 12.8,
            ),
          ),
        ],
      ),
    );
  }
}