// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';

Widget buildImagemPreviewV2(CampoDesignEtiquetaV2Model campo) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: AspectRatio(
      aspectRatio: 1.2,
      child: Image.asset(
        'assets/exemplos/pao_dither.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF4F4F4),
          child: const Icon(
            Icons.image_outlined,
            size: 42,
            color: Colors.grey,
          ),
        ),
      ),
    ),
  );
}