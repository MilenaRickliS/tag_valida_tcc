// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class LoteReadOnlyCard extends StatelessWidget {
  final String lote;
  final VoidCallback? onRegenerate;

  const LoteReadOnlyCard({super.key, 
    required this.lote,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final onBrand = isDark ? Colors.black : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.55);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brand.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: onBrand,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lote (automático)",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lote.isEmpty ? "Gerando..." : lote,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Gerado automaticamente pelo tipo de etiqueta.",
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRegenerate != null)
            IconButton(
              tooltip: "Gerar novo lote",
              onPressed: onRegenerate,
              icon: Icon(
                Icons.refresh,
                color: isDark ? brand : null,
              ),
            ),
        ],
      ),
    );
  }
}