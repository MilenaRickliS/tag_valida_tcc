// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/alimento_catalogo_model.dart';

class HeaderAlimento extends StatelessWidget {
  final AlimentoCatalogo item;
  final bool isDark;
  final Color brand;
  final Color brandSoft;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const HeaderAlimento({super.key, 
    required this.item,
    required this.isDark,
    required this.brand,
    required this.brandSoft,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  IconData _iconeAlimento(String nome) {
    final n = nome.toLowerCase();

    if (n.contains('pão')) return Icons.breakfast_dining_rounded;
    if (n.contains('leite')) return Icons.local_drink_rounded;
    if (n.contains('queijo')) return Icons.egg_alt_rounded;
    if (n.contains('carne')) return Icons.set_meal_rounded;
    if (n.contains('frango')) return Icons.restaurant_rounded;
    if (n.contains('ovo')) return Icons.egg_rounded;
    if (n.contains('bolo')) return Icons.cake_rounded;
    if (n.contains('peixe')) return Icons.phishing_rounded;
    if (n.contains('fruta')) return Icons.apple_rounded;

    return Icons.food_bank_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icone = _iconeAlimento(item.nome);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF232323),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F3E8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: brandSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icone,
                  color: brand,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Guia visual de apoio para análise de qualidade do alimento.',
                      style: TextStyle(
                        color: textSecondary,
                        height: 1.45,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icone,
                  size: 54,
                  color: brand.withOpacity(0.85),
                ),
                const SizedBox(height: 10),
                Text(
                  'Imagem representativa',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Substituir esta área por uma imagem real do alimento ou ilustração.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      height: 1.45,
                      fontSize: 13.5,
                    ),
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
