import 'tspl_font_spec.dart';
import 'tspl_text_utils.dart';

class TsplWriter {
  final StringBuffer _sb = StringBuffer();

  void setup({
    required double larguraMm,
    required double alturaMm,
  }) {
    _sb.writeln(
      'SIZE ${larguraMm.toStringAsFixed(0)} mm,${alturaMm.toStringAsFixed(0)} mm',
    );
    _sb.writeln('GAP 2 mm,0 mm');
    _sb.writeln('DIRECTION 1');
    _sb.writeln('REFERENCE 0,0');
    _sb.writeln('CLS');
  }

  void text({
    required int x,
    required int y,
    required TsplFontSpec spec,
    required String text,
    bool isBold = false,
    int max = 180,
  }) {
    final safe = cleanTsplText(text, max: max);

    _sb.writeln(
      'TEXT $x,$y,"${spec.font}",0,${spec.xMul},${spec.yMul},"$safe"',
    );

    if (isBold) {
      _sb.writeln(
        'TEXT ${x + 1},$y,"${spec.font}",0,${spec.xMul},${spec.yMul},"$safe"',
      );
    }
  }

  void qrCode({
    required int x,
    required int y,
    required int module,
    required String data,
  }) {
    _sb.writeln(
      'QRCODE $x,$y,L,$module,A,0,"${cleanQr(data)}"',
    );
  }

  void bar({
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    _sb.writeln('BAR $x,$y,$width,$height');
  }

  void box({
    required int left,
    required int top,
    required int right,
    required int bottom,
    int thickness = 1,
  }) {
    _sb.writeln('BOX $left,$top,$right,$bottom,$thickness');
  }

  void raw(String command) {
    _sb.writeln(command);
  }

  void print({
    required int copias,
  }) {
    final qtdCopias = copias <= 0 ? 1 : copias;
    _sb.writeln('PRINT $qtdCopias,1');
  }

  @override
  String toString() => _sb.toString();
}