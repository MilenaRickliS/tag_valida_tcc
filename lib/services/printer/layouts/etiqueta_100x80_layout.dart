import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/etiqueta_model.dart';
import '../../../models/user_model.dart';
import '../../../models/tabela_nutricional_model.dart';
import '../../../models/design_etiqueta_model.dart';

import '../tspl_writer.dart';
import '../tspl_font_spec.dart';
import '../tspl_text_utils.dart';

class Etiqueta100x80Layout {
  String build({
    required DesignEtiquetaModel design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) {
    final tabela = etiqueta.tabelaNutricional;

    final temTabela = tabela != null;

    final w = TsplWriter();

    final qtdCopias = copias <= 0 ? 1 : copias;

    final produto = cleanTsplText(etiqueta.produtoNome, max: 40);
    final validade = DateFormat('dd/MM/yyyy').format(etiqueta.dataValidade);
    final fabricacao = DateFormat('dd/MM/yyyy').format(etiqueta.dataFabricacao);
    final quantidade = formatNumber(etiqueta.quantidade);
    final lote = cleanTsplText(etiqueta.lote ?? '', max: 24);
    final empresa = _buildEmpresaText(usuario, compact: false);

    w.setup(larguraMm: 100, alturaMm: 80);

    const outerLeft = 26;
    const outerTop = 16;
    const outerWidth = 748;
    const outerHeight = 608;
    const padding = 16;

    const qrX = 664;
    const qrY = 42;

    const headerTextLeft = outerLeft + padding;
    const headerTextRight = qrX - 24;
    const headerTextWidth = headerTextRight - headerTextLeft;

    const dividerY = 174;
    const contentTop = 190;
    const contentBottom = outerTop + outerHeight - 12;
    const contentHeight = contentBottom - contentTop;

    const leftColX = outerLeft + padding;
    final leftColW = temTabela ? 246 : 600;

    const separatorX = 378;

    const rightColX = 380;
    const rightColW = 420;

    _addMultiLineTextStyled(
      w: w,
      text: empresa,
      xBase: headerTextLeft,
      y: outerTop + 8,
      maxWidth: headerTextWidth,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      align: TextAlign.left,
      isBold: false,
      maxLines: 3,
      hardRightLimit: headerTextRight,
    );

    _addMultiLineTextStyled(
      w: w,
      text: produto,
      xBase: headerTextLeft,
      y: outerTop + 64,
      maxWidth: headerTextWidth,
      spec: const TsplFontSpec(font: '3', xMul: 1, yMul: 1),
      align: TextAlign.left,
      isBold: true,
      maxLines: 2,
      hardRightLimit: headerTextRight,
    );

    w.text(
      x: qrX + 18,
      y: outerTop + 8,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: 'TagValida',
      isBold: true,
    );

    w.qrCode(
      x: qrX,
      y: qrY,
      module: 4,
      data: qrData,
    );

    w.bar(
      x: outerLeft + 4,
      y: dividerY,
      width: outerWidth - 8,
      height: 2,
    );

    if (temTabela) {
      w.bar(
        x: separatorX,
        y: contentTop,
        width: 2,
        height: contentHeight,
      );
    }

    int y = contentTop + 10;
    final limiteInferiorEsquerda = contentBottom - 8;

    bool cabe(int proxY) => proxY <= limiteInferiorEsquerda;

    int proximo;

    proximo = _printLinhaCampo(
      w: w,
      x: leftColX,
      y: y,
      label: 'Fab.:',
      value: fabricacao,
    );
    if (cabe(proximo)) y = proximo;

    proximo = _printLinhaCampo(
      w: w,
      x: leftColX,
      y: y,
      label: 'Val.:',
      value: validade,
      bold: true,
    );
    if (cabe(proximo)) y = proximo;

    proximo = _printLinhaCampo(
      w: w,
      x: leftColX,
      y: y,
      label: 'Lote:',
      value: lote.isEmpty ? '-' : lote,
    );
    if (cabe(proximo)) y = proximo;

    proximo = _printLinhaCampo(
      w: w,
      x: leftColX,
      y: y,
      label: 'Qtd.:',
      value: quantidade,
    );
    if (cabe(proximo)) y = proximo;

    if (etiqueta.categoriaNome.trim().isNotEmpty) {
      proximo = _printLinhaCampo(
        w: w,
        x: leftColX,
        y: y,
        label: 'Categoria:',
        value: cleanTsplText(etiqueta.categoriaNome, max: 18),
      );
      if (cabe(proximo)) y = proximo;
    }

    if (etiqueta.setorNome.trim().isNotEmpty) {
      proximo = _printLinhaCampo(
        w: w,
        x: leftColX,
        y: y,
        label: 'Setor:',
        value: cleanTsplText(etiqueta.setorNome, max: 18),
      );
      if (cabe(proximo)) y = proximo;
    }

    final custom = Map<String, dynamic>.from(etiqueta.camposCustomValores);

    String? ingredientes;
    String? alergenicos;

    for (final entry in custom.entries) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;

      String texto = '';

      if (value is Map) {
        texto = (value['value'] ?? '').toString().trim();
      } else if (value != null) {
        texto = value.toString().trim();
      }

      if (texto.isEmpty) continue;

      if (key.contains('ingred')) {
        ingredientes = texto;
      } else if (key.contains('alerg')) {
        alergenicos = texto;
      }
    }

    if (ingredientes != null &&
        ingredientes.trim().isNotEmpty &&
        y + 38 < limiteInferiorEsquerda) {
      y += 6;

      w.text(
        x: leftColX,
        y: y,
        spec: const TsplFontSpec(font: '2', xMul: 1, yMul: 1),
        text: 'INGREDIENTES',
        isBold: true,
      );

      y += 20;

      final novoY = _addMultiLineTextStyled(
        w: w,
        text: ingredientes,
        xBase: leftColX,
        y: y,
        maxWidth: leftColW - 18,
        spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
        align: TextAlign.left,
        isBold: false,
        maxLines: 5,
        hardRightLimit: separatorX - 10,
      );

      if (novoY <= limiteInferiorEsquerda) {
        y = novoY;
      }
    }

    if (alergenicos != null &&
        alergenicos.trim().isNotEmpty &&
        y + 38 < limiteInferiorEsquerda) {
      y += 8;

      w.text(
        x: leftColX,
        y: y,
        spec: const TsplFontSpec(font: '2', xMul: 1, yMul: 1),
        text: 'ALERGENICOS',
        isBold: true,
      );

      y += 20;

      final novoY = _addMultiLineTextStyled(
        w: w,
        text: alergenicos,
        xBase: leftColX,
        y: y,
        maxWidth: leftColW - 18,
        spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
        align: TextAlign.left,
        isBold: false,
        maxLines: 4,
        hardRightLimit: separatorX - 10,
      );

      if (novoY <= limiteInferiorEsquerda) {
        y = novoY;
      }
    }

    if (temTabela) {
      _printTabelaNutricional100x80(
        w: w,
        x: rightColX,
        y: contentTop + 2,
        width: rightColW,
        tabela: tabela,
      );
    }

    w.print(copias: qtdCopias);

    return w.toString();
  }

