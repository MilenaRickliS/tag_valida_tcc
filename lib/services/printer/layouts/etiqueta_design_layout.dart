import '../../../models/design_etiqueta_model.dart';
import '../../../models/etiqueta_model.dart';
import '../../../models/user_model.dart';

import '../tspl_writer.dart';
import '../tspl_font_spec.dart';
import '../tspl_text_utils.dart';

class EtiquetaDesignLayout {
  String build({
    required DesignEtiquetaModel design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) {
    final w = TsplWriter();

    final larguraMm = design.larguraMm <= 0 ? 60.0 : design.larguraMm;
    final alturaMm = design.alturaMm <= 0 ? 40.0 : design.alturaMm;

    final larguraDots = mmToDots(larguraMm);
   
    final is60x40 = larguraMm <= 60.5 && alturaMm <= 40.5;

    final outerPad = mmToDots(is60x40 ? 3.2 : 2.8);

    final campos = [...design.campos]..sort((a, b) => a.ordem.compareTo(b.ordem));
    final visiveis = campos.where((c) => c.visivel).toList();

    final hasQr = visiveis.any((c) => c.tipo == CampoDesignTipo.qrcode);

    final qrSize = hasQr ? (is60x40 ? 72 : 126) : 0;
    final qrX = larguraDots - mmToDots(5) - qrSize;
    final qrY = outerPad + mmToDots(2);

    final textAreaX = outerPad;
    final textAreaRight = hasQr
        ? qrX - mmToDots(3)
        : larguraDots - outerPad;

    final textAreaWidth = textAreaRight - textAreaX;

    w.setup(larguraMm: larguraMm, alturaMm: alturaMm);

    int y = outerPad;

    final empresa = _buildEmpresa(usuario);

    final empresaSpec = fontSpecFromPt(
      is60x40 ? 7 : 9,
      compact: is60x40,
    );

    y = _writeMultiline(
      w,
      text: empresa,
      x: textAreaX,
      y: y,
      width: textAreaWidth,
      spec: empresaSpec,
      maxLines: is60x40 ? 2 : 3,
    );

    y += mmToDots(2);

    
    final produtoSpec = fontSpecFromPt(
      is60x40 ? 8 : 12,
      compact: is60x40,
    );

    y = _writeMultiline(
      w,
      text: etiqueta.produtoNome,
      x: textAreaX,
      y: y,
      width: textAreaWidth,
      spec: produtoSpec,
      maxLines: 2,
      bold: true,
    );


    if (hasQr) {
      w.qrCode(
        x: qrX,
        y: qrY,
        module: is60x40 ? 2 : 3,
        data: qrData,
      );
    }

    final dividerY = y + mmToDots(1);

    final dividerEnd = hasQr
        ? qrX - mmToDots(1)
        : larguraDots - outerPad;

    w.bar(
      x: outerPad,
      y: dividerY,
      width: dividerEnd - outerPad,
      height: 1,
    );

    y = dividerY + mmToDots(2);

    final infoSpec = fontSpecFromPt(
      is60x40 ? 7 : 9,
      compact: is60x40,
    );

    final valores = _buildValores(etiqueta);

    for (final entry in valores.entries) {
      final texto = '${entry.key}: ${entry.value}';

      y = _writeMultiline(
        w,
        text: texto,
        x: textAreaX,
        y: y,
        width: textAreaWidth,
        spec: infoSpec,
        maxLines: 2,
      );

      y += mmToDots(1);
    }

    w.print(copias: copias);

    return w.toString();
  }

  String _buildEmpresa(UserModel u) {
    final partes = [
      u.razao.isNotEmpty ? u.razao : u.nome,
      if (u.cnpj.isNotEmpty) 'CNPJ: ${u.cnpj}',
    ];
    return partes.join('\n');
  }

 Map<String, String> _buildValores(EtiquetaModel e) {
    return {
      'Val': _formatDate(e.dataValidade),
      'Fab': _formatDate(e.dataFabricacao),
      if (e.lote != null && e.lote!.isNotEmpty) 'Lote': e.lote!,
      'Qtd': formatNumber(e.quantidade),
    };
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
  }) {
    final lines = wrapText(
      cleanTsplText(text, max: 120),
      maxChars: estimateCharsPerLine(spec, width),
    ).take(maxLines);

    int currentY = y;

    for (final line in lines) {
      w.text(
        x: x,
        y: currentY,
        spec: spec,
        text: line,
        isBold: bold,
      );

      currentY += lineHeight(spec);
    }

    return currentY;
  }
}

List<String> wrapText(String text, {required int maxChars}) {
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

int estimateCharsPerLine(TsplFontSpec spec, int maxWidth) {
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

int lineHeight(TsplFontSpec spec) {
  final baseHeight = switch (spec.font) {
    '1' => 16,
    '2' => 20,
    '3' => 24,
    '4' => 30,
    _ => 20,
  };

  return baseHeight * spec.yMul;
}