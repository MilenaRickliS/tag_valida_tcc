// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

 Widget buildEmptyTiposCard({
    required Color card,
    required Color text,
    required Color muted,
    required Color border,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sell_outlined,
            size: 42,
            color: muted,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum tipo de etiqueta cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre pelo menos um tipo de etiqueta para configurar o design.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }