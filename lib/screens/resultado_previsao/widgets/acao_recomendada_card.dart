// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AcaoRecomendadaCard extends StatelessWidget {
  final String estado;
  final String titulo;
  final String descricao;
  final IconData icon;
  final Color color;
  final bool isDark;

  const AcaoRecomendadaCard({super.key, 
    required this.estado,
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.32 : 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ação recomendada',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}