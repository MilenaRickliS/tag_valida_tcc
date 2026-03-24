// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CatalogoHeroCard extends StatelessWidget {
  final Color brand;
  final Color text;
  final bool isDark;

  const CatalogoHeroCard({super.key, 
    required this.brand,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2418),
                  const Color(0xFF151515),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFF4EFE5),
                  const Color(0xFFE8F5E9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.22)
              : const Color(0xFF428E2E).withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.24 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: brand.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Consulta manual',
                    style: TextStyle(
                      color: brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Catálogo de alimentos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veja sinais de cor, cheiro, textura e deterioração para entender melhor quando um alimento está bom, em alerta ou impróprio para consumo.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFD6D6D6)
                        : Colors.black.withOpacity(0.68),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: brand.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 44,
              color: brand,
            ),
          ),
        ],
      ),
    );
  }
}

