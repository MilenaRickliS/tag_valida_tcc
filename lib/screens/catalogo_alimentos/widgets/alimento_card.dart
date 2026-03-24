// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../detalhe_alimento_screen.dart';
import '../../../models/alimento_catalogo_model.dart';

class AlimentoCard extends StatelessWidget {
  final AlimentoCatalogo item;
  final Color brand;
  final Color text;
  final Color muted;
  final bool isDark;

  const AlimentoCard({super.key, 
    required this.item,
    required this.brand,
    required this.text,
    required this.muted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.05);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalheAlimentoScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.24 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.categoria,
                  style: TextStyle(
                    color: brand,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.nome,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.descricao,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 12),
              Text(
                'Sinais críticos:',
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...item.sinaisRuim.take(2).map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $s',
                        style: TextStyle(
                          color: muted,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
              const Spacer(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Ver sinais',
                    style: TextStyle(
                      color: brand,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: brand),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


