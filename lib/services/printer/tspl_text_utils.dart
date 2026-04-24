import 'tspl_font_spec.dart';

int mmToDots(double mm) => (mm * 8).round();

String cleanTsplText(String value, {int max = 30}) {
  var text = value
      .replaceAll('"', "'")
      .replaceAll('\r', ' ')
      .replaceAll('\n', ' ')
      .trim();

  text = removeAccents(text);
  text = text.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

  if (text.length > max) {
    text = text.substring(0, max);
  }

  return text;
}

String removeAccents(String str) {
  const withAccents =
      'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
  const withoutAccents =
      'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  for (int i = 0; i < withAccents.length; i++) {
    str = str.replaceAll(withAccents[i], withoutAccents[i]);
  }

  return str;
}

String cleanQr(String value) {
  return value.replaceAll('\n', '').replaceAll('\r', '').trim();
}

String formatNumber(num value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceAll('.', ',');
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

int estimateTextWidth(String text, TsplFontSpec spec) {
  final baseCharWidth = switch (spec.font) {
    '1' => 7,
    '2' => 8,
    '3' => 10,
    '4' => 13,
    _ => 8,
  };

  return text.length * baseCharWidth * spec.xMul;
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