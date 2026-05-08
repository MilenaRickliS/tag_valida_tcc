// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/etiqueta_layout_preset.dart';

class TamanhoEtiquetaSelectorV2 extends StatelessWidget {
  final EtiquetaLayoutPreset selected;
  final ValueChanged<EtiquetaLayoutPreset> onChanged;
  final bool isDark;

  const TamanhoEtiquetaSelectorV2({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        preset: EtiquetaLayoutPreset.mm60x40,
        label: '60 x 40 mm',
      ),
      (
        preset: EtiquetaLayoutPreset.mm100x80,
        label: '100 x 80 mm',
      ),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.preset == selected;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(item.preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFED7227)
                    : (isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFED7227)
                      : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08)),
                ),
                boxShadow: isSelected
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
                    Icons.straighten,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? Colors.white
                              : const Color(0xFF2B2B2B)),
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