// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../utils/preview_align_utils_v2.dart';
import 'preview_font_size_v2.dart';

Widget buildEmpresaPreviewV2(
  CampoDesignEtiquetaV2Model campo,
  DesignEtiquetaV2Model config,
) {
  final isSmall = config.preset.larguraMm <= 60;
  final baseFontSize = isSmall ? 6.5 : 9.0;
  final fontSize = baseFontSize * previewFontFactorV2(config.tamanhoFonte);

  return Align(
    alignment: toAlignmentV2(campo.align),
    child: Column(
      crossAxisAlignment: toCrossAxisV2(campo.align),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RAZÃO SOCIAL',
          textAlign: campo.align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: fontSize,
            height: 1.0,
            color: Colors.black.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'CNPJ: 12.123.456/0001-00',
          textAlign: campo.align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: fontSize,
            height: 1.0,
            color: Colors.black.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}