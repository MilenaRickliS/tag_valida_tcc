// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class OutrosMetodosCard extends StatelessWidget {
  const OutrosMetodosCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final brand = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF428E2E);

    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.65);

    final iconBg = isDark
        ? brand.withOpacity(0.12)
        : brand.withOpacity(0.10);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.pushNamed(context, '/catalogo-alimentos');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2A2418),
                    const Color(0xFF1A1A1A),
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
                ? const Color(0xFFD4AF37).withOpacity(0.25)
                : const Color(0xFF428E2E).withOpacity(0.20),
          ),
          boxShadow: [
            
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),

          
            BoxShadow(
              color: isDark
                  ? const Color(0xFFD4AF37).withOpacity(0.15)
                  : const Color(0xFF428E2E).withOpacity(0.12),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: brand,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

         
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: brand.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "Método alternativo",
                      style: TextStyle(
                        color: brand,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Não tem certeza se o alimento está bom?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: text,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Veja outras formas de identificar se o alimento está próprio para consumo, como cor, cheiro, textura e sinais de deterioração.",
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: brand.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Abrir catálogo",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: brand,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: brand),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}