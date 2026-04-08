 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './info_somente_linha.dart';

Widget buildConteudoComLateral({
  required List<CampoDesignEtiquetaModel> infoCampos,
  required Widget lateral,
  required DesignEtiquetaModel config,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: buildInfosSomenteLinhas(infoCampos, config: config),
      ),
      const SizedBox(width: 18),
      SizedBox(
        width: 170,
        child: Center(child: lateral),
      ),
    ],
  );
}
