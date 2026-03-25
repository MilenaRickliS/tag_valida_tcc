// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HeroCard extends StatelessWidget {
  final bool compact;

  const HeroCard({super.key, required this.compact});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardGradient = isDark
        ? const [
            Color(0xFF1E1E1E),
            Color(0xFF151515),
          ]
        : const [
            Color(0xFFFFFFFF),
            Color(0xFFF7F3EA),
          ];

    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.05);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.24 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HeroText(),
                SizedBox(height: 18),
                HeroIcon(),
              ],
            )
          : Row(
              children: const [
                Expanded(child: HeroText()),
                SizedBox(width: 20),
                HeroIcon(),
              ],
            ),
    );
  }
}

class HeroText extends StatelessWidget {
  const HeroText({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.68);
    final pillBg = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.12)
        : const Color(0xFF428E2E).withOpacity(0.10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            "Visão computacional",
            style: TextStyle(
              color: brand,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Prever validade por imagem",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: text,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Tire uma foto do alimento para que a inteligência artificial analise sinais visuais e ajude a identificar se o produto está bom, em alerta ou vencido.",
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: muted,
          ),
        ),
      ],
    );
  }
}

class HeroIcon extends StatelessWidget {
  const HeroIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final bg = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.12)
        : const Color(0xFF428E2E).withOpacity(0.10);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        Icons.document_scanner_outlined,
        size: 52,
        color: brand,
      ),
    );
  }
}