// ignore_for_file: deprecated_member_use

import '../../../models/design_etiqueta_v2_model.dart';
import 'package:flutter/material.dart';

double previewFontFactorV2(TamanhoFonteEtiqueta tamanho) {
  switch (tamanho) {
    case TamanhoFonteEtiqueta.pequena:
      return 0.90;
    case TamanhoFonteEtiqueta.media:
      return 1.0;
    case TamanhoFonteEtiqueta.grande:
      return 1.18;
  }
}

class FontSizeSelectorV2 extends StatelessWidget {
  final TamanhoFonteEtiqueta selected;
  final bool isDark;
  final ValueChanged<TamanhoFonteEtiqueta> onChanged;

  const FontSizeSelectorV2({
    super.key,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = text.withOpacity(0.65);
    final bg = isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFFFFBF5);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.12)
        : Colors.black.withOpacity(0.07);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tamanho da fonte',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: text)),
          const SizedBox(height: 4),
          Text(
            'Ajusta o tamanho dos textos da etiqueta. A tabela nutricional não é alterada.',
            style: TextStyle(fontSize: 12.5, color: muted, height: 1.25),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FontOptionV2(
                label: 'Pequena',
                subtitle: 'Mais campos',
                icon: Icons.text_decrease_rounded,
                value: TamanhoFonteEtiqueta.pequena,
                selected: selected,
                isDark: isDark,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              _FontOptionV2(
                label: 'Média',
                subtitle: 'Equilíbrio',
                icon: Icons.text_fields_rounded,
                value: TamanhoFonteEtiqueta.media,
                selected: selected,
                isDark: isDark,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              _FontOptionV2(
                label: 'Grande',
                subtitle: 'Mais legível',
                icon: Icons.text_increase_rounded,
                value: TamanhoFonteEtiqueta.grande,
                selected: selected,
                isDark: isDark,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FontOptionV2 extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final TamanhoFonteEtiqueta value;
  final TamanhoFonteEtiqueta selected;
  final bool isDark;
  final ValueChanged<TamanhoFonteEtiqueta> onChanged;

  const _FontOptionV2({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final orange = const Color(0xFFED7227);
    final gold = const Color(0xFFD4AF37);

    final bg = isSelected
        ? orange.withOpacity(isDark ? 0.22 : 0.12)
        : isDark
            ? Colors.white.withOpacity(0.035)
            : Colors.white;

    final border = isSelected
        ? orange
        : isDark
            ? gold.withOpacity(0.12)
            : Colors.black.withOpacity(0.06);

    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = text.withOpacity(0.62);

    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: isSelected ? 1.4 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? orange : muted),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? orange : text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.8, color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}