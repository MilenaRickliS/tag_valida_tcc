import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_model.dart';
import '../../../models/user_model.dart';

import '../tspl_writer.dart';
import 'etiqueta_100x80_layout_v2.dart';
import 'tabela_nutricional_100x80_layout_v2.dart';

class Etiqueta100x80TabelaLayoutV2 {
  String build({
    required DesignEtiquetaV2Model design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) {
    final tabela = etiqueta.tabelaNutricional;

    if (tabela == null) {
      return Etiqueta100x80LayoutV2().build(
        design: design,
        etiqueta: etiqueta,
        usuario: usuario,
        qrData: qrData,
        copias: copias,
      );
    }

    final w = TsplWriter();

    w.setup(larguraMm: 100, alturaMm: 80);

    final base = Etiqueta100x80LayoutV2().build(
      design: design,
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: 0,
    );

    final baseSemPrint = base.replaceAll(
      RegExp(r'PRINT\s+\d+,1'),
      '',
    );

    w.raw(baseSemPrint);

    const separatorX = 350;
    const contentTop = 190;
    const contentHeight = 420;

    w.bar(
      x: separatorX,
      y: contentTop,
      width: 2,
      height: contentHeight,
    );

    TabelaNutricional100x80LayoutV2().build(
      w: w,
      x: 360,
      y: 192,
      width: 420,
      tabela: tabela,
    );

    w.print(copias: copias);

    return w.toString();
  }
}