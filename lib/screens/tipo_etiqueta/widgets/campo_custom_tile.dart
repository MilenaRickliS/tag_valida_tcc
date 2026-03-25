import 'package:flutter/material.dart';
import '../../../models/tipo_etiqueta_model.dart';

class CampoCustomTile extends StatelessWidget {
  final CampoCustomModel campo;
  final Color fieldBg;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final Color brandColor;
  final bool isDark;
  final String Function(CampoTipo tipo) campoTipoLabel;
  final String Function(CampoTipo tipo) campoTipoHint;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const CampoCustomTile({
    super.key,
    required this.campo,
    required this.fieldBg,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.brandColor,
    required this.isDark,
    required this.campoTipoLabel,
    required this.campoTipoHint,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_handle, color: mutedColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${campo.label}${campo.obrigatorio ? " *" : ""}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Chave: ${campo.key} • Tipo: ${campoTipoLabel(campo.tipo)}",
                  style: TextStyle(color: mutedColor),
                ),
                const SizedBox(height: 2),
                Text(
                  campoTipoHint(campo.tipo),
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Editar campo",
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              color: isDark ? brandColor : null,
            ),
          ),
          IconButton(
            tooltip: "Remover campo",
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}