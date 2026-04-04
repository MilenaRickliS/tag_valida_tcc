 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget buildLoadingCard({
    required Color card,
    required Color text,
    required Color muted,
    required Color border,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            'Carregando design da etiqueta...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aguarde enquanto os campos do tipo selecionado são preparados.',
            style: TextStyle(
              fontSize: 12.5,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }