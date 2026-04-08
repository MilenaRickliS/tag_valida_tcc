// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';

Widget buildEmpresaPreviewNovo(
  CampoDesignEtiquetaModel campo,
  DesignEtiquetaModel config,
) {
  final fontSize = campo.fontSize.clamp(8.0, 12.0).toDouble();

  return Align(
    alignment: toAlignment(campo.align),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RAZAO SOCIAL',
          textAlign: campo.align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.05,
            color: Colors.black.withOpacity(0.82),
            fontWeight: campo.isBold ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'CNPJ: 12.123.456/0001-00',
          textAlign: campo.align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: (fontSize - 0.6).clamp(7.5, 11.0),
            height: 1.0,
            color: Colors.black.withOpacity(0.72),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
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