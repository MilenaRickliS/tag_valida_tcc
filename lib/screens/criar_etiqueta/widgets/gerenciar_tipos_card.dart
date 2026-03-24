// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GerenciarTiposCard extends StatelessWidget {
  final VoidCallback onTap;

  const GerenciarTiposCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.60);
    final accent = isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.tune_rounded, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gerenciar tipos de etiqueta",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Configure campos personalizados, lote automático e regras de validade.",
                    style: TextStyle(
                      color: muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}