  int _printLinhaCampo({
    required TsplWriter w,
    required int x,
    required int y,
    required String label,
    required String value,
    bool bold = false,
  }) {
    w.text(
      x: x,
      y: y,
      spec: const TsplFontSpec(font: '2', xMul: 1, yMul: 1),
      text: cleanTsplText('$label $value', max: 52),
      isBold: bold,
    );

    return y + 22;
  }

  void _printTabelaNutricional100x80({
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

    w.text(
      x: col2,
      y: headerY,
      spec: bodyFont,
      text: '100g',
      isBold: true,
    );

    w.text(
      x: col3,
      y: headerY,
      spec: bodyFont,
      text: porcaoLabel,
      isBold: true,
    );

    w.text(
      x: col4,
      y: headerY,
      spec: bodyFont,
      text: '%VD',
      isBold: true,
    );

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

    w.bar(
      x: tableLeft + 190,
      y: verticalTop,
      width: 1,
      height: verticalHeight,
    );

    w.bar(
      x: tableLeft + 290,
      y: verticalTop,
      width: 1,
      height: verticalHeight,
    );

    w.bar(
      x: tableLeft + 380,
      y: verticalTop,
      width: 1,
      height: verticalHeight,
    );

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
      isBold: false,
    );

    w.text(
      x: c100X,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: _fmtNutriComUnidade(valor100, unidade),
      isBold: false,
    );

    w.text(
      x: porcaoX,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: _fmtNutriComUnidade(valorPorcao, unidade),
      isBold: false,
    );

    w.text(
      x: vdX,
      y: y,
      spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
      text: (mostrarTracoNoVd && vd <= 0) ? '-' : '${vd.round()}%',
      isBold: false,
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

    final linhas = maxLines == null
        ? linhasFinais
        : linhasFinais.take(maxLines).toList();

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

  String _buildEmpresaText(UserModel usuario, {bool compact = false}) {
    final razao = usuario.razao.trim().isNotEmpty
        ? usuario.razao.trim()
        : usuario.nome.trim();

    final cnpj = usuario.cnpj.trim();

    final ruaNumero = [
      usuario.rua.trim(),
      usuario.numero.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

    final cidadeUf = [
      usuario.cidade.trim(),
      usuario.estado.trim(),
    ].where((e) => e.isNotEmpty).join('-');

    if (compact) {
      final linhas = <String>[
        razao,
        if (cnpj.isNotEmpty) 'CNPJ: $cnpj',
        if (ruaNumero.isNotEmpty || cidadeUf.isNotEmpty)
          [ruaNumero, cidadeUf].where((e) => e.isNotEmpty).join(' • '),
      ];

      return linhas.join('\n');
    }

    final local = [
      usuario.cep.trim(),
      cidadeUf,
    ].where((e) => e.isNotEmpty).join(' ');

    final endereco = [ruaNumero, local].where((e) => e.isNotEmpty).join(', ');

    final linhas = <String>[
      razao,
      if (cnpj.isNotEmpty) 'CNPJ: $cnpj',
      if (endereco.isNotEmpty) endereco,
    ];

    return linhas.join('\n');
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