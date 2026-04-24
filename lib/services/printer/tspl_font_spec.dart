class TsplFontSpec {
  final String font;
  final int xMul;
  final int yMul;

  const TsplFontSpec({
    required this.font,
    required this.xMul,
    required this.yMul,
  });
}

TsplFontSpec fontSpecFromPt(double pt, {bool compact = false}) {
  final value = pt.clamp(6.0, 28.0);

  if (compact) {
    if (value <= 7) return const TsplFontSpec(font: '1', xMul: 1, yMul: 1);
    if (value <= 9) return const TsplFontSpec(font: '2', xMul: 1, yMul: 1);
    if (value <= 12) return const TsplFontSpec(font: '2', xMul: 1, yMul: 2);
    if (value <= 15) return const TsplFontSpec(font: '3', xMul: 1, yMul: 1);
    if (value <= 18) return const TsplFontSpec(font: '3', xMul: 1, yMul: 2);
    return const TsplFontSpec(font: '4', xMul: 1, yMul: 1);
  }

  if (value <= 7) return const TsplFontSpec(font: '1', xMul: 1, yMul: 1);
  if (value <= 9) return const TsplFontSpec(font: '2', xMul: 1, yMul: 1);
  if (value <= 11) return const TsplFontSpec(font: '2', xMul: 1, yMul: 2);
  if (value <= 14) return const TsplFontSpec(font: '3', xMul: 1, yMul: 1);
  if (value <= 17) return const TsplFontSpec(font: '3', xMul: 2, yMul: 1);
  if (value <= 21) return const TsplFontSpec(font: '3', xMul: 2, yMul: 2);
  return const TsplFontSpec(font: '4', xMul: 1, yMul: 1);
}