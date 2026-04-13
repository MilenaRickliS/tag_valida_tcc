import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/design_etiqueta_model.dart';
import '../models/etiqueta_model.dart';
import '../models/user_model.dart';

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

_TsplFontSpec _fontSpecFromPt(double pt, {bool compact = false}) {
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

enum _StatusValidadePrint {
  normal,
  alerta,
  vencido,
}

class ElginL42NetworkService {
  final String ip;
  final int port;
  final Duration timeout;

  ElginL42NetworkService({
    required this.ip,
    this.port = 9100,
    this.timeout = const Duration(seconds: 5),
  });

  Future<void> sendRaw(String command) async {
    Socket? socket;
    try {
      debugPrint('================ TSPL DEBUG ================');
      debugPrint(command);
      debugPrint('===========================================');

      socket = await Socket.connect(ip, port, timeout: timeout);

      final normalized = '${command
              .replaceAll('\r\n', '\n')
              .replaceAll('\r', '\n')
              .split('\n')
              .map((line) => line.trimRight())
              .where((line) => line.isNotEmpty)
              .join('\r\n')}\r\n';

      debugPrint('================ TSPL NORMALIZED ================');
      debugPrint(normalized);
      debugPrint('=================================================');

      socket.add(ascii.encode(normalized));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e, stack) {
      debugPrint('❌ ERRO AO ENVIAR PARA IMPRESSORA');
      debugPrint('Erro: $e');
      debugPrint('Stack: $stack');
    } finally {
      try {
        await socket?.flush();
      } catch (_) {}

      try {
        await socket?.close();
      } catch (_) {}

      socket?.destroy();
    }
  }

  Future<bool> testConnection() async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: timeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      await socket?.close();
      socket?.destroy();
    }
  }

  Future<void> avancarEtiqueta() async {
    const tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
PRINT 1,1
''';

    await sendRaw(tspl);
  }

  Future<void> printTeste() async {
    const tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
TEXT 20,30,"3",0,1,1,"TESTE TAGVALIDA"
TEXT 20,70,"2",0,1,1,"ELGIN L42 PRO OK"
PRINT 1,1
''';

    await sendRaw(tspl);
  }

 Future<void> printEtiqueta60x40Compacta({
  required String produto,
  required String validade,
  required String lote,
  required String quantidade,
  required String qrData,
  int copias = 1,
}) async {
  final safeProduto = _clean(produto, max: 22);
  final safeValidade = _clean(validade, max: 18);
  final safeLote = _clean(lote, max: 18);
  final safeQuantidade = _clean(quantidade, max: 10);
  final safeQr = _cleanQr(qrData);

  final qtdCopias = copias <= 0 ? 1 : copias;

  final tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
TEXT 32,18,"3",0,1,1,"$safeProduto"
TEXT 32,95,"2",0,1,1,"Val: $safeValidade"
TEXT 32,120,"2",0,1,1,"Lote: $safeLote"
TEXT 32,145,"2",0,1,1,"Qtd: $safeQuantidade"
QRCODE 320,22,L,3,A,0,"$safeQr"
PRINT $qtdCopias,1
''';

  await sendRaw(tspl);
}

  Future<void> printEtiquetaComDesign({
    required DesignEtiquetaModel design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    final qtdCopias = copias <= 0 ? 1 : copias;

    final campos = [...design.campos]..sort((a, b) => a.ordem.compareTo(b.ordem));
    final visiveis = campos.where((c) => c.visivel).toList();

    final empresaCampo = visiveis
        .where((c) => c.id == 'empresa')
        .cast<CampoDesignEtiquetaModel?>()
        .firstWhere((_) => true, orElse: () => null);

    final produtoCampo = visiveis
        .where((c) => c.id == 'produto')
        .cast<CampoDesignEtiquetaModel?>()
        .firstWhere((_) => true, orElse: () => null);

    final hasQr = visiveis.any((c) => c.tipo == CampoDesignTipo.qrcode);

    final infoCampos = visiveis.where((campo) {
      if (campo.tipo == CampoDesignTipo.qrcode) return false;
      if (campo.tipo == CampoDesignTipo.blocoEmpresa) return false;
      if (campo.tipo == CampoDesignTipo.produto) return false;
      if (campo.tipo == CampoDesignTipo.imagem) return false;
      if (campo.id == 'tabela_nutricional') return false;
      return true;
    }).toList();

    final valores = _buildValoresEtiqueta(
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
    );

    final larguraMm = (design.larguraMm <= 0 ? 60.0 : design.larguraMm).toDouble();
    final alturaMm  = (design.alturaMm <= 0 ? 40.0 : design.alturaMm).toDouble();

    final larguraDots = _mmToDots(larguraMm);
    final alturaDots = _mmToDots(alturaMm);

    final is60x40 = larguraMm <= 60.5 && alturaMm <= 40.5;

    final outerPad = _mmToDots(is60x40 ? 3.2 : 2.8);
    final innerPad = _mmToDots(is60x40 ? 2.4 : 2.6);

   
    final qrModule = hasQr ? (is60x40 ? 2 : 3) : 0;
    final qrVisualSize = hasQr ? (is60x40 ? 72 : 126) : 0;
    final qrGap = hasQr ? _mmToDots(2.2) : 0;
    final qrRightSafe = _mmToDots(is60x40 ? 4.0 : 5.0);

    final qrX = hasQr ? (larguraDots - qrRightSafe - qrVisualSize) : 0;
    final qrY = outerPad + _mmToDots(1.8); 

    final textAreaX = outerPad;
    final textAreaRight = hasQr
        ? (qrX - _mmToDots(is60x40 ? 3.0 : 4.0))
        : (larguraDots - outerPad);

    final textAreaWidth = (textAreaRight - textAreaX).clamp(
      _mmToDots(16.0),
      larguraDots,
    );


    final sb = StringBuffer();
    sb.writeln('SIZE ${larguraMm.toStringAsFixed(0)} mm,${alturaMm.toStringAsFixed(0)} mm');
    sb.writeln('GAP 2 mm,0 mm');
    sb.writeln('DIRECTION 1');
    sb.writeln('REFERENCE 0,0');
    sb.writeln('CLS');

    int y = outerPad;

    if (empresaCampo != null) {
      final empresaText = valores['empresa'] ?? '';
      final empresaFont = is60x40 ? 7.0 : 9.0;

      final empresaSpec = _fontSpecFromPt(
        empresaFont,
        compact: is60x40,
      );

      final empresaBoxHeight = is60x40 ? 38 : 54;

      final empresaStartY = y;

      _addMultiLineTextStyled(
        sb: sb,
        text: empresaText,
        xBase: textAreaX,
        y: empresaStartY,
        maxWidth: textAreaWidth,
        spec: empresaSpec,
        maxLines: is60x40 ? 2 : 3,
        align: empresaCampo.align,
        isBold: empresaCampo.isBold,
        hardRightLimit: textAreaRight,
      );

      y = empresaStartY + empresaBoxHeight;
    }

  if (produtoCampo != null) {
    final produtoText = valores['produto'] ?? '';
    final produtoFont = is60x40
        ? produtoCampo.fontSize.clamp(7.0, 8.0)
        : produtoCampo.fontSize.clamp(8.0, 14.0);

    final produtoSpec = _fontSpecFromPt(
      produtoFont,
      compact: is60x40,
    );

    final produtoBoxHeight = is60x40 ? 42 : 58;
    final produtoStartY = y;

    _addMultiLineTextStyled(
      sb: sb,
      text: produtoText,
      xBase: textAreaX,
      y: produtoStartY,
      maxWidth: textAreaWidth,
      spec: produtoSpec,
      maxLines: 2,
      align: produtoCampo.align,
      isBold: produtoCampo.isBold,
      hardRightLimit: textAreaRight,
    );

    y = produtoStartY + produtoBoxHeight;
  }

   if (hasQr && design.mostrarMarcaTagValida) {
    final brandText = 'TagValida';
    final brandSpec = _fontSpecFromPt(7, compact: is60x40);

    final brandWidth = _estimateTextWidth(brandText, brandSpec);
    final brandX = qrX + ((qrVisualSize - brandWidth) ~/ 2);

   
    final brandY = qrY - _lineHeight(brandSpec);

    _writeText(
      sb: sb,
      x: brandX < qrX ? qrX : brandX,
      y: brandY,
      spec: brandSpec,
      text: brandText,
      isBold: true,
    );

    sb.writeln('QRCODE $qrX,$qrY,L,$qrModule,A,0,"${_cleanQr(qrData)}"');
  } else if (hasQr) {
    sb.writeln('QRCODE $qrX,$qrY,L,$qrModule,A,0,"${_cleanQr(qrData)}"');
  } else if (design.mostrarMarcaTagValida) {
    final brandText = 'TagValida';
    final brandSpec = _fontSpecFromPt(7, compact: is60x40);
    final brandY = alturaDots - outerPad - _lineHeight(brandSpec);

    _writeText(
      sb: sb,
      x: textAreaX,
      y: brandY,
      spec: brandSpec,
      text: brandText,
      isBold: true,
    );
  }

   
    final dividerY = y + _mmToDots(0.8);

    final dividerStartX = outerPad;
    final dividerEndX = hasQr
        ? (qrX - _mmToDots(1.5))
        : (larguraDots - outerPad);

    final dividerWidth = dividerEndX - dividerStartX;

    if (dividerWidth > 8) {
      sb.writeln('BAR $dividerStartX,$dividerY,$dividerWidth,1');
    }


    final blocoY1 = dividerY + _mmToDots(1.4);
    final blocoY2 = alturaDots - outerPad;

    int infoY = blocoY1 + innerPad;
    final infoX = outerPad + innerPad;

    final infoRightLimit = hasQr
        ? (qrX - qrGap - _mmToDots(2.0))
        : (larguraDots - outerPad - innerPad);

    final infoWidth = (infoRightLimit - infoX).clamp(
      _mmToDots(16.0),
      larguraDots,
    );

    final infoBottomLimit = blocoY2 - innerPad;

    for (final campo in infoCampos) {
      final valor = (valores[campo.id] ?? '').trim();
      if (valor.isEmpty) continue;
      final campoSpec = _fontSpecFromPt(
        campo.fontSize,
        compact: is60x40,
      );
     
      if (campo.id == 'validade' && design.destacarValidade) {
        infoY = _addValidadeDestaque(
          sb: sb,
          xBase: infoX,
          y: infoY,
          maxWidth: infoWidth,
          valor: valor,
          spec: campoSpec,
          align: campo.align,
          isBold: campo.isBold,
          status: _getStatusValidade(etiqueta.dataValidade),
        );
        infoY += _mmToDots(0.8);

        if (infoY > infoBottomLimit) break;
        continue;
      }

      final prefixo = (campo.labelImpresso ?? campo.nome).trim();
      final linha = prefixo.isEmpty ? valor : '$prefixo: $valor';

      infoY = _addMultiLineTextStyled(
        sb: sb,
        text: linha,
        xBase: infoX,
        y: infoY,
        maxWidth: infoWidth,
        spec: campoSpec,
        maxLines: (campo.id == 'ingredientes' || campo.id == 'alergenicos') ? 2 : 2,
        align: campo.align,
        isBold: campo.isBold,
      );

      infoY += _mmToDots(0.5);

      if (infoY > blocoY2 - innerPad) {
        break;
      }
    }

    sb.writeln('PRINT $qtdCopias,1');
    await sendRaw(sb.toString());
  }

  Map<String, String> _buildValoresEtiqueta({
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
  }) {
    final custom = Map<String, dynamic>.from(etiqueta.camposCustomValores);

    String loteValue = etiqueta.lote?.trim() ?? '';
    final loteRaw = custom['lote'];

    if (loteRaw is Map) {
      loteValue = (loteRaw['value'] ?? loteValue).toString().trim();
    } else if (loteRaw != null && loteValue.isEmpty) {
      loteValue = loteRaw.toString().trim();
    }

    final resultado = <String, String>{
      'empresa': _buildEmpresaText(
        usuario,
        compact: true,
      ),
      'produto': etiqueta.produtoNome,
      'fabricacao': DateFormat('dd/MM/yyyy').format(etiqueta.dataFabricacao),
      'validade': DateFormat('dd/MM/yyyy').format(etiqueta.dataValidade),
      'categoria': etiqueta.categoriaNome,
      'setor': etiqueta.setorNome,
      'quantidade': _fmtNum(etiqueta.quantidade),
      'lote': loteValue,
      'qrcode': qrData,
    };

    for (final entry in custom.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value == null) continue;

      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final label = (map['label'] ?? key).toString();
        final rawValue = (map['value'] ?? '').toString().trim();
        final safeId = _safeCustomId(label);
        resultado['custom_$safeId'] = rawValue;
      } else {
        resultado[key] = value.toString().trim();
      }
    }

    if (etiqueta.incluirTabelaNutricional && etiqueta.tabelaNutricional != null) {
      resultado['tabela_nutricional'] = 'Tabela nutricional';
    }

    return resultado;
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

  _StatusValidadePrint _getStatusValidade(DateTime dataValidade) {
    final hoje = DateTime.now();
    final baseHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final baseValidade = DateTime(
      dataValidade.year,
      dataValidade.month,
      dataValidade.day,
    );

    if (baseValidade.isBefore(baseHoje)) {
      return _StatusValidadePrint.vencido;
    }

    final diff = baseValidade.difference(baseHoje).inDays;
    if (diff <= 3) {
      return _StatusValidadePrint.alerta;
    }

    return _StatusValidadePrint.normal;
  }

  int _addMultiLineTextStyled({
    required StringBuffer sb,
    required String text,
    required int xBase,
    required int y,
    required int maxWidth,
    required _TsplFontSpec spec,
    required TextAlign align,
    required bool isBold,
    int? maxLines,
    int? hardRightLimit,
  }) {
    final blocos = text.split('\n');
    final linhasFinais = <String>[];

    for (final bloco in blocos) {
      final wrapped = _wrapText(
        _clean(bloco, max: 180),
        maxChars: _estimateCharsPerLine(spec, maxWidth),
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
        final larguraLinha = _estimateTextWidth(linha, spec);
        final maxAllowedX = hardRightLimit - larguraLinha;
        if (x > maxAllowedX) x = maxAllowedX;
        if (x < xBase) x = xBase;
      }

      _writeText(
        sb: sb,
        x: x,
        y: currentY,
        spec: spec,
        text: linha,
        isBold: isBold,
      );

      currentY += _lineHeight(spec);
    }

    return currentY;
  }

  void _writeText({
    required StringBuffer sb,
    required int x,
    required int y,
    required _TsplFontSpec spec,
    required String text,
    required bool isBold,
  }) {
    final safe = _clean(text, max: 180);

    sb.writeln(
      'TEXT $x,$y,"${spec.font}",0,${spec.xMul},${spec.yMul},"$safe"',
    );

    if (isBold) {
      sb.writeln(
        'TEXT ${x + 1},$y,"${spec.font}",0,${spec.xMul},${spec.yMul},"$safe"',
      );
    }
  }

  int _addValidadeDestaque({
    required StringBuffer sb,
    required int xBase,
    required int y,
    required int maxWidth,
    required String valor,
    required _TsplFontSpec spec,
    required TextAlign align,
    required bool isBold,
    required _StatusValidadePrint status,
  }) {
    String texto = 'VALIDADE: $valor';

    if (status == _StatusValidadePrint.alerta) {
      texto += ' *EM ALERTA';
    } else if (status == _StatusValidadePrint.vencido) {
      texto += ' !VENCIDO';
    }

    return _addMultiLineTextStyled(
      sb: sb,
      text: texto,
      xBase: xBase,
      y: y,
      maxWidth: maxWidth,
      spec: spec,
      maxLines: 1,
      align: align,
      isBold: isBold,
    );
  }

  int _resolveAlignedX({
    required TextAlign align,
    required int xBase,
    required int containerWidth,
    required String text,
    required _TsplFontSpec spec,
  }) {
    final estimatedWidth = _estimateTextWidth(text, spec);
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

  int _estimateTextWidth(String text, _TsplFontSpec spec) {
    final baseCharWidth = switch (spec.font) {
      '1' => 7,
      '2' => 8,
      '3' => 10,
      '4' => 13,
      _ => 8,
    };

    return text.length * baseCharWidth * spec.xMul;
  }

  int _estimateCharsPerLine(_TsplFontSpec spec, int maxWidth) {
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

  int _lineHeight(_TsplFontSpec spec) {
    final baseHeight = switch (spec.font) {
      '1' => 16,
      '2' => 20,
      '3' => 24,
      '4' => 30,
      _ => 20,
    };

    return baseHeight * spec.yMul;
  }

  List<String> _wrapText(String text, {required int maxChars}) {
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

  int _mmToDots(double mm) => (mm * 8).round();

  String _fmtNum(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _safeCustomId(String label) {
    return label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _clean(String value, {int max = 30}) {
    var text = value
        .replaceAll('"', "'")
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .trim();

  
    text = _removeAccents(text);

  
    text = text.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

    if (text.length > max) {
      text = text.substring(0, max);
    }

    return text;
  }

  String _removeAccents(String str) {
    const withAccents = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
    const withoutAccents = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    for (int i = 0; i < withAccents.length; i++) {
      str = str.replaceAll(withAccents[i], withoutAccents[i]);
    }

    return str;
  }

  String _cleanQr(String value) {
    return value.replaceAll('\n', '').replaceAll('\r', '').trim();
  }
}