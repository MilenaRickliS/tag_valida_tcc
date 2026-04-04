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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: config.mostrarBordaInterna
            ? Border.all(color: Colors.black.withOpacity(0.12))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: toCrossAxis(
            produtoCampo?.align ?? TextAlign.left,
          ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (empresaCampo != null) buildEmpresaPreviewNovo(empresaCampo, config),
                    const SizedBox(height: 10),
                    if (produtoCampo != null) buildProdutoPreviewNovo(produtoCampo),
                  ],
                ),
              ),
              if (qrCampo) ...[
                const SizedBox(width: 12),
                buildQrPreviewNovo(config),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.14)),
              ),
              child: (imagemCampo != null)
                  ? buildConteudoComLateral(
                      infoCampos: infoCampos,
                      lateral: buildImagemPreviewNovo(imagemCampo),
                    )
                  : (tabelaCampo != null)
                      ? buildConteudoComLateral(
                          infoCampos: infoCampos,
                          lateral: buildTabelaNutricionalPreview(),
                        )
                      : buildInfosSomenteLinhas(infoCampos),
            ),
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
