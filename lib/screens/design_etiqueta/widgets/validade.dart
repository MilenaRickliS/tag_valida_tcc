import 'package:flutter/material.dart';

enum StatusValidadePreview {
  normal,
  alerta,
  vencido,
}

Widget buildValidadeTermica({
  required String valor,
  required bool destacar,
  required StatusValidadePreview status,
  required double fontSize,
  required TextAlign align,
  required bool isBold,
}) {
  final weight = isBold ? FontWeight.w800 : FontWeight.w600;

  String texto = 'VALIDADE: $valor';

  if (destacar) {
    if (status == StatusValidadePreview.alerta) {
      texto += ' *EM ALERTA';
    } else if (status == StatusValidadePreview.vencido) {
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