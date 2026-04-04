import 'design_etiqueta_model.dart';
import 'design_validacao_model.dart';

class DesignEtiquetaLimiter {
  static const double horizontalPaddingMm = 2.0;
  static const double verticalPaddingMm = 2.0;
  static const double blocoGapMm = 0.6;
  static const double linhaGapMm = 0.3;
  static const double bordaInternaExtraMm = 0.5;

  static DesignValidationResult validate(DesignEtiquetaModel config) {
    final campos = [...config.campos]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final visiveis = campos.where((c) => c.visivel).toList();

    final empresaCampo = _findCampo(visiveis, 'empresa');
    final produtoCampo = _findCampo(visiveis, 'produto');
    final hasQr = visiveis.any((c) => c.tipo == CampoDesignTipo.qrcode);
    final hasImagem = visiveis.any((c) => c.tipo == CampoDesignTipo.imagem);
    final hasTabela = visiveis.any((c) => c.id == 'tabela_nutricional');

    final infoCampos = visiveis.where((campo) {
      if (campo.tipo == CampoDesignTipo.qrcode) return false;
      if (campo.tipo == CampoDesignTipo.blocoEmpresa) return false;
      if (campo.tipo == CampoDesignTipo.produto) return false;
      if (campo.tipo == CampoDesignTipo.imagem) return false;
      if (campo.id == 'tabela_nutricional') return false;
      return true;
    }).toList();

    final availableHeight = config.alturaMm - (verticalPaddingMm * 2);
    double usedHeight = 0;

    double topBlockHeight = 0;

    if (empresaCampo != null) {
      final empresaTextHeight = _estimateTextBlockHeightMm(
        fontSizePt: empresaCampo.fontSize.clamp(8, 13),
        lines: 1,
        lineHeightFactor: 1.0,
      );

      final empresaLogoHeight = config.mostrarLogo ? 8.0 : 0.0;
      topBlockHeight = empresaTextHeight > empresaLogoHeight
          ? empresaTextHeight
          : empresaLogoHeight;
    }

    if (produtoCampo != null) {
      final produtoHeight = _estimateTextBlockHeightMm(
        fontSizePt: produtoCampo.fontSize.clamp(16, 28),
        lines: 1,
        lineHeightFactor: 1.0,
      );

      if (topBlockHeight > 0) {
        topBlockHeight += blocoGapMm;
      }
      topBlockHeight += produtoHeight;
    }

    if (hasQr) {
      final qrHeight = config.larguraMm >= 100 ? 14.0 : 10.0;
      topBlockHeight = topBlockHeight > qrHeight ? topBlockHeight : qrHeight;
    }

    if (topBlockHeight > 0) {
      usedHeight += topBlockHeight;
      usedHeight += blocoGapMm;
    }

    double bottomBlockHeight = 0;

    if (hasImagem || hasTabela) {
      final lateralHeight = hasTabela ? 16.0 : 12.0;

      double infoHeight = 0;
      for (final campo in infoCampos) {
        final lines =
            (campo.id == 'ingredientes' || campo.id == 'alergenicos') ? 2 : 1;

        infoHeight += _estimateTextBlockHeightMm(
          fontSizePt: campo.fontSize.clamp(10, 18),
          lines: lines,
          lineHeightFactor: 1.0,
        );
        infoHeight += linhaGapMm;
      }

      bottomBlockHeight =
          infoHeight > lateralHeight ? infoHeight : lateralHeight;
      bottomBlockHeight += 2.0;
    } else {
      for (final campo in infoCampos) {
        final lines =
            (campo.id == 'ingredientes' || campo.id == 'alergenicos') ? 2 : 1;

        bottomBlockHeight += _estimateTextBlockHeightMm(
          fontSizePt: campo.fontSize.clamp(10, 18),
          lines: lines,
          lineHeightFactor: 1.0,
        );
        bottomBlockHeight += linhaGapMm;
      }

      bottomBlockHeight += 2.0;
    }

    if (bottomBlockHeight > 0) {
      usedHeight += bottomBlockHeight;
    }

    if (config.mostrarBordaInterna) {
      usedHeight += bordaInternaExtraMm;
    }

    final maxInfoCampos = _maxInfoCamposForSize(
      larguraMm: config.larguraMm,
      alturaMm: config.alturaMm,
      hasImagem: hasImagem,
      hasTabela: hasTabela,
    );

    if (infoCampos.length > maxInfoCampos) {
      return DesignValidationResult.invalid(
        message:
            'Quantidade de informações em linha acima do permitido para este tamanho de etiqueta.',
        usedHeight: usedHeight,
        availableHeight: availableHeight,
        visibleCount: infoCampos.length,
        blockingFields: infoCampos.map((e) => e.nome).toList(),
      );
    }

    final isEtiqueta60x40 =
        config.larguraMm <= 60.5 && config.alturaMm <= 40.5;
    final toleranciaMm = isEtiqueta60x40 ? 6.0 : 3.0;

    if (usedHeight > availableHeight + toleranciaMm) {
      final excesso = usedHeight - availableHeight;

      return DesignValidationResult.invalid(
        message:
            'As informações ultrapassam o limite da etiqueta em ${excesso.toStringAsFixed(1)} mm. Reduza a fonte, remova campos ou aumente a altura.',
        usedHeight: usedHeight,
        availableHeight: availableHeight,
        visibleCount: infoCampos.length,
        blockingFields: infoCampos.map((e) => e.nome).toList(),
      );
    }

    return DesignValidationResult.valid(
      usedHeight: usedHeight,
      availableHeight: availableHeight,
      visibleCount: infoCampos.length,
    );
  }

  static CampoDesignEtiquetaModel? _findCampo(
    List<CampoDesignEtiquetaModel> campos,
    String id,
  ) {
    try {
      return campos.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static double _estimateTextBlockHeightMm({
    required double fontSizePt,
    required int lines,
    double lineHeightFactor = 1.0,
  }) {
    const mmPerPt = 0.3528;
    return (fontSizePt * mmPerPt * lineHeightFactor * lines) + 0.1;
  }

  static int _maxInfoCamposForSize({
    required double larguraMm,
    required double alturaMm,
    required bool hasImagem,
    required bool hasTabela,
  }) {
    final area = larguraMm * alturaMm;

    int base;
    if (area <= 2400) {
      base = 8;
    } else if (area <= 5000) {
      base = 11;
    } else if (area <= 9000) {
      base = 14;
    } else {
      base = 18;
    }

    if (hasImagem) base -= 2;
    if (hasTabela) base -= 3;

    return base.clamp(4, 20);
  }
}