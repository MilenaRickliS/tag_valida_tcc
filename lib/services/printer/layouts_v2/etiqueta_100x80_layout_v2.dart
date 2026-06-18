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
    final deveImprimir = copias > 0;
    final qtdCopias = copias <= 0 ? 1 : copias;
   

    final campos = [...design.campos]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final visiveis = campos.where((c) => c.visivel).toList();
    final hasQr = visiveis.any((c) => c.tipo == CampoDesignV2Tipo.qrcode);
    final hasTabelaNutricional = etiqueta.incluirTabelaNutricional && etiqueta.tabelaNutricional != null;
    final produto = cleanTsplText(
      etiqueta.produtoNome,
      max: design.tamanhoFonte == TamanhoFonteEtiqueta.grande ? 60 : 42,
    );
    final empresa = _buildEmpresaText(usuario);

    w.setup(larguraMm: 100, alturaMm: 80);

    const subirTudo = 38;

    const outerTop = 16 - subirTudo;

    const outerLeft = 26;

    const outerWidth = 748;
    const outerHeight = 608;
    const padding = 16;

    final larguraDots = mmToDots(100);
    final outerPad = mmToDots(3.2);
    final qrSize = hasQr ? 100 : 0;
    final qrX = larguraDots - qrSize - 10;
    final qrY = outerPad - subirTudo + 10;
    final tagValidaY = qrY + 2;
    const headerTextLeft = outerLeft + padding;
    final isGrande = design.tamanhoFonte == TamanhoFonteEtiqueta.grande;

    final headerTextRight = isGrande ? qrX - 130 : qrX - 30;
    final headerTextWidth = headerTextRight - headerTextLeft;
    final dividerY = isGrande
        ? 228 - subirTudo
        : 160 - subirTudo;

    final contentTop = isGrande
        ? 244 - subirTudo
        : 176 - subirTudo;
    
    const contentBottom = outerTop + outerHeight - 4;

    const leftColX = outerLeft + padding;
    final leftColW = hasTabelaNutricional ? 230 : 690;

    final empresaCampo = _findCampo(visiveis, 'empresa');
    final produtoCampo = _findCampo(visiveis, 'produto');
     
    if (empresaCampo != null) {
     _addMultiLineTextStyled(
        w: w,
        design: design,
        text: empresa,
        xBase: headerTextLeft,
        y: outerTop + 8,
        maxWidth: isGrande ? 360 : headerTextWidth,
        spec: fontEtiquetaFromPt(
          isGrande ? 5.8 : 6,
          design.tamanhoFonte,
          compact: true,
        ),
        align: isGrande ? TextAlign.left : empresaCampo.align,
        isBold: empresaCampo.isBold,
        maxLines: isGrande ? 4 : 3,
        hardRightLimit: isGrande ? headerTextLeft + 360 : headerTextRight,
      );
    }

    if (produtoCampo != null) {
      _addMultiLineTextStyled(
        w: w,
        design: design,
        text: produto,
        xBase: headerTextLeft,
        y: isGrande ? outerTop + 128 : outerTop + 64,
        maxWidth: headerTextWidth,
        spec: isGrande
          ? const TsplFontSpec(font: '3', xMul: 1, yMul: 2)
          : fontEtiquetaFromPt(
              12,
              design.tamanhoFonte,
            ),
        align: produtoCampo.align,
        isBold: produtoCampo.isBold,
        maxLines:
          design.tamanhoFonte ==
                  TamanhoFonteEtiqueta.grande
              ? 3
              : 2,
        hardRightLimit: headerTextRight,
      );
    }

    

  if (hasQr) {
     
        w.text(
          x: qrX,
          y: tagValidaY,
          spec: const TsplFontSpec(font: '1', xMul: 1, yMul: 1),
          text: 'TagValida',
          isBold: true,
          max: 16,
        );

        int resolveQrModule(String qrData) {
          final isPublico =
              qrData.startsWith('http://') ||
              qrData.startsWith('https://');

          return isPublico ? 3 : 2;
        }

      w.qrCode(
        x: qrX,
        y: qrY + 20,
        module: resolveQrModule(qrData),
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
      final value =
        valores[campo.id] ??
        valores['custom_${campo.id}'];

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
        design: design,
        x: leftColX,
        y: y,
        text: textoFinal,
        bold: campo.isBold || campo.id == 'validade',
        max: campo.id == 'validade' && hasTabelaNutricional
          ? 42
          : campo.id.contains('ingred') ||
                  campo.id.contains('alerg') ||
                  campo.id.contains('observ')
              ? 120
              : 60,
        maxWidth: hasTabelaNutricional ? 285 : leftColW,
        maxLines: campo.id == 'validade' && hasTabelaNutricional ? 2 : _maxLinesForCampo(campo, design),
        hardRightLimit: hasTabelaNutricional ? 345 : null,
      );

      if (novoY <= limiteInferior) {
        y = novoY;
      }
    }

    if (deveImprimir) {
      w.print(copias: qtdCopias);
    }
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
    required DesignEtiquetaV2Model design,
    required TsplWriter w,
    required int x,
    required int y,
    required String text,
    required bool bold,
    required int max,
    required int maxWidth,
    required int maxLines,
    int? hardRightLimit,
  }) {
    
    final partes = text.split('|');

    int currentY = y;

    for (final parte in partes) {
      final textoLimpo = cleanTsplText(parte, max: max);

      currentY = _addMultiLineTextStyled(
        w: w,
        design: design,
        text: textoLimpo,
        xBase: x,
        y: currentY,
        maxWidth: maxWidth,
        spec: fontEtiquetaFromPt(
          8,
          design.tamanhoFonte,
          compact: true,
        ),
        align: TextAlign.left,
        isBold: bold,
        maxLines: maxLines,
        hardRightLimit: hardRightLimit,
      );
    }

    return currentY + 4;
  }

  String _fmtQtd(EtiquetaModel e) {
    return formatQtdComUnidade(
      e.quantidadeRestante,
      e.unidadeMedida,
    );
  }

  String _formatDate(DateTime date) {
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year.toString();

    return '$dia/$mes/$ano';
  }

