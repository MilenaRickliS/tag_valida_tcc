// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';

 Widget buildQrPreviewNovo(DesignEtiquetaModel config) {
  final largura = config.larguraMm;
  final size = largura >= 100 ? 108.0 : 84.0;

  return Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/exemplos/qr_exemplo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.qr_code_2,
          color: Colors.black,
          size: 72,
        ),
      ),
    ),
  );
}