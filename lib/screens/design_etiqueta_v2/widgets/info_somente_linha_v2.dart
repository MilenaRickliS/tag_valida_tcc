// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import 'linha_info_v2.dart';
import '../../../utils/preview_align_utils_v2.dart';

Widget buildInfosSomenteLinhasV2(
  List<CampoDesignEtiquetaV2Model> infoCampos, {
  required DesignEtiquetaV2Model config,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: toCrossAxisV2(
      infoCampos.isNotEmpty ? infoCampos.first.align : TextAlign.left,
    ),
    children: infoCampos.map((campo) {
      final isMultiLine = campo.id == 'ingredientes' ||
          campo.id == 'alergenicos' ||
          campo.id == 'observacao';

      return Padding(
        padding: EdgeInsets.only(bottom: isMultiLine ? 1.8 : 1.0),
        child: buildLinhaInfoV2(
          campo,
          config: config,
        ),
      );
    }).toList(),
  );
}