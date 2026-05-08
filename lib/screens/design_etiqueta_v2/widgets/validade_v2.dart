import 'package:flutter/material.dart';

enum StatusValidadePreviewV2 {
  normal,
  alerta,
  vencido,
}

Widget buildValidadeTermicaV2({
  required String valor,
  required bool destacar,
  required StatusValidadePreviewV2 status,
  required double fontSize,
  required TextAlign align,
  required bool isBold,
}) {
  final weight = isBold ? FontWeight.w800 : FontWeight.w600;

  String texto = 'VALIDADE: $valor';

  if (destacar) {
    if (status == StatusValidadePreviewV2.alerta) {
      texto += ' *EM ALERTA';
    } else if (status == StatusValidadePreviewV2.vencido) {
      texto += ' !VENCIDO';
    }
  }

  return Text(
    texto,
    textAlign: align,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: fontSize,
      fontWeight: weight,
      color: Colors.black87,
      height: 0.94,
    ),
  );
}