String formatCampoCustomParaImpressao(dynamic value) {
  if (value == null) return '';

  if (value is bool) {
    return value ? 'SIM' : 'NAO';
  }

  if (value is Map) {
    final tipo = (value['tipo'] ?? value['type'] ?? '').toString().toLowerCase().trim();
    final raw = value['value'] ?? value['valor'] ?? value['preco'];

    if (tipo == 'bool' || tipo == 'booltype') {
      if (raw == true) return 'SIM';

      final s = raw?.toString().toLowerCase().trim() ?? '';
      if (s == 'true' || s == '1' || s == 'sim' || s == 'yes') {
        return 'SIM';
      }

      return 'NAO';
    }
    

    if (tipo == 'date') {
      if (raw == null) return '';

      if (raw is DateTime) {
        return _formatDate(raw);
      }

      if (raw is num) {
        return _formatDate(
          DateTime.fromMillisecondsSinceEpoch(raw.toInt()),
        );
      }

      final texto = raw.toString().trim();

      final numero = int.tryParse(texto);
      if (numero != null && texto.length >= 10) {
        return _formatDate(
          DateTime.fromMillisecondsSinceEpoch(numero),
        );
      }

      return texto;
    }

    final rawEhPrecoModo = raw is Map &&
        (raw.containsKey('valor') ||
            raw.containsKey('value') ||
            raw.containsKey('preco'));

    if (tipo == 'pricemode' ||
        tipo == 'price_mode' ||
        tipo == 'preco' ||
        rawEhPrecoModo) {

      final precoRaw = raw is Map
          ? (raw['valor'] ?? raw['value'] ?? raw['preco'])
          : raw;

      final modoRaw = raw is Map
          ? (raw['modo'] ??
              raw['modoPreco'] ??
              raw['priceMode'] ??
              raw['mode'])
          : null;

      final preco = precoRaw?.toString().trim() ?? '';
      final modo = modoRaw?.toString().trim() ?? '';

      if (preco.isEmpty) return '';

      final precoFinal =
          preco.startsWith('R\$') ? preco : 'R\$ $preco';

      if (modo.isEmpty) {
        return precoFinal;
      }

      return '$precoFinal/$modo';
    }

    final prefixo = cleanUnit((value['prefixo'] ?? '').toString());
    final sufixo = cleanUnit((value['sufixo'] ?? '').toString());

    final unit = cleanUnit(
      (value['unit'] ??
              value['unidade'] ??
              value['unidadeMedida'] ??
              value['simbolo'] ??
              '')
          .toString(),
    );

    String texto;
    if (raw is num) {
      texto = formatNumber(raw);
    } else {
      texto = raw?.toString() ?? '';
    }

    if (prefixo.isNotEmpty) {
      return '$prefixo $texto';
    }

    if (sufixo.isNotEmpty) {
      return '$texto $sufixo';
    }

    if (unit.isNotEmpty) {
      if (unit == r'R$') {
        return 'R\$ $texto';
      }

      return '$texto $unit';
    }

    return texto;

  }

  final text = value.toString().trim().toLowerCase();

  if (text == 'true' || text == '1' || text == 'sim') return 'SIM';
  if (text == 'false' || text == '0' || text == 'não' || text == 'nao') {
    return 'NAO';
  }

  return value.toString().trim();
}

 Map<String, String> _buildValores(EtiquetaModel e) {
    final valores = <String, String>{
      'fabricacao': DateFormat('dd/MM/yyyy').format(e.dataFabricacao),
      'validade': DateFormat('dd/MM/yyyy').format(e.dataValidade),
      'categoria': e.categoriaNome,
      'setor': e.setorNome,
      'quantidade': _fmtQtd(e),
      if (e.lote != null && e.lote!.isNotEmpty) 'lote': e.lote!,
    };

    for (final entry in e.camposCustomValores.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value == null) continue;

      valores['custom_$key'] = formatCampoCustomParaImpressao(value);
    }

    return valores;
  }

  int _maxLinesForCampo(
    CampoDesignEtiquetaV2Model campo,
    DesignEtiquetaV2Model design,
  ) {
    if (campo.id.contains('ingred')) {
      return design.tamanhoFonte ==
              TamanhoFonteEtiqueta.grande
          ? 6
          : 5;
    }

    if (campo.id.contains('alerg')) {
      return design.tamanhoFonte ==
              TamanhoFonteEtiqueta.grande
          ? 5
          : 4;
    }

    if (campo.id.contains('observ')) {
      return design.tamanhoFonte ==
              TamanhoFonteEtiqueta.grande
          ? 4
          : 3;
    }
    return 1;
  }
  String _abreviarRua(String rua) {
    return rua
        .replaceAll('Rua ', 'R. ')
        .replaceAll('Avenida ', 'Av. ')
        .replaceAll('Travessa ', 'Tv. ')
        .replaceAll('Rodovia ', 'Rod. ');
  }

  String _buildEmpresaText(UserModel usuario) {
    final razao = usuario.razao.trim().isNotEmpty
        ? usuario.razao.trim()
        : usuario.nome.trim();

    final cnpj = usuario.cnpj.trim();

    final ruaNumero = [
      _abreviarRua(usuario.rua.trim()),
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
    required DesignEtiquetaV2Model design,
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

      currentY += lineHeight(spec) +
        (design.tamanhoFonte ==
                TamanhoFonteEtiqueta.grande
            ? 2
            : 0);
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