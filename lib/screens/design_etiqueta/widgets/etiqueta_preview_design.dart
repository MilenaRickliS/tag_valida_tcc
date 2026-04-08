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

Widget buildEtiquetaPreview(DesignEtiquetaModel config) {
  
  final camposVisiveis = [...config.campos]
    ..sort((a, b) => a.ordem.compareTo(b.ordem));

  final camposPreview = camposVisiveis.where((c) => c.visivel).toList();

  final empresaCampo = _findCampo(camposPreview, 'empresa');
  final produtoCampo = _findCampo(camposPreview, 'produto');

  final qrCampo = camposPreview.any((e) => e.tipo == CampoDesignTipo.qrcode);

  final imagemCampo = camposPreview.where((e) => e.tipo == CampoDesignTipo.imagem).isNotEmpty
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

  return DefaultTextStyle(
    style: const TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 10,
      height: 1.05, 
      letterSpacing: -0.2,
    ),
    child: Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
     
      border: null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
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
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (empresaCampo != null)
                      buildEmpresaPreviewNovo(empresaCampo, config),

                    const SizedBox(height: 2),

                    if (produtoCampo != null)
                      buildProdutoPreviewNovo(produtoCampo),
                  ],
                ),
              ),
            ),
            if (qrCampo) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 72,
                height: 72,
                child: Align(
                  alignment: Alignment.topRight,
                  child: buildQrPreviewNovo(config),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 2),

        
        LayoutBuilder(
          builder: (context, constraints) {
            const qrReserva = 82.0;
            final larguraLinha = qrCampo
                ? (constraints.maxWidth - qrReserva).clamp(80.0, double.infinity)
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: larguraLinha,
                height: 0.8,
                color: Colors.black.withOpacity(0.6),
              ),
            );
          },
        ),

        const SizedBox(height: 2),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                        : buildInfosSomenteLinhas(infoCampos, config: config),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        if (config.mostrarMarcaTagValida) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TagVálida',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.72),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ]
      ],
    ),
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