// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './linha_info.dart';

Widget buildInfosSomenteLinhas(
  List<CampoDesignEtiquetaModel> infoCampos, {
  required DesignEtiquetaModel config,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: toCrossAxis(
      infoCampos.isNotEmpty ? infoCampos.first.align : TextAlign.left,
    ),
    children: infoCampos.map((campo) {
      final isMultiLine = campo.id == 'ingredientes' ||
          campo.id == 'alergenicos' ||
          campo.id == 'observacao';

      return Padding(
        padding: EdgeInsets.only(bottom: isMultiLine ? 1.8 : 1.0),
        child: buildLinhaInfo(
          campo,
          destacarValidade: config.destacarValidade,
          is60x40: config.larguraMm <= 60.5 && config.alturaMm <= 40.5,
        ),
      );
    }).toList(),
  );
}