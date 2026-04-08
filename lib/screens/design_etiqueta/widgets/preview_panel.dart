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
  final etiquetaBg = Colors.white;

  final larguraMm = clampLargura(
    config.larguraMm <= 0 ? 60 : config.larguraMm,
  );
  final alturaMm = clampAltura(
    config.alturaMm <= 0 ? 40 : config.alturaMm,
  );

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

        LayoutBuilder(
          builder: (context, constraints) {
            const double shellPadding = 22;
            const double pixelsPorMm = 3.2;
            const double maxPreviewHeight = 300;

            final larguraBase = larguraMm * pixelsPorMm;
            final alturaBase = alturaMm * pixelsPorMm;

            final larguraDisponivel =
                (constraints.maxWidth - (shellPadding * 2)).clamp(120.0, 520.0);

            double escala = larguraDisponivel / larguraBase;

            final alturaEscalada = alturaBase * escala;
            if (alturaEscalada > maxPreviewHeight) {
              escala = maxPreviewHeight / alturaBase;
            }

            final previewWidth = larguraBase * escala;
            final previewHeight = alturaBase * escala;

            return Center(
              child: Container(
                padding: const EdgeInsets.all(shellPadding),
                decoration: BoxDecoration(
                  color: shell,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: border),
                ),
                child: SizedBox(
                  width: previewWidth,
                  height: previewHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: etiquetaBg,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: buildEtiquetaPreview(config),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}