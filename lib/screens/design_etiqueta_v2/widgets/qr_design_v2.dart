// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_layout_preset.dart';

Widget buildQrPreviewV2(DesignEtiquetaV2Model config) {
  final size = config.preset == EtiquetaLayoutPreset.mm100x80 ? 108.0 : 84.0;

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

Widget buildQrPreviewV2ComData(String qrData, {double size = 84}) {
  return Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: QrImageView(
      data: qrData,
      size: size - 12,
      backgroundColor: Colors.white,
    ),
  );
}