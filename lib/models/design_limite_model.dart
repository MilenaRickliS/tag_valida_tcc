import 'design_etiqueta_model.dart';
import 'design_validacao_model.dart';

class DesignEtiquetaLimiter {
  static DesignValidationResult validate(DesignEtiquetaModel config) {
    final campos = [...config.campos]..sort((a, b) => a.ordem.compareTo(b.ordem));
    final visiveis = campos.where((c) => c.visivel).toList();

    final empresaCampo = _findCampo(visiveis, 'empresa');
    final produtoCampo = _findCampo(visiveis, 'produto');
    final hasQr = visiveis.any((c) => c.tipo == CampoDesignTipo.qrcode);

    final infoCampos = visiveis.where((campo) {
      if (campo.tipo == CampoDesignTipo.qrcode) return false;
      if (campo.tipo == CampoDesignTipo.blocoEmpresa) return false;
      if (campo.tipo == CampoDesignTipo.produto) return false;
      if (campo.tipo == CampoDesignTipo.imagem) return false;
      if (campo.id == 'tabela_nutricional') return false;
      return true;
    }).toList();

    final larguraMm = config.larguraMm <= 0 ? 60.0 : config.larguraMm;
    final alturaMm = config.alturaMm <= 0 ? 40.0 : config.alturaMm;

    final larguraDots = _mmToDots(larguraMm);
    final alturaDots = _mmToDots(alturaMm);
    final is60x40 = larguraMm <= 60.5 && alturaMm <= 40.5;

    final outerPad = _mmToDots(is60x40 ? 3.2 : 2.8);
    final innerPad = _mmToDots(is60x40 ? 2.4 : 2.6);

    final qrVisualSize = hasQr ? (is60x40 ? 72 : 126) : 0;
    final qrGap = hasQr ? _mmToDots(2.2) : 0;
    final qrRightSafe = _mmToDots(is60x40 ? 4.0 : 5.0);
    final qrX = hasQr ? (larguraDots - qrRightSafe - qrVisualSize) : 0;

    final textAreaX = outerPad;
    final textAreaRight = hasQr
        ? (qrX - _mmToDots(is60x40 ? 3.0 : 4.0))
        : (larguraDots - outerPad);

    final textAreaWidth = (textAreaRight - textAreaX).clamp(
      _mmToDots(16.0),
      larguraDots,
    );

    int y = outerPad;
    final blocking = <String>[];

   
    if (empresaCampo != null) {
      final empresaFont = is60x40 ? 7.0 : 9.0;
      final empresaSpec = _fontSpecFromPt(empresaFont, compact: is60x40);

      final empresaLines = _estimatedWrappedLines(
        text: 'JR SILVERIO E SILVERIO LTDA\nCNPJ: 12.123.456/0001-00',
        maxWidth: textAreaWidth,
        spec: empresaSpec,
        maxLines: is60x40 ? 2 : 3,
      );

      final empresaBoxHeight = is60x40 ? 38 : 54;
      final empresaUsedHeight = empresaLines * _lineHeight(empresaSpec);

      if (empresaUsedHeight > empresaBoxHeight) {
        blocking.add(empresaCampo.nome);
      }

      y += empresaBoxHeight;
    }

    if (produtoCampo != null) {
      final produtoFont = is60x40
          ? produtoCampo.fontSize.clamp(7.0, 8.0)
          : produtoCampo.fontSize.clamp(8.0, 14.0);

      final produtoSpec = _fontSpecFromPt(produtoFont, compact: is60x40);

      final produtoLines = _estimatedWrappedLines(
        text: 'Pao Frances Tradicional',
        maxWidth: textAreaWidth,
        spec: produtoSpec,
        maxLines: 2,
      );

      final produtoBoxHeight = is60x40 ? 42 : 58;
      final produtoUsedHeight = produtoLines * _lineHeight(produtoSpec);

      if (produtoUsedHeight > produtoBoxHeight) {
        blocking.add(produtoCampo.nome);
      }

      y += produtoBoxHeight;
    }

   
    final dividerY = y + _mmToDots(0.8);

    final blocoY1 = dividerY + _mmToDots(1.4);
    int infoY = blocoY1 + innerPad;

    final infoX = outerPad + innerPad;
    final infoRightLimit = hasQr
        ? (qrX - qrGap - _mmToDots(2.0))
        : (larguraDots - outerPad - innerPad);

    final infoWidth = (infoRightLimit - infoX).clamp(
      _mmToDots(16.0),
      larguraDots,
    );

    
    final infoBottomLimit = is60x40
        ? (alturaDots - _mmToDots(2.0))
        : (alturaDots - outerPad - innerPad);

    for (final campo in infoCampos) {
      final font = _resolvedFontForCampo(campo, is60x40: is60x40);
      final spec = _fontSpecFromPt(font, compact: is60x40);

      final sampleText = _sampleTextForCampo(campo);

      final lines = _estimatedWrappedLines(
        text: sampleText,
        maxWidth: infoWidth,
        spec: spec,
        maxLines: _maxLinesForCampo(campo),
      );

      final lineHeight = lines * _lineHeight(spec);
      final gap = _mmToDots(0.5);

      final nextY = infoY + lineHeight + gap;

      if (nextY > infoBottomLimit) {
        blocking.add(campo.nome);
      } else {
        infoY = nextY;
      }
    }

    final usedHeightMm = _dotsToMm(infoY);
    final availableHeightMm = _dotsToMm(infoBottomLimit);

    if (blocking.isNotEmpty) {
      return DesignValidationResult.invalid(
        message: _buildValidationMessage(blocking),
        usedHeight: usedHeightMm,
        availableHeight: availableHeightMm,
        visibleCount: visiveis.length,
        blockingFields: blocking,
      );
    }

    return DesignValidationResult.valid(
      usedHeight: usedHeightMm,
      availableHeight: availableHeightMm,
      visibleCount: visiveis.length,
    );
  }

