// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';

Widget buildEmpresaPreviewNovo(
  CampoDesignEtiquetaModel campo,
  DesignEtiquetaModel config,
) {
  final fontSize = campo.fontSize.clamp(8.0, 10.0).toDouble();

  return Align(
    alignment: toAlignment(campo.align),
    child: Column(
      crossAxisAlignment: toCrossAxis(campo.align),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RAZAO SOCIAL',
          textAlign: campo.align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
         style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: fontSize,
            height: 1.0,
            color: Colors.black.withOpacity(0.85),
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
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
            letterSpacing: 0,
          ),
        ),
      ],
    ),
  );
}

Alignment toAlignment(TextAlign align) {
  switch (align) {
    case TextAlign.center:
      return Alignment.center;
    case TextAlign.right:
      return Alignment.centerRight;
    case TextAlign.left:
    default:
      return Alignment.centerLeft;
  }
}

CrossAxisAlignment toCrossAxis(TextAlign align) {
  switch (align) {
    case TextAlign.center:
      return CrossAxisAlignment.center;
    case TextAlign.right:
      return CrossAxisAlignment.end;
    case TextAlign.left:
    default:
      return CrossAxisAlignment.start;
  }
}