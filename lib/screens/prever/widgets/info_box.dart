// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark
        ? const Color(0xFF1E1E1E).withOpacity(0.96)
        : Colors.white.withOpacity(0.92);
    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.05);
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final iconBg = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.12)
        : const Color(0xFF428E2E).withOpacity(0.12);
    final text = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.75);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.24 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.info_outline,
              color: brand,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Após tirar a foto, a inteligência artificial poderá classificar o alimento como bom, em alerta ou vencido, conforme os padrões visuais aprendidos durante o treinamento.",
              style: TextStyle(
                height: 1.5,
                fontSize: 14.5,
                color: text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}