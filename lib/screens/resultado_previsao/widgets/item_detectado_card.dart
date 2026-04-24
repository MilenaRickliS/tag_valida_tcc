// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './info_linha.dart';

class ItemDetectadoCard extends StatelessWidget {
  final String produto;
  final String estado;
  final double produtoConf;
  final double estadoConf;
  final Color text;
  final Color muted;
  final Color card;
  final Color border;
  final bool isDark;
  final Color color;
  final String tituloAcao;
  final String descricaoAcao;
  final IconData icon;

  const ItemDetectadoCard({super.key, 
    required this.produto,
    required this.estado,
    required this.produtoConf,
    required this.estadoConf,
    required this.text,
    required this.muted,
    required this.card,
    required this.border,
    required this.isDark,
    required this.color,
    required this.tituloAcao,
    required this.descricaoAcao,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final confiancaMediaItem = _mediaConfianca(produtoConf, estadoConf);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  produto,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.20)),
                ),
                child: Text(
                  estado.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          InfoLinha(
            titulo: 'Confiança geral',
            valor: '${confiancaMediaItem.toStringAsFixed(0)}%',
            textColor: text,
            mutedColor: muted,
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (confiancaMediaItem.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tituloAcao,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  descricaoAcao,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  double _mediaConfianca(double a, double b) {
    if (a <= 0 && b <= 0) return 0;
    if (a <= 0) return b;
    if (b <= 0) return a;
    return (a + b) / 2;
  }
}