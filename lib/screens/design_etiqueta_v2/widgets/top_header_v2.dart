// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget buildTopHeaderV2({
  required Color card,
  required Color text,
  required Color muted,
  required Color border,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Design da etiqueta',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha o tamanho da etiqueta e personalize os campos exibidos. A fonte e o encaixe visual são controlados automaticamente pelo layout.',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: muted,
          ),
        ),
      ],
    ),
  );
}