  static String _buildValidationMessage(List<String> blocking) {
    if (blocking.isEmpty) {
      return 'O layout não cabe neste tamanho de etiqueta.';
    }

    if (blocking.length == 1) {
      return 'O campo "${blocking.first}" não cabe neste tamanho de etiqueta.';
    }

    final lista = blocking.take(3).join(', ');
    return 'Alguns campos não cabem neste tamanho de etiqueta: $lista.';
  }

  static double _resolvedFontForCampo(
    CampoDesignEtiquetaModel campo, {
    required bool is60x40,
  }) {
    if (is60x40) {
      if (campo.id == 'empresa') return 7.0;
      if (campo.id == 'produto') return campo.fontSize.clamp(7.0, 8.0);
      if (campo.id == 'validade') return campo.fontSize.clamp(6.0, 8.0);
      return campo.fontSize.clamp(6.0, 7.0);
    }

    if (campo.id == 'empresa') return 9.0;
    if (campo.id == 'produto') return campo.fontSize.clamp(8.0, 14.0);
    return campo.fontSize.clamp(6.0, 18.0);
  }

  static int _maxLinesForCampo(CampoDesignEtiquetaModel campo) {
    if (campo.id == 'ingredientes' ||
        campo.id == 'alergenicos' ||
        campo.id == 'observacao') {
      return 2;
    }

    return 1;
  }

