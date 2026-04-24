import 'package:flutter/material.dart';

import '../../../models/tabela_nutricional_model.dart';
import '../tspl_font_spec.dart';
import '../tspl_text_utils.dart';
import '../tspl_writer.dart';

class TabelaNutricional100x80Layout {
  void build({
    required TsplWriter w,
    required int x,
    required int y,
    required int width,
    required TabelaNutricionalModel tabela,
  }) {
    const titleFont = TsplFontSpec(font: '1', xMul: 1, yMul: 1);
    const bodyFont = TsplFontSpec(font: '1', xMul: 1, yMul: 1);

    final porcaoLabel = '${tabela.porcao}g';
    final medidaCaseira =
        '${tabela.quantidadeMedida} ${tabela.medidaCaseira}'.trim();

    final tableLeft = x;
    final tableTop = y;
    final tableWidth = width;
    const tableHeight = 560;

    final tableRight = tableLeft + tableWidth;
    final tableBottom = tableTop + tableHeight;

    final col1 = tableLeft + 8;
    final col2 = tableLeft + 200;
    final col3 = tableLeft + 300;
    final col4 = tableLeft + 390;

    final tituloY = y + 5;
    final tituloDividerY = y + 24;
    final info1Y = y + 30;
    final info2Y = y + 46;
    final infoDividerY = y + 64;
    final headerY = y + 70;
    int rowY = y + 88;

    w.box(
      left: tableLeft,
      top: tableTop,
      right: tableRight,
      bottom: tableBottom,
      thickness: 1,
    );

    const titulo = 'INFORMACAO NUTRICIONAL';

    final tituloX = _resolveAlignedX(
      align: TextAlign.center,
      xBase: tableLeft,
      containerWidth: tableWidth,
      text: titulo,
      spec: titleFont,
    );

    w.text(
      x: tituloX,
      y: tituloY,
      spec: titleFont,
      text: titulo,
      isBold: true,
    );

    w.bar(
      x: tableLeft + 4,
      y: tituloDividerY,
      width: tableRight - tableLeft - 8,
      height: 1,
    );

    w.text(
      x: tableLeft + 8,
      y: info1Y,
      spec: bodyFont,
      text: 'Porcao: $porcaoLabel ($medidaCaseira)',
      isBold: true,
    );

    w.text(
      x: tableLeft + 8,
      y: info2Y,
      spec: bodyFont,
      text: 'Porcoes por emb.: ${tabela.porcoesPorEmbalagem}',
      isBold: true,
    );

    w.bar(
      x: tableLeft + 4,
      y: infoDividerY,
      width: tableRight - tableLeft - 8,
      height: 2,
    );

    w.text(x: col2, y: headerY, spec: bodyFont, text: '100g', isBold: true);
    w.text(x: col3, y: headerY, spec: bodyFont, text: porcaoLabel, isBold: true);
    w.text(x: col4, y: headerY, spec: bodyFont, text: '%VD', isBold: true);

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Valor energetico',
      valorPorcao: tabela.valorEnergetico,
      vdRef: 2000,
      porcaoBase: tabela.porcao,
      unidade: 'kcal',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Carboidratos',
      valorPorcao: tabela.carboidratos,
      vdRef: 300,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1 + 8,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Acucares totais',
      valorPorcao: tabela.acucaresTotais,
      vdRef: 50,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1 + 8,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Acuc. adicionados',
      valorPorcao: tabela.acucaresAdicionados,
      vdRef: 50,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Proteinas',
      valorPorcao: tabela.proteinas,
      vdRef: 50,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Gorduras totais',
      valorPorcao: tabela.gordurasTotais,
      vdRef: 55,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1 + 8,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Gord. saturadas',
      valorPorcao: tabela.gordurasSaturadas,
      vdRef: 22,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1 + 8,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Gord. trans',
      valorPorcao: tabela.gordurasTrans,
      vdRef: 2,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Fibras alimentares',
      valorPorcao: tabela.fibraAlimentar,
      vdRef: 25,
      porcaoBase: tabela.porcao,
      unidade: 'g',
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    rowY = _printNutriRow(
      w: w,
      y: rowY,
      labelX: col1,
      c100X: col2,
      porcaoX: col3,
      vdX: col4,
      label: 'Sodio',
      valorPorcao: tabela.sodio,
      vdRef: 2000,
      porcaoBase: tabela.porcao,
      unidade: 'mg',
      linhaFinalGrossa: true,
      lineStartX: tableLeft + 2,
      lineWidth: tableWidth - 4,
    );

    final verticalTop = y + 88;
    final verticalHeight = (rowY - 6) - verticalTop;

    w.bar(x: tableLeft + 190, y: verticalTop, width: 1, height: verticalHeight);
    w.bar(x: tableLeft + 290, y: verticalTop, width: 1, height: verticalHeight);
    w.bar(x: tableLeft + 380, y: verticalTop, width: 1, height: verticalHeight);

    _addMultiLineTextStyled(
      w: w,
      text:
          '* Percentual de valores diarios fornecidos por porcao, com base em uma dieta de 2000 kcal. Seus valores podem ser diferentes dependendo de suas necessidades energeticas.',
      xBase: tableLeft + 6,
      y: rowY + 8,
      maxWidth: tableWidth - 130,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      align: TextAlign.left,
      isBold: false,
      maxLines: 12,
      hardRightLimit: tableRight - 8,
    );
  }

