 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './resumo_box.dart';

Widget buildResumoRapido({
    required Color card,
    required Color border,
    required Color text,
    required Color muted,
    required int quantidadeDetectada,
    required double confiancaMedia,
    required String estadoGeral,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da análise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Informações principais para tomada de decisão.',
            style: TextStyle(
              fontSize: 14,
              color: muted,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;

              final cards = [
                ResumoBox(
                  icon: Icons.category_rounded,
                  titulo: 'Itens detectados',
                  valor: '$quantidadeDetectada',
                  color: Colors.blue,
                ),
                ResumoBox(
                  icon: Icons.speed_rounded,
                  titulo: 'Confiança média',
                  valor: '${confiancaMedia.toStringAsFixed(0)}%',
                  color: Colors.deepPurple,
                ),
                ResumoBox(
                  icon: estadoIcon(estadoGeral),
                  titulo: 'Status geral',
                  valor: estadoGeral.toUpperCase(),
                  color: estadoColor(estadoGeral),
                ),
              ];

              if (isSmall) {
                return Column(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      SizedBox(
                        width: double.infinity,
                        child: cards[i],
                      ),
                      if (i != cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color estadoColor(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return const Color(0xFF54A73B);
      case 'alerta':
        return const Color(0xFFED7227);
      case 'vencido':
        return const Color(0xFFE53935);
      default:
        return Colors.blueGrey;
    }
  }


  IconData estadoIcon(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return Icons.check_circle_rounded;
      case 'alerta':
        return Icons.warning_amber_rounded;
      case 'vencido':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }