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
  final weight = isBold ? FontWeight.w800 : FontWeight.w500;

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
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      color: Colors.black87,
      height: 1.05,
    ),
  );
}