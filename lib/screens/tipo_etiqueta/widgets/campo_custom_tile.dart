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

  String _resumoConfiguracao(CampoCustomModel campo) {
    final partes = <String>[];

    if ((campo.prefixo ?? '').trim().isNotEmpty) {
      partes.add('Prefixo: ${campo.prefixo}');
    }

    if ((campo.sufixo ?? '').trim().isNotEmpty) {
      partes.add('Sufixo: ${campo.sufixo}');
    }

    if ((campo.unidadePadrao ?? '').trim().isNotEmpty) {
      partes.add('Unidade: ${campo.unidadePadrao}');
    }

    if (campo.tipo == CampoTipo.priceMode && campo.opcoesModoPreco.isNotEmpty) {
      partes.add('Preço por: ${campo.opcoesModoPreco.join(", ")}');
    }

    if (campo.casasDecimais > 0 &&
        (campo.tipo == CampoTipo.decimal ||
            campo.tipo == CampoTipo.currency ||
            campo.tipo == CampoTipo.priceMode)) {
      partes.add('Casas decimais: ${campo.casasDecimais}');
    }

    return partes.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final resumo = _resumoConfiguracao(campo);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                if (resumo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    resumo,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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