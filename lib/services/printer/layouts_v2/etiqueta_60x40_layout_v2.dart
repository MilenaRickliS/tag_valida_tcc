
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
        text: _buildEmpresa(usuario),
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: fontSpecFromPt(6, compact: true),
        maxLines: 3,
        bold: empresaCampo.isBold,
        isEmpresa: true,
        align: empresaCampo.align,
      );

      y += 8;
    }

    if (produtoCampo != null) {
      y = _writeMultiline(
        w,
        text: etiqueta.produtoNome,
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: fontSpecFromPt(8, compact: true),
        maxLines: 1,
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

      w.qrCode(
        x: qrX,
        y: qrY + 10,
        module: 2,
        data: qrData,
      );
    }

    final dividerY = y + mmToDots(1.8);
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
        text: textoFinal,
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: fontSpecFromPt(7, compact: true),
        maxLines: _maxLinesForCampo(campo),
        bold: campo.isBold || campo.id == 'validade',
        align: campo.align,
      );

      y += mmToDots(0.8);
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
    if (e.unidadeMedida == 'kg') {
      return '${e.quantidade.toStringAsFixed(3).replaceAll(".", ",")} kg';
    }

    if (e.quantidade % 1 == 0) {
      return '${e.quantidade.toInt()} un';
    }

    return '${formatNumber(e.quantidade)} un';
  }

  Map<String, String> _buildValores(EtiquetaModel e) {
    final valores = <String, String>{
      'validade': _formatDate(e.dataValidade),
      'fabricacao': _formatDate(e.dataFabricacao),
      'categoria': e.categoriaNome,
      'setor': e.setorNome,
      'quantidade': _fmtQtd(e),
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

 String _buildEmpresa(UserModel u) {
    final nome = (u.razao.isNotEmpty ? u.razao : u.nome).toUpperCase();

    final linhas = <String>[
      nome,
    ];

    if (u.cnpj.isNotEmpty) {
      linhas.add('CNPJ: ${u.cnpj}');
    }

    final endereco = [
      if (u.rua.isNotEmpty) u.rua,
      if (u.numero.isNotEmpty) u.numero,
      if (u.bairro.isNotEmpty) u.bairro,
    ].join(', ');

    if (endereco.isNotEmpty) {
      linhas.add(endereco);
    }

    return linhas.join('\n');
  }

  int _maxLinesForCampo(CampoDesignEtiquetaV2Model campo) {
    if (campo.id.contains('ingred') ||
        campo.id.contains('alerg') ||
        campo.id.contains('observ')) {
      return 2;
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

      currentY += lineHeight(spec) - (isEmpresa ? 2 : 6);
    }

    return currentY;
  }

  int _estimateLineWidthDots(String text, TsplFontSpec spec) {
    final baseCharWidth = spec.font == '1' ? 8 : 12;
    return text.length * baseCharWidth * spec.xMul;
  }
}