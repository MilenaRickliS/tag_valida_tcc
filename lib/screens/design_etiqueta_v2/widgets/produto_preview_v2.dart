import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_layout_preset.dart';
import '../../../utils/preview_align_utils_v2.dart';
import './preview_font_size_v2.dart';

Widget buildProdutoPreviewV2(
  CampoDesignEtiquetaV2Model campo,
  DesignEtiquetaV2Model config,
) {
  final baseFontSize = config.preset == EtiquetaLayoutPreset.mm60x40 ? 18.0 : 20.0;
  final fontSize = baseFontSize * previewFontFactorV2(config.tamanhoFonte);

  return Align(
    alignment: toAlignmentV2(campo.align),
    child: Text(
      _exampleValueProdutoV2(campo),
      textAlign: campo.align,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: fontSize,
        height: 1.0,
        fontWeight: campo.isBold ? FontWeight.w700 : FontWeight.w600,
        color: Colors.black,
      ),
    ),
  );
}

String _exampleValueProdutoV2(CampoDesignEtiquetaV2Model campo) {
  if (campo.id == 'produto') return 'Pão Francês';
  return campo.valorExemplo ?? campo.nome;
}