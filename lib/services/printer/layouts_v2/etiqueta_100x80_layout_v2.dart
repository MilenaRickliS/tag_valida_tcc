import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_model.dart';
import '../../../models/user_model.dart';

import '../tspl_writer.dart';
import '../tspl_font_spec.dart';
import '../tspl_text_utils.dart';

class Etiqueta100x80LayoutV2 {
  String build({
    required DesignEtiquetaV2Model design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) {
    final w = TsplWriter();
    final qtdCopias = copias <= 0 ? 1 : copias;

    final campos = [...design.campos]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final visiveis = campos.where((c) => c.visivel).toList();
    final hasQr = visiveis.any((c) => c.tipo == CampoDesignV2Tipo.qrcode);
    final hasTabelaNutricional = etiqueta.incluirTabelaNutricional && etiqueta.tabelaNutricional != null;
    final produto = cleanTsplText(etiqueta.produtoNome, max: 42);
    final empresa = _buildEmpresaText(usuario);

    w.setup(larguraMm: 100, alturaMm: 80);

    const outerLeft = 26;
    const outerTop = 16;
    const outerWidth = 748;
    const outerHeight = 608;
    const padding = 16;

    const qrX = 690;
    const qrY = 45;

    const headerTextLeft = outerLeft + padding;
    const headerTextRight = qrX - 30;
    const headerTextWidth = headerTextRight - headerTextLeft;

    const dividerY = 174;
    const contentTop = 190;
    const contentBottom = outerTop + outerHeight - 12;

    const leftColX = outerLeft + padding;
    final leftColW = hasTabelaNutricional ? 230 : 690;

    final empresaCampo = _findCampo(visiveis, 'empresa');
    final produtoCampo = _findCampo(visiveis, 'produto');

    const qrModule = 3;
    const qrEstimatedSize = 93; 
    const tagTextWidth = 72;   

    final tagX = qrX + ((qrEstimatedSize - tagTextWidth) ~/ 2);

    if (empresaCampo != null) {
      _addMultiLineTextStyled(
        w: w,
        text: empresa,
        xBase: headerTextLeft,
        y: outerTop + 8,
        maxWidth: headerTextWidth,
        spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
        align: empresaCampo.align,
        isBold: empresaCampo.isBold,
        maxLines: 3,
        hardRightLimit: headerTextRight,
      );
    }

    if (produtoCampo != null) {
      _addMultiLineTextStyled(
        w: w,
        text: produto,
        xBase: headerTextLeft,
        y: outerTop + 64,
        maxWidth: headerTextWidth,
        spec: const TsplFontSpec(font: '3', xMul: 1, yMul: 1),
        align: produtoCampo.align,
        isBold: produtoCampo.isBold,
        maxLines: 2,
        hardRightLimit: headerTextRight,
      );
    }

    if (hasQr) {
      if (design.mostrarMarcaTagValida) {
       w.text(
          x: tagX,
          y: outerTop + 8,
          spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
          text: 'TagValida',
          isBold: true,
        );
      }

      w.qrCode(
        x: qrX,
        y: qrY,
        module: qrModule,
        data: qrData,
      );
    }

    w.bar(
      x: outerLeft + 4,
      y: dividerY,
      width: outerWidth - 8,
      height: 2,
    );

    int y = contentTop + 10;
    final limiteInferior = contentBottom - 8;

    final valores = _buildValores(etiqueta);

    final infoCampos = visiveis.where((campo) {
      if (campo.tipo == CampoDesignV2Tipo.qrcode) return false;
      if (campo.tipo == CampoDesignV2Tipo.blocoEmpresa) return false;
      if (campo.tipo == CampoDesignV2Tipo.produto) return false;
      if (campo.tipo == CampoDesignV2Tipo.imagem) return false;
      if (campo.tipo == CampoDesignV2Tipo.tabelaNutricional) return false;
      return true;
    }).toList();

    for (final campo in infoCampos) {
      final label = campo.labelImpresso ?? campo.nome;
      final value = valores[campo.id];

      if (value == null || value.trim().isEmpty) continue;

      final textoFinal = _buildTextoCampo(
        campo: campo,
        label: label,
        value: value,
        etiqueta: etiqueta,
        design: design,
      );

      final novoY = _printTextoCampo(
        w: w,
        x: leftColX,
        y: y,
        text: textoFinal,
        bold: campo.isBold || campo.id == 'validade',
        max: campo.id == 'validade' && hasTabelaNutricional
          ? 42
          : campo.id.contains('ingred') ||
                  campo.id.contains('alerg') ||
                  campo.id.contains('observ')
              ? 90
              : 60,
        maxWidth: leftColW,
        maxLines: campo.id == 'validade' && hasTabelaNutricional ? 2 : _maxLinesForCampo(campo),
      );

      if (novoY <= limiteInferior) {
        y = novoY;
      }
    }

    w.print(copias: qtdCopias);
    return w.toString();
  }

  CampoDesignEtiquetaV2Model? _findCampo(
    List<CampoDesignEtiquetaV2Model> campos,
    String id,
  ) {
    try {
      return campos.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int _printTextoCampo({
    required TsplWriter w,
    required int x,
    required int y,
    required String text,
    required bool bold,
    required int max,
    required int maxWidth,
    required int maxLines,
  }) {
    
    final partes = text.split('|');

    int currentY = y;

    for (final parte in partes) {
      final textoLimpo = cleanTsplText(parte, max: max);

      currentY = _addMultiLineTextStyled(
        w: w,
        text: textoLimpo,
        xBase: x,
        y: currentY,
        maxWidth: maxWidth,
        spec: const TsplFontSpec(font: '2', xMul: 1, yMul: 1),
        align: TextAlign.left,
        isBold: bold,
        maxLines: 1,
      );
    }

    return currentY + 4;
  }

  Map<String, String> _buildValores(EtiquetaModel e) {
    final valores = <String, String>{
      'fabricacao': DateFormat('dd/MM/yyyy').format(e.dataFabricacao),
      'validade': DateFormat('dd/MM/yyyy').format(e.dataValidade),
      'categoria': e.categoriaNome,
      'setor': e.setorNome,
      'quantidade': formatNumber(e.quantidade),
      if (e.lote != null && e.lote!.isNotEmpty) 'lote': e.lote!,
    };

    for (final entry in e.camposCustomValores.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value == null) continue;

      if (value is Map) {
        valores['custom_$key'] = (value['value'] ?? '').toString();
      } else {
        valores['custom_$key'] = value.toString();
      }
    }

    return valores;
  }

  int _maxLinesForCampo(CampoDesignEtiquetaV2Model campo) {
    if (campo.id.contains('ingred')) return 5;
    if (campo.id.contains('alerg')) return 4;
    if (campo.id.contains('observ')) return 3;
    return 1;
  }

  String _buildEmpresaText(UserModel usuario) {
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

    final local = [
      usuario.cep.trim(),
      cidadeUf,
    ].where((e) => e.isNotEmpty).join(' ');

    final endereco = [ruaNumero, local].where((e) => e.isNotEmpty).join(', ');

    return [
      razao,
      if (cnpj.isNotEmpty) 'CNPJ: $cnpj',
      if (endereco.isNotEmpty) endereco,
    ].join('\n');
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
}

String _buildTextoCampo({
  required CampoDesignEtiquetaV2Model campo,
  required String label,
  required String value,
  required EtiquetaModel etiqueta,
  required DesignEtiquetaV2Model design,
}) {
  if (campo.id != 'validade') {
    return '${label.toUpperCase()}: $value';
  }

  final destaque = _validadeDestaque(etiqueta);

  if (!design.destacarValidade || destaque.isEmpty) {
    return '${label.toUpperCase()}: $value';
  }

  final hasTabelaNutricional =
      etiqueta.incluirTabelaNutricional &&
      etiqueta.tabelaNutricional != null;

  if (hasTabelaNutricional) {
    return '${label.toUpperCase()}: $value|>>> $destaque';
  }

  return '${label.toUpperCase()}: $value $destaque';
}

String _validadeDestaque(EtiquetaModel etiqueta) {
  final hoje = DateTime.now();
  final hojeLimpo = DateTime(hoje.year, hoje.month, hoje.day);

  final validade = DateTime(
    etiqueta.dataValidade.year,
    etiqueta.dataValidade.month,
    etiqueta.dataValidade.day,
  );

  final dias = validade.difference(hojeLimpo).inDays;

  if (dias < 0) {
    return 'VENCIDO!';
  }

  if (dias <= 1) {
    return 'ALERTA';
  }

  return '';
}