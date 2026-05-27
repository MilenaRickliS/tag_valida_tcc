
import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_model.dart';
import '../../../models/user_model.dart';

import '../tspl_writer.dart';
import '../tspl_font_spec.dart';
import '../tspl_text_utils.dart';

class Etiqueta60x40LayoutV2 {
  String build({
    required DesignEtiquetaV2Model design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) {
    final w = TsplWriter();

    const larguraMm = 60.0;
    const alturaMm = 40.0;

    final larguraDots = mmToDots(larguraMm);
    final outerPad = mmToDots(3.2);

    final campos = [...design.campos]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final visiveis = campos.where((c) => c.visivel).toList();
    final hasQr = visiveis.any((c) => c.tipo == CampoDesignV2Tipo.qrcode);

    final qrSize = hasQr ? 100 : 0;
    final qrX = larguraDots - qrSize - 10;
    final qrY = outerPad + mmToDots(0.3);

    final textAreaX = outerPad;
    final textAreaRight = hasQr ? qrX - mmToDots(1) : larguraDots - outerPad;
    final textAreaWidth = textAreaRight - textAreaX;

    w.setup(larguraMm: larguraMm, alturaMm: alturaMm);

    int y = outerPad;

    final empresaCampo = _findCampo(visiveis, 'empresa');
    final produtoCampo = _findCampo(visiveis, 'produto');

    if (empresaCampo != null) {
      y = _writeMultiline(
        w,
        design: design,
        text: _buildEmpresa(usuario, isSmall: true),
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: fontEtiquetaFromPt(
          6,
          design.tamanhoFonte,
          compact: true,
          isSmallLabel: true,
        ),
        maxLines: 3,
        bold: empresaCampo.isBold,
        isEmpresa: true,
        align: empresaCampo.align,
      );

      y += design.tamanhoFonte == TamanhoFonteEtiqueta.grande
        ? 12
        : 8;
    }

    if (produtoCampo != null) {
      y = _writeMultiline(
        w,
        design: design,
        text: etiqueta.produtoNome,
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: fontEtiquetaFromPt(
          8,
          design.tamanhoFonte,
          compact: true,
          isSmallLabel: true,
        ),
        maxLines: design.tamanhoFonte ==
        TamanhoFonteEtiqueta.grande
          ? 2
          : 1,
        bold: produtoCampo.isBold,
        align: produtoCampo.align,
      );
    }

    if (hasQr) {
     
        w.text(
          x: qrX,
          y: outerPad,
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
        y: qrY + 10,
        module: resolveQrModule(qrData),
        data: qrData,
      );
    }

    final dividerY = y +
      mmToDots(
        design.tamanhoFonte == TamanhoFonteEtiqueta.grande
            ? 2.6
            : 1.8,
      );
    final dividerEnd = hasQr ? qrX - mmToDots(0.5) : larguraDots - outerPad;

    w.bar(
      x: outerPad,
      y: dividerY,
      width: dividerEnd - outerPad,
      height: 1,
    );

    y = dividerY + mmToDots(2);

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

      y = _writeMultiline(
        w,
        design: design,
        text: textoFinal,
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: fontEtiquetaFromPt(
          7,
          design.tamanhoFonte,
          compact: true,
          isSmallLabel: true,
        ),
        maxLines: _maxLinesForCampo(campo, design),
        bold: campo.isBold || campo.id == 'validade',
        align: campo.align,
      );

      y += mmToDots(
        design.tamanhoFonte == TamanhoFonteEtiqueta.grande
            ? 1.2
            : 0.8,
      );
    }

    w.print(copias: copias);
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

 String _fmtQtd(EtiquetaModel e) {
  return formatQtdComUnidade(
    e.quantidadeRestante,
    e.unidadeMedida,
  );
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
      'fabricacao': _formatDate(e.dataFabricacao),
      'validade': _formatDate(e.dataValidade),
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

 String _buildEmpresa(UserModel u, {required bool isSmall}) {
    final nome = (u.razao.isNotEmpty ? u.razao : u.nome).toUpperCase();

    if (isSmall) {
      return [
        nome,
        if (u.cnpj.isNotEmpty) 'CNPJ: ${u.cnpj}',
        if (u.cidade.isNotEmpty && u.estado.isNotEmpty)
          '${u.cidade} - ${u.estado}',
      ].join('\n');
    }

    final enderecoCurto = [
      if (u.rua.isNotEmpty) _abreviarRua(u.rua),
      if (u.numero.isNotEmpty) u.numero,
    ].join(', ');

    return [
      nome,
      if (u.cnpj.isNotEmpty) 'CNPJ: ${u.cnpj}',
      if (enderecoCurto.isNotEmpty) enderecoCurto,
      if (u.cidade.isNotEmpty && u.estado.isNotEmpty)
        '${u.cidade} - ${u.estado}',
    ].join('\n');
  }
  String _abreviarRua(String rua) {
    return rua
        .replaceAll('Rua ', 'R. ')
        .replaceAll('Avenida ', 'Av. ')
        .replaceAll('Travessa ', 'Tv. ')
        .replaceAll('Rodovia ', 'Rod. ');
  }

  int _maxLinesForCampo(CampoDesignEtiquetaV2Model campo, DesignEtiquetaV2Model design,) {
    if (campo.id.contains('ingred') ||
        campo.id.contains('alerg') ||
        campo.id.contains('observ')) {
      return design.tamanhoFonte ==
          TamanhoFonteEtiqueta.grande
      ? 3
      : 2;
    }

    return 1;
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

  String _formatDate(DateTime date) {
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year.toString();

    return '$dia/$mes/$ano';
  }

  int _writeMultiline(
    TsplWriter w, {
    required String text,
    required DesignEtiquetaV2Model design,
    required int x,
    required int y,
    required int width,
    required TsplFontSpec spec,
    int maxLines = 2,
    bool bold = false,
    bool isEmpresa = false,
    TextAlign align = TextAlign.left,
  }) {
    final rawLines = text.split('\n');

    final lines = rawLines
        .expand((linha) => wrapText(
              cleanTsplText(linha, max: 120),
              maxChars: estimateCharsPerLine(spec, width),
            ))
        .take(maxLines);

    int currentY = y;

    for (final line in lines) {
      final lineWidth = _estimateLineWidthDots(line, spec);

      int alignedX = x;

      if (align == TextAlign.center) {
        alignedX = x + ((width - lineWidth) ~/ 2);
      } else if (align == TextAlign.right) {
        alignedX = x + width - lineWidth;
      }

      if (alignedX < x) alignedX = x;

      w.text(
        x: alignedX,
        y: currentY,
        spec: spec,
        text: line,
        isBold: bold,
      );

      final spacing = design.tamanhoFonte ==
              TamanhoFonteEtiqueta.grande
          ? (isEmpresa ? 0 : 3)
          : (isEmpresa ? 2 : 6);

      currentY += lineHeight(spec) - spacing;
    }

    return currentY;
  }

  int _estimateLineWidthDots(String text, TsplFontSpec spec) {
    final baseCharWidth = spec.font == '1' ? 8 : 12;
    return text.length * baseCharWidth * spec.xMul;
  }
}