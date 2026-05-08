import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_layout_preset.dart';
import '../../../providers/design_etiqueta_v2_provider.dart';
import 'preview_image_widget_v2.dart';

class PreviewPanelV2 extends StatelessWidget {
  final bool isDark;
  final Color card;
  final Color text;
  final Color muted;
  final Color border;
  final DesignEtiquetaV2Model config;
  final List<Widget> actions;

  const PreviewPanelV2({
    super.key,
    required this.isDark,
    required this.card,
    required this.text,
    required this.muted,
    required this.border,
    required this.config,
    this.actions = const [],
  });

  

  @override
  Widget build(BuildContext context) {
    final larguraMm = config.larguraMm;
    final alturaMm = config.alturaMm;

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
                'Visual aproximado da etiqueta impressa para o tamanho selecionado.',
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
                  final is60x40 = config.preset == EtiquetaLayoutPreset.mm60x40;

                  final maxPreviewHeight = isMobile ? 220.0 : 320.0;
                  final minPreviewWidth = isMobile ? 180.0 : 240.0;

                  double previewWidth;
                  double previewHeight;

                  if (is60x40) {
                    const pixelsPorMm = 5.8;
                    previewWidth = larguraMm * pixelsPorMm;
                    previewHeight = alturaMm * pixelsPorMm;
                  } else {
                    const pixelsPorMm = 3.8;
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

                  final designProvider =
                      context.watch<DesignEtiquetaV2Provider>();

                  final isInvalid = designProvider.validation != null &&
                      !designProvider.validation!.ok;

                  return SizedBox(
                    height: previewHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: EtiquetaPreviewImageWidgetV2(
                        config: config,
                        isInvalid: isInvalid,
                        errorMessage: designProvider.validation?.message,
                        width: previewWidth,
                        height: previewHeight,
                        borderRadius: 18,
                      ),
                    ),
                  );
                },
              ),

               if (actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}