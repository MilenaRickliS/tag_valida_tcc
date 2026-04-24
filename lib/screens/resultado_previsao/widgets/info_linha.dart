// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class InfoLinha extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color textColor;
  final Color mutedColor;

  const InfoLinha({super.key, 
    required this.titulo,
    required this.valor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              color: mutedColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}



