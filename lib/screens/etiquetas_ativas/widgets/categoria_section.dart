// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/etiqueta_model.dart';
import 'custom_badge.dart';
import './etiqueta_card.dart';

class CategoriaSection extends StatelessWidget {
  final String categoriaNome;
  final List<EtiquetaModel> etiquetas;
  final String uid;

  const CategoriaSection({super.key, 
    required this.categoriaNome,
    required this.etiquetas,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    etiquetas.sort((a, b) => a.dataValidade.compareTo(b.dataValidade));
    final minCat = etiquetas.first.dataValidade;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.06);
    final text = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        iconColor: isDark ? const Color(0xFFD4AF37) : null,
        collapsedIconColor: isDark ? const Color(0xFFD4AF37) : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                categoriaNome,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
            ),
            CustomBadge(text: "Mais próximo a vencer: ${_fmt(minCat)}"),
          ],
        ),
        children: [
          for (final e in etiquetas) ...[
            EtiquetaCard(uid: uid, e: e),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  static String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, "0");
    final mm = d.month.toString().padLeft(2, "0");
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }
}