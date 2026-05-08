// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_layout_preset.dart';

import 'empresa_preview_v2.dart';
import 'produto_preview_v2.dart';
import 'qr_design_v2.dart';
import 'info_somente_linha_v2.dart';
import 'conteudo_com_lateral_v2.dart';
import 'imagem_design_v2.dart';
import 'tabela_nutricional_design_v2.dart';

class _PreviewLayoutV2 {
  final double outerPad;
  final double qrSize;
  final double qrGap;
  final double empresaBoxHeight;
  final double produtoBoxHeight;
  final double brandHeight;
  final double dividerGap;
  final double infoTopGap;
  final double infoBottomGap;

  const _PreviewLayoutV2({
    required this.outerPad,
    required this.qrSize,
    required this.qrGap,
    required this.empresaBoxHeight,
    required this.produtoBoxHeight,
    required this.brandHeight,
    required this.dividerGap,
    required this.infoTopGap,
    required this.infoBottomGap,
  });

  factory _PreviewLayoutV2.fromPreset(EtiquetaLayoutPreset preset) {
    switch (preset) {
      case EtiquetaLayoutPreset.mm60x40:
        return const _PreviewLayoutV2(
          outerPad: 6,
          qrSize: 56,
          qrGap: 6,
          empresaBoxHeight: 28,
          produtoBoxHeight: 30,
          brandHeight: 10,
          dividerGap: 3,
          infoTopGap: 4,
          infoBottomGap: 3,
        );

      case EtiquetaLayoutPreset.mm100x80:
        return const _PreviewLayoutV2(
          outerPad: 10,
          qrSize: 84,
          qrGap: 8,
          empresaBoxHeight: 42,
          produtoBoxHeight: 44,
          brandHeight: 14,
          dividerGap: 5,
          infoTopGap: 6,
          infoBottomGap: 6,
        );
    }
  }
}

Widget buildEtiquetaPreviewV2(
  DesignEtiquetaV2Model config, {
  required bool isInvalid,
  String? errorMessage,
}) {
  final camposOrdenados = [...config.campos]
    ..sort((a, b) => a.ordem.compareTo(b.ordem));

  final camposPreview = camposOrdenados.where((c) => c.visivel).toList();

  final empresaCampo = _findCampoV2(camposPreview, 'empresa');
  final produtoCampo = _findCampoV2(camposPreview, 'produto');
  final hasQr = camposPreview.any((e) => e.tipo == CampoDesignV2Tipo.qrcode);

  final imagemCampo = camposPreview.any((e) => e.tipo == CampoDesignV2Tipo.imagem)
      ? camposPreview.firstWhere((e) => e.tipo == CampoDesignV2Tipo.imagem)
      : null;

  final tabelaCampo = _findCampoV2(camposPreview, 'tabela_nutricional');

  final infoCampos = camposPreview.where((campo) {
    if (campo.tipo == CampoDesignV2Tipo.qrcode) return false;
    if (campo.tipo == CampoDesignV2Tipo.blocoEmpresa) return false;
    if (campo.tipo == CampoDesignV2Tipo.produto) return false;
    if (campo.tipo == CampoDesignV2Tipo.imagem) return false;
    if (campo.id == 'tabela_nutricional') return false;
    return true;
  }).toList();

  final layout = _PreviewLayoutV2.fromPreset(config.preset);
  final is100x80 = config.preset == EtiquetaLayoutPreset.mm100x80;
  final brandFontSize = config.preset == EtiquetaLayoutPreset.mm60x40 ? 10.0 : 11.0;

  return DefaultTextStyle(
    style: const TextStyle(
      fontFamily: 'RobotoMono',
      color: Colors.black,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final contentWidth =
            (totalWidth - (layout.outerPad * 2)).clamp(0.0, totalWidth);

        final qrColumnWidth = hasQr ? layout.qrSize : 0.0;

        final dividerWidth = hasQr
            ? (contentWidth - qrColumnWidth - 6).clamp(60.0, contentWidth)
            : contentWidth;

        final infoWidth = hasQr
            ? (contentWidth - qrColumnWidth - layout.qrGap)
                .clamp(80.0, contentWidth)
            : contentWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.fromLTRB(
            layout.outerPad,
            8,
            layout.outerPad,
            layout.infoBottomGap,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isInvalid
                  ? Colors.red.withOpacity(0.85)
                  : Colors.black.withOpacity(0.05),
              width: isInvalid ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isInvalid
                    ? Colors.red.withOpacity(0.08)
                    : Colors.black.withOpacity(0.03),
                blurRadius: isInvalid ? 10 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (empresaCampo != null)
                          SizedBox(
                            height: layout.empresaBoxHeight,
                            child: buildEmpresaPreviewV2(
                              empresaCampo,
                              config,
                            ),
                          ),
                        const SizedBox(height: 2),
                        if (produtoCampo != null)
                          SizedBox(
                            height: layout.produtoBoxHeight,
                            child: buildProdutoPreviewV2(
                              produtoCampo,
                              config,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasQr) ...[
                    SizedBox(width: layout.qrGap),
                    SizedBox(
                      width: qrColumnWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                            SizedBox(
                              height: layout.brandHeight,
                              child: Text(
                                'TagValida',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: brandFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.78),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: layout.qrSize,
                            height: layout.qrSize,
                            child: buildQrPreviewV2(config),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: layout.dividerGap),

              Container(
                width: dividerWidth,
                height: 0.9,
                color: isInvalid
                    ? Colors.red.withOpacity(0.55)
                    : Colors.black.withOpacity(0.62),
              ),

              SizedBox(height: layout.infoTopGap),

              if (is100x80 && tabelaCampo != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 42,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 10),
                        child: buildInfosSomenteLinhasV2(
                          infoCampos,
                          config: config,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 58,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: buildTabelaNutricionalPreviewV2(width: 200),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: infoWidth,
                  child: imagemCampo != null
                      ? buildConteudoComLateralV2(
                          infoCampos: infoCampos,
                          lateral: buildImagemPreviewV2(imagemCampo),
                          config: config,
                        )
                      : tabelaCampo != null
                          ? buildConteudoComLateralV2(
                              infoCampos: infoCampos,
                              lateral: buildTabelaNutricionalPreviewV2(
                                width: 190,
                              ),
                              config: config,
                            )
                          : buildInfosSomenteLinhasV2(
                              infoCampos,
                              config: config,
                            ),
                ),

              if (!hasQr && config.mostrarMarcaTagValida) ...[
                const SizedBox(height: 4),
                Text(
                  'TagValida',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: brandFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.78),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

CampoDesignEtiquetaV2Model? _findCampoV2(
  List<CampoDesignEtiquetaV2Model> campos,
  String id,
) {
  try {
    return campos.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}