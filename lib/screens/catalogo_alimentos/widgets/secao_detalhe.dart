// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SecaoDetalhe extends StatelessWidget {
  final String titulo;
  final Color cor;
  final List<String> itens;

  const SecaoDetalhe({super.key, 
    required this.titulo,
    required this.cor,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.65);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 10),
          ...itens.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $e',
                style: TextStyle(
                  color: muted,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

