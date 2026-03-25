// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final bool compact;
  const PageHeader({super.key, required this.compact});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final text = _isDark(context) ? Colors.white : Colors.black.withOpacity(0.86);
    final muted =
        _isDark(context) ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.55);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Histórico",
                style: TextStyle(
                  fontSize: compact ? 22 : 26,
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Consulte todas as movimentações do estoque. Use filtros por período, tipo e busca para encontrar registros rapidamente.",
                style: TextStyle(
                  fontSize: compact ? 12.5 : 13.5,
                  height: 1.25,
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}