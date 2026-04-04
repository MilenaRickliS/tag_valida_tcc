// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './etiqueta_preview_design.dart';

const double _minLarguraMm = 20;
const double _maxLarguraMm = 111;
const double _minAlturaMm = 8;
const double _maxAlturaMm = 2000;

double clampLargura(double value) {
  return value.clamp(_minLarguraMm, _maxLarguraMm).toDouble();
}

double clampAltura(double value) {
  return value.clamp(_minAlturaMm, _maxAlturaMm).toDouble();
}

Widget buildPreviewPanel({
  required bool isDark,
  required Color card,
  required Color text,
  required Color muted,
  required Color border,
  required DesignEtiquetaModel config,
}) {
  final shell = isDark ? const Color(0xFF121212) : const Color(0xFFFFFBF6);

  final larguraMm = clampLargura(
    config.larguraMm <= 0 ? 60 : config.larguraMm,
  );
  final alturaMm = clampAltura(
    config.alturaMm <= 0 ? 40 : config.alturaMm,
  );

  const double maxPreviewWidth = 560;
  const double maxPreviewHeight = 420;

  double previewWidth = maxPreviewWidth;
  double previewHeight = previewWidth * (alturaMm / larguraMm);

  if (previewHeight > maxPreviewHeight) {
    previewHeight = maxPreviewHeight;
    previewWidth = previewHeight * (larguraMm / alturaMm);
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pré-visualização',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Visual aproximado da etiqueta impressa para o tipo selecionado.',
          style: TextStyle(
            fontSize: 13.5,
            color: muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tamanho atual: ${larguraMm.toStringAsFixed(0)} x ${alturaMm.toStringAsFixed(0)} mm',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: muted,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: shell,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: buildEtiquetaPreview(config),
            ),
          ),
        ),
      ],
    ),
  );
}