  int _printNutriRow({
    required TsplWriter w,
    required int y,
    required int labelX,
    required int c100X,
    required int porcaoX,
    required int vdX,
    required String label,
    required double valorPorcao,
    required double vdRef,
    required String porcaoBase,
    required String unidade,
    required int lineStartX,
    required int lineWidth,
    bool linhaFinalGrossa = false,
  }) {
    final valor100 = _calcPor100(valorPorcao, porcaoBase);
    final vd = _calcVD(valorPorcao, vdRef);

    final labelLower = label.toLowerCase();
    final mostrarTracoNoVd =
        labelLower.contains('acuc. adicionados') ||
        labelLower.contains('gord. trans');

    w.text(
      x: labelX,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: cleanTsplText(label, max: 24),
    );

    w.text(
      x: c100X,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: _fmtNutriComUnidade(valor100, unidade),
    );

    w.text(
      x: porcaoX,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: _fmtNutriComUnidade(valorPorcao, unidade),
    );

    w.text(
      x: vdX,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: (mostrarTracoNoVd && vd <= 0) ? '-' : '${vd.round()}%',
    );

    final nextY = y + 18;

    w.bar(
      x: lineStartX,
      y: nextY,
      width: lineWidth,
      height: linhaFinalGrossa ? 2 : 1,
    );

    return nextY + 6;
  }

  int _addMultiLineTextStyled({
    required TsplWriter w,
    required String text,
    required int xBase,
    required int y,
    required int maxWidth,
    required TsplFontSpec spec,
    required TextAlign align,
    required bool isBold,
    int? maxLines,
    int? hardRightLimit,
  }) {
    final blocos = text.split('\n');
    final linhasFinais = <String>[];

    for (final bloco in blocos) {
      final wrapped = wrapText(
        cleanTsplText(bloco, max: 180),
        maxChars: estimateCharsPerLine(spec, maxWidth),
      );
      linhasFinais.addAll(wrapped);
    }

    final linhas =
        maxLines == null ? linhasFinais : linhasFinais.take(maxLines).toList();

    var currentY = y;

    for (final linha in linhas) {
      int x = _resolveAlignedX(
        align: align,
        xBase: xBase,
        containerWidth: maxWidth,
        text: linha,
        spec: spec,
      );

      if (hardRightLimit != null) {
        final larguraLinha = estimateTextWidth(linha, spec);
        final maxAllowedX = hardRightLimit - larguraLinha;
        if (x > maxAllowedX) x = maxAllowedX;
        if (x < xBase) x = xBase;
      }

      w.text(
        x: x,
        y: currentY,
        spec: spec,
        text: linha,
        isBold: isBold,
      );

      currentY += lineHeight(spec);
    }

    return currentY;
  }

  int _resolveAlignedX({
    required TextAlign align,
    required int xBase,
    required int containerWidth,
    required String text,
    required TsplFontSpec spec,
  }) {
    final estimatedWidth = estimateTextWidth(text, spec);
    final safeWidth = estimatedWidth.clamp(0, containerWidth);
    const rightPadding = 10;

    switch (align) {
      case TextAlign.center:
        return xBase + ((containerWidth - safeWidth) ~/ 2);
      case TextAlign.right:
        final rightX = xBase + containerWidth - safeWidth - rightPadding;
        return rightX < xBase ? xBase : rightX;
      case TextAlign.left:
      default:
        return xBase;
    }
  }

  double _calcPor100(double valorNaPorcao, String porcao) {
    final base = double.tryParse(porcao.replaceAll(',', '.')) ?? 0;
    if (base <= 0) return 0;
    return (valorNaPorcao / base) * 100;
  }

  double _calcVD(double valorNaPorcao, double vdReferencia) {
    if (vdReferencia <= 0) return 0;
    return (valorNaPorcao / vdReferencia) * 100;
  }

  String _fmtNutri(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _fmtNutriComUnidade(num v, String unidade) {
    return '${_fmtNutri(v)} $unidade';
  }
}