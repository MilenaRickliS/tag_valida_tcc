import 'package:flutter/material.dart';
import '../../../models/tipo_etiqueta_model.dart';
import 'campo_custom_tile.dart';

class CampoCustomSection extends StatelessWidget {
  final List<CampoCustomModel> campos;
  final Color sectionBg;
  final Color fieldBg;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final Color brandColor;
  final Color onBrandColor;
  final bool isDark;

  final Future<void> Function() onAdd;
  final Future<void> Function(int index, CampoCustomModel campo) onEdit;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  final String Function(CampoTipo tipo) campoTipoLabel;
  final String Function(CampoTipo tipo) campoTipoHint;

  const CampoCustomSection({
    super.key,
    required this.campos,
    required this.sectionBg,
    required this.fieldBg,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.brandColor,
    required this.onBrandColor,
    required this.isDark,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.onReorder,
    required this.campoTipoLabel,
    required this.campoTipoHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Campos personalizados",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: onBrandColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(Icons.add, color: onBrandColor),
                label: const Text(
                  "Adicionar",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Adicione campos que você quer preencher ao criar etiquetas (ex: Lote, Peso, Observações).",
            style: TextStyle(color: mutedColor),
          ),
          const SizedBox(height: 12),
          if (campos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                "Nenhum campo adicional.\nToque em “Adicionar” para criar o primeiro.",
                style: TextStyle(color: mutedColor),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: campos.length,
              onReorder: onReorder,
              itemBuilder: (context, i) {
                final c = campos[i];
               return CampoCustomTile(
                  key: ValueKey("${c.key}-$i"),
                  campo: c,
                  fieldBg: fieldBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  brandColor: brandColor,
                  isDark: isDark,
                  campoTipoLabel: campoTipoLabel,
                  campoTipoHint: campoTipoHint,
                  onEdit: () => onEdit(i, c),
                  onRemove: () => onRemove(i),
                );
              },
            ),
        ],
      ),
    );
  }
}