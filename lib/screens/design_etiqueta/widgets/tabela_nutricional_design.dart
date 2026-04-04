// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget buildTabelaNutricionalPreview() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/exemplos/tabela_nutricional_exemplo.jpg',
          width: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 150,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: const Text(
              'Tabela nutricional',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/exemplos/lupa_exemplo.jpg',
          width: 170,
          fit: BoxFit.contain,
        ),
      ),
    ],
  );
}