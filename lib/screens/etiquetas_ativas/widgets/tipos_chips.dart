// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/tipo_etiqueta_model.dart';

class TiposChips extends StatelessWidget {
  final bool loading;
  final List<TipoEtiquetaModel> tipos;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const TiposChips({super.key, 
    required this.loading,
    required this.tipos,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final card = isDark ? const Color(0xFF181818) : const Color(0xFFFDF7ED);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.10);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);

    if (loading && tipos.isEmpty) {
      return const LinearProgressIndicator(minHeight: 3);
    }

    if (tipos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          "Nenhum tipo encontrado. Cadastre em “Tipos de etiqueta”.",
          style: TextStyle(color: muted),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tipos.map((t) {
          final selected = t.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 6),
                  Text(t.nome),
                ],
              ),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(t.id),
              selectedColor: brand,
              labelStyle: TextStyle(
                color: selected
                    ? (isDark ? Colors.black : Colors.white)
                    : brand,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: border),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}