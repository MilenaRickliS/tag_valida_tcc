// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/design_etiqueta_model.dart';
import '../../../providers/design_etiqueta_provider.dart';
import './preview_image_widget.dart';

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
  final larguraMm = clampLargura(config.larguraMm <= 0 ? 60 : config.larguraMm);
  final alturaMm = clampAltura(config.alturaMm <= 0 ? 40 : config.alturaMm);

  return LayoutBuilder(
    builder: (context, outerConstraints) {
      final isMobile = MediaQuery.of(context).size.width < 600;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 14 : 20),
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
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w900,
                color: text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Visual aproximado da etiqueta impressa para o tipo selecionado.',
              style: TextStyle(
                fontSize: isMobile ? 12.5 : 13.5,
                color: muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tamanho atual: ${larguraMm.toStringAsFixed(0)} x ${alturaMm.toStringAsFixed(0)} mm',
              style: TextStyle(
                fontSize: isMobile ? 11.5 : 12.5,
                fontWeight: FontWeight.w700,
                color: muted,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final is60x40 = larguraMm <= 60.5 && alturaMm <= 40.5;

                final maxPreviewHeight = isMobile ? 220.0 : 320.0;
                final minPreviewWidth = isMobile ? 180.0 : 240.0;

                double previewWidth;
                double previewHeight;

                if (is60x40) {
                  const double pixelsPorMm = 5.8;
                  previewWidth = larguraMm * pixelsPorMm;
                  previewHeight = alturaMm * pixelsPorMm;
                } else {
                  const double pixelsPorMm = 3.8;
                  previewWidth = larguraMm * pixelsPorMm;
                  previewHeight = alturaMm * pixelsPorMm;
                }

                if (previewWidth < minPreviewWidth) {
                  final factor = minPreviewWidth / previewWidth;
                  previewWidth *= factor;
                  previewHeight *= factor;
                }

                if (previewHeight > maxPreviewHeight) {
                  final factor = maxPreviewHeight / previewHeight;
                  previewWidth *= factor;
                  previewHeight *= factor;
                }

                final designProvider = context.watch<DesignEtiquetaProvider>();
                final isInvalid = designProvider.validation != null &&
                    !designProvider.validation!.ok;

                return SizedBox(
                  height: previewHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: EtiquetaPreviewImageWidget(
                        config: config,
                        isInvalid: isInvalid,
                        errorMessage: designProvider.validation?.message,
                        width: previewWidth,
                        height: previewHeight,
                        borderRadius: 18,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}