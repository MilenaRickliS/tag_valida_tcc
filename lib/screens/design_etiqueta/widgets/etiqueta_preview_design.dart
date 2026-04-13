// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './empresa_preview.dart';
import './produto_preview.dart';
import './tabela_nutricional_design.dart';
import './qr_design.dart';
import './conteudo_lateral.dart';
import './imagem_design.dart';
import './info_somente_linha.dart';

class _PreviewLayout {
  final double outerPad;
  final double innerPad;
  final double qrSize;
  final double qrRightSafe;
  final double qrGap;
  final double empresaBoxHeight;
  final double produtoBoxHeight;
  final double brandHeight;
  final double dividerGap;
  final double infoTopGap;
  final double infoBottomGap;

  const _PreviewLayout({
    required this.outerPad,
    required this.innerPad,
    required this.qrSize,
    required this.qrRightSafe,
    required this.qrGap,
    required this.empresaBoxHeight,
    required this.produtoBoxHeight,
    required this.brandHeight,
    required this.dividerGap,
    required this.infoTopGap,
    required this.infoBottomGap,
  });

  factory _PreviewLayout.fromConfig(DesignEtiquetaModel config) {
    final is60x40 =
        config.larguraMm <= 60.5 && config.alturaMm <= 40.5;

    if (is60x40) {
      return const _PreviewLayout(
        outerPad: 10,
        innerPad: 7,
        qrSize: 72,
        qrRightSafe: 6,
        qrGap: 8,
        empresaBoxHeight: 40,
        produtoBoxHeight: 44,
        brandHeight: 14,
        dividerGap: 6,
        infoTopGap: 8,
        infoBottomGap: 6,
      );
    }

    return const _PreviewLayout(
      outerPad: 12,
      innerPad: 8,
      qrSize: 92,
      qrRightSafe: 8,
      qrGap: 10,
      empresaBoxHeight: 48,
      produtoBoxHeight: 52,
      brandHeight: 16,
      dividerGap: 6,
      infoTopGap: 8,
      infoBottomGap: 8,
    );
  }
}

Widget buildEtiquetaPreview(
  DesignEtiquetaModel config, {
  required bool isInvalid,
  String? errorMessage,
}) {
  final camposOrdenados = [...config.campos]
    ..sort((a, b) => a.ordem.compareTo(b.ordem));

  final camposPreview = camposOrdenados.where((c) => c.visivel).toList();

  final empresaCampo = _findCampo(camposPreview, 'empresa');
  final produtoCampo = _findCampo(camposPreview, 'produto');
  final hasQr = camposPreview.any((e) => e.tipo == CampoDesignTipo.qrcode);

  final imagemCampo = camposPreview.any((e) => e.tipo == CampoDesignTipo.imagem)
      ? camposPreview.firstWhere((e) => e.tipo == CampoDesignTipo.imagem)
      : null;

  final tabelaCampo = _findCampo(camposPreview, 'tabela_nutricional');

  final infoCampos = camposPreview.where((campo) {
    if (campo.tipo == CampoDesignTipo.qrcode) return false;
    if (campo.tipo == CampoDesignTipo.blocoEmpresa) return false;
    if (campo.tipo == CampoDesignTipo.produto) return false;
    if (campo.tipo == CampoDesignTipo.imagem) return false;
    if (campo.id == 'tabela_nutricional') return false;
    return true;
  }).toList();

  final layout = _PreviewLayout.fromConfig(config);
  final is60x40 = config.larguraMm <= 60.5 && config.alturaMm <= 40.5;

  final empresaPreviewScale = is60x40 ? 2.55 : 2.20;
  final produtoPreviewScale = is60x40 ? 2.45 : 2.15;
  final brandFontSize = is60x40 ? 10.0 : 11.0;

  return DefaultTextStyle(
    style: const TextStyle(
      fontFamily: 'RobotoMono',
      color: Colors.black,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isInvalid) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage ?? 'O conteúdo passou do limite da etiqueta.',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;

          
            final contentWidth = (totalWidth - (layout.outerPad * 2)).clamp(0.0, totalWidth);

            final qrColumnWidth = hasQr ? layout.qrSize : 0.0;

            final dividerWidth = hasQr
                ? (contentWidth - qrColumnWidth - 6).clamp(60.0, contentWidth)
                : contentWidth;

            final infoWidth = hasQr
                ? (contentWidth - qrColumnWidth - layout.qrGap - layout.innerPad)
                    .clamp(80.0, contentWidth)
                : (contentWidth - layout.innerPad).clamp(0.0, contentWidth);

            final empresaPreviewFont =
                ((empresaCampo?.fontSize ?? 7.0) * empresaPreviewScale)
                    .clamp(is60x40 ? 16.0 : 17.0, is60x40 ? 22.0 : 24.0);

            final produtoPreviewFont =
                ((produtoCampo?.fontSize ?? 8.0) * produtoPreviewScale)
                    .clamp(is60x40 ? 17.0 : 18.0, is60x40 ? 24.0 : 28.0);

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
                                child: Align(
                                  alignment: toAlignment(empresaCampo.align),
                                  child: buildEmpresaPreviewNovo(
                                    empresaCampo.copyWith(
                                      fontSize: empresaPreviewFont,
                                    ),
                                    config,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 2),
                            if (produtoCampo != null)
                              SizedBox(
                                height: layout.produtoBoxHeight,
                                child: Align(
                                  alignment: toAlignment(produtoCampo.align),
                                  child: buildProdutoPreviewNovo(
                                    produtoCampo.copyWith(
                                      fontSize: produtoPreviewFont,
                                    ),
                                  ),
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
                              if (config.mostrarMarcaTagValida)
                                SizedBox(
                                  height: layout.brandHeight,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'TagValida',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: brandFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black.withOpacity(0.78),
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: layout.qrSize,
                                height: layout.qrSize,
                                child: buildQrPreviewNovo(config),
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
                  SizedBox(
                    width: infoWidth,
                    child: (imagemCampo != null)
                        ? buildConteudoComLateral(
                            infoCampos: infoCampos,
                            lateral: buildImagemPreviewNovo(imagemCampo),
                            config: config,
                          )
                        : (tabelaCampo != null)
                            ? buildConteudoComLateral(
                                infoCampos: infoCampos,
                                lateral: buildTabelaNutricionalPreview(),
                                config: config,
                              )
                            : buildInfosSomenteLinhas(
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
      ],
    ),
  );
}

CampoDesignEtiquetaModel? _findCampo(
  List<CampoDesignEtiquetaModel> campos,
  String id,
) {
  try {
    return campos.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

Alignment toAlignment(TextAlign align) {
  switch (align) {
    case TextAlign.center:
      return Alignment.center;
    case TextAlign.right:
      return Alignment.centerRight;
    case TextAlign.left:
    default:
      return Alignment.centerLeft;
  }
}

CrossAxisAlignment toCrossAxis(TextAlign align) {
  switch (align) {
    case TextAlign.center:
      return CrossAxisAlignment.center;
    case TextAlign.right:
      return CrossAxisAlignment.end;
    case TextAlign.left:
    default:
      return CrossAxisAlignment.start;
  }
}