// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import 'info_somente_linha_v2.dart';

Widget buildConteudoComLateralV2({
  required List<CampoDesignEtiquetaV2Model> infoCampos,
  required Widget lateral,
  required DesignEtiquetaV2Model config,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: buildInfosSomenteLinhasV2(
          infoCampos,
          config: config,
        ),
      ),
      const SizedBox(width: 18),
      SizedBox(
        width: config.preset.larguraMm <= 60 ? 72 : 170,
        child: Center(child: lateral),
      ),
    ],
  );
}