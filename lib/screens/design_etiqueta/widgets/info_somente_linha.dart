 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './linha_info.dart';

Widget buildInfosSomenteLinhas(List<CampoDesignEtiquetaModel> infoCampos, { required DesignEtiquetaModel config}) {
  return Column(
    crossAxisAlignment: toCrossAxis(
      infoCampos.isNotEmpty ? infoCampos.first.align : TextAlign.left,
    ),
    children: infoCampos.map((campo) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: buildLinhaInfo(campo,destacarValidade: config.destacarValidade),
      );
    }).toList(),
  );
}
