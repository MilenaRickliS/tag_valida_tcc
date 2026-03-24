// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/etiqueta_model.dart';
import './categoria_section.dart';
import 'custom_badge.dart';

class SetorSection extends StatelessWidget {
  final String setorNome;
  final Map<String, List<EtiquetaModel>> categoriasMap;
  final DateTime Function(List<EtiquetaModel>) minValidadeOf;
  final String uid;

  const SetorSection({super.key, 
    required this.setorNome,
    required this.categoriasMap,
    required this.minValidadeOf,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final categoriasOrdenadas = categoriasMap.entries.toList()
      ..sort((a, b) => minValidadeOf(a.value).compareTo(minValidadeOf(b.value)));

    final minSetor =
        minValidadeOf(categoriasMap.values.expand((v) => v).toList());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF181818) : Colors.white.withOpacity(0.55);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.07);
    final text = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        iconColor: isDark ? const Color(0xFFD4AF37) : null,
        collapsedIconColor: isDark ? const Color(0xFFD4AF37) : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                setorNome,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
            ),
            CustomBadge(text: "Mais próximo a vencer: ${_fmt(minSetor)}"),
          ],
        ),
        children: [
          for (final catEntry in categoriasOrdenadas) ...[
            CategoriaSection(
              categoriaNome: catEntry.key,
              etiquetas: catEntry.value,
              uid: uid,
            ),
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