  static String _sampleTextForCampo(CampoDesignEtiquetaModel campo) {
    switch (campo.id) {
      case 'categoria':
        return 'CATEGORIA: Pao';
      case 'fabricacao':
        return 'FABRICACAO: 15/03/2026';
      case 'validade':
        return 'VALIDADE: 22/03/2026 !VENCIDO';
      case 'setor':
        return 'SETOR: Paes';
      case 'quantidade':
        return 'QUANTIDADE: 5';
      case 'lote':
        return 'LOTE: A2D3FD20';
      case 'observacao':
        return 'OBSERVACAO: feito por alice';
      case 'preco':
        return 'PRECO: R\$ 20,00';
      case 'ingredientes':
        return 'INGREDIENTES: farinha, agua, sal';
      case 'alergenicos':
        return 'ALERGENICOS: contem gluten';
      default:
        final prefixo = (campo.labelImpresso ?? campo.nome).trim();
        return prefixo.isEmpty ? campo.nome : '$prefixo: EXEMPLO';
    }
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

  static _TsplFontSpec _fontSpecFromPt(double pt, {bool compact = false}) {
    final value = pt.clamp(6.0, 28.0);

    if (compact) {
      if (value <= 7) return const _TsplFontSpec(font: '1', xMul: 1, yMul: 1);
      if (value <= 9) return const _TsplFontSpec(font: '2', xMul: 1, yMul: 1);
      if (value <= 12) return const _TsplFontSpec(font: '2', xMul: 1, yMul: 2);
      if (value <= 15) return const _TsplFontSpec(font: '3', xMul: 1, yMul: 1);
      if (value <= 18) return const _TsplFontSpec(font: '3', xMul: 1, yMul: 2);
      return const _TsplFontSpec(font: '4', xMul: 1, yMul: 1);
    }

    if (value <= 7) return const _TsplFontSpec(font: '1', xMul: 1, yMul: 1);
    if (value <= 9) return const _TsplFontSpec(font: '2', xMul: 1, yMul: 1);
    if (value <= 11) return const _TsplFontSpec(font: '2', xMul: 1, yMul: 2);
    if (value <= 14) return const _TsplFontSpec(font: '3', xMul: 1, yMul: 1);
    if (value <= 17) return const _TsplFontSpec(font: '3', xMul: 2, yMul: 1);
    if (value <= 21) return const _TsplFontSpec(font: '3', xMul: 2, yMul: 2);
    return const _TsplFontSpec(font: '4', xMul: 1, yMul: 1);
  }

  static int _estimatedWrappedLines({
    required String text,
    required int maxWidth,
    required _TsplFontSpec spec,
    required int maxLines,
  }) {
    final blocos = text.split('\n');
    final linhas = <String>[];

    for (final bloco in blocos) {
      linhas.addAll(
        _wrapText(
          bloco,
          maxChars: _estimateCharsPerLine(spec, maxWidth),
        ),
      );
    }

    final total = linhas.take(maxLines).length;
    return total <= 0 ? 1 : total;
  }

  static List<String> _wrapText(String text, {required int maxChars}) {
    if (text.length <= maxChars) return [text];

    final words = text.split(' ');
    final lines = <String>[];
    var current = '';

    for (final word in words) {
      final test = current.isEmpty ? word : '$current $word';
      if (test.length <= maxChars) {
        current = test;
      } else {
        if (current.isNotEmpty) lines.add(current);
        current = word;
      }
    }

    if (current.isNotEmpty) lines.add(current);
    return lines;
  }

  static int _estimateCharsPerLine(_TsplFontSpec spec, int maxWidth) {
    final baseCharWidth = switch (spec.font) {
      '1' => 7,
      '2' => 8,
      '3' => 10,
      '4' => 13,
      _ => 8,
    };

    final charWidth = baseCharWidth * spec.xMul;
    final value = maxWidth ~/ charWidth;
    return value < 6 ? 6 : value;
  }

  static int _lineHeight(_TsplFontSpec spec) {
    final baseHeight = switch (spec.font) {
      '1' => 16,
      '2' => 20,
      '3' => 24,
      '4' => 30,
      _ => 20,
    };

    return baseHeight * spec.yMul;
  }

  static int _mmToDots(double mm) => (mm * 8).round();

  static double _dotsToMm(int dots) => dots / 8.0;
}

class _TsplFontSpec {
  final String font;
  final int xMul;
  final int yMul;

  const _TsplFontSpec({
    required this.font,
    required this.xMul,
    required this.yMul,
  });
}