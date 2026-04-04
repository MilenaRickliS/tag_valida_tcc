// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/tipo_etiqueta_model.dart';

class TipoEtiquetaDesignSelector extends StatelessWidget {
  final List<TipoEtiquetaModel> tipos;
  final String? selectedId;
  final ValueChanged<TipoEtiquetaModel> onSelected;
  final bool isDark;

  const TipoEtiquetaDesignSelector({
    super.key,
    required this.tipos,
    required this.selectedId,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (tipos.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tipos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tipo = tipos[index];
          final selected = tipo.id == selectedId;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelected(tipo),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFED7227)
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFED7227)
                      : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08)),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFED7227).withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sell_outlined,
                    size: 18,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tipo.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF2B2B2B)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}