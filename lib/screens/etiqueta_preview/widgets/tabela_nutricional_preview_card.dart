import 'package:flutter/material.dart';
import '../../../models/tabela_nutricional_model.dart';

class TabelaNutricionalPreviewCard extends StatelessWidget {
  final TabelaNutricionalModel tabela;
  final bool compacta;

  const TabelaNutricionalPreviewCard({
    super.key,
    required this.tabela,
    this.compacta = false,
  });

  static const _black = Colors.black;
  static const _outerBorder = 1.3;
  static const _heavyBorder = 2.4;
  static const _mediumBorder = 1.3;
  static const _lightLineColor = Colors.black;
  static const _thinBorder = 0.4;
  

  String _fmtNum(num v, {int casas = 1}) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(casas).replaceAll('.', ',');
  }

  double _porcaoEmGramas() {
    final raw = tabela.porcao.trim().replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  double _calc100g(double valorNaPorcao) {
    final porcao = _porcaoEmGramas();
    if (porcao <= 0) return 0;
    return (valorNaPorcao / porcao) * 100;
  }

  double _calcVD(double valorNaPorcao, double vdReferencia) {
    if (vdReferencia <= 0) return 0;
    return (valorNaPorcao / vdReferencia) * 100;
  }

  String _fmtVd(double v) {
    if (v <= 0) return '0%';
    return '${v.round()}%';
  }

  TextStyle _titleStyle() => TextStyle(
        color: _black,
        fontSize: compacta ? 14.5 : 16.8,
        fontFamily: 'Arial',
        fontWeight: FontWeight.w900,
        height: 1,
      );

  TextStyle _infoStyle() => TextStyle(
        color: _black,
        fontSize: compacta ? 9.8 : 11.0,
        fontFamily: 'Arial',
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  TextStyle _headerStyle() => TextStyle(
        color: _black,
        fontSize: 9.6,
        fontFamily: 'Arial',
        fontWeight: FontWeight.w900,
        height: 1,
      );

  TextStyle _cellStyle({bool bold = false}) => TextStyle(
        color: _black,
        fontSize: 9.6,
        fontFamily: 'Arial',
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        height: 1.08,
      );

  Widget _headerCell(String text, {TextAlign align = TextAlign.center}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2.5,
      ),
      child: Text(
        text,
        textAlign: align,
        style: _headerStyle(),
      ),
    );
  }

  TableRow _dataRow({
    required String label,
    required double valorPorcao,
    required double vdReferencia,
    bool indentado = false,
  }) {
    final valor100 = _calc100g(valorPorcao);
    final vd = _calcVD(valorPorcao, vdReferencia);

    Widget cell(
      String text, {
      TextAlign align = TextAlign.left,
      EdgeInsets? padding,
    }) {
      return Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2.5,
            ),
        child: Text(
          text,
          textAlign: align,
          style: _cellStyle(),
        ),
      );
    }

    return TableRow(
      children: [
        cell(
          label,
          padding: EdgeInsets.fromLTRB(
            indentado ? 12 : 4,
            compacta ? 3 : 4,
            4,
            compacta ? 3 : 4,
          ),
        ),
        cell(
          _fmtNum(valor100),
          align: TextAlign.center,
        ),
        cell(
          _fmtNum(valorPorcao),
          align: TextAlign.center,
        ),
        cell(
          _fmtVd(vd),
          align: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final porcaoLabel = '${tabela.porcao} g';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(compacta ? 8 : 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _black, width: _outerBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: compacta ? 7 : 9,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: _lightLineColor, width: _thinBorder),
                    ),
                  ),
                  child: Text(
                    'INFORMAÇÃO NUTRICIONAL',
                    textAlign: TextAlign.center,
                    style: _titleStyle(),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    8,
                    compacta ? 6 : 8,
                    8,
                    compacta ? 5 : 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Porções por embalagem: ${tabela.porcoesPorEmbalagem}',
                        style: _infoStyle(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Porção: $porcaoLabel (${tabela.medidaCaseira})',
                        style: _infoStyle(),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _black, width: _heavyBorder),
                      bottom: BorderSide(color: _lightLineColor, width: _thinBorder),
                    ),
                  ),
                  child: Table(
                    border: const TableBorder(
                      verticalInside:
                          BorderSide(color: _lightLineColor, width: _thinBorder),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(0.9),
                      2: FlexColumnWidth(0.9),
                      3: FlexColumnWidth(0.7),
                    },
                    children: [
                      TableRow(
                        children: [
                          _headerCell('', align: TextAlign.left),
                          _headerCell('100 g'),
                          _headerCell(porcaoLabel),
                          _headerCell('%VD*'),
                        ],
                      ),
                    ],
                  ),
                ),

                Table(
                  border: const TableBorder(
                    horizontalInside:
                        BorderSide(color: _lightLineColor, width: _thinBorder),
                    verticalInside:
                        BorderSide(color: _lightLineColor, width: _thinBorder),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(0.9),
                    2: FlexColumnWidth(0.9),
                    3: FlexColumnWidth(0.7),
                  },
                  children: [
                    _dataRow(
                      label: 'Valor energético (kcal)',
                      valorPorcao: tabela.valorEnergetico,
                      vdReferencia: 2000,
                    ),
                    _dataRow(
                      label: 'Carboidratos totais (g)',
                      valorPorcao: tabela.carboidratos,
                      vdReferencia: 300,
                    ),
                    _dataRow(
                      label: 'Açúcares totais (g)',
                      valorPorcao: tabela.acucaresTotais,
                      vdReferencia: 50,
                      indentado: true,
                    ),
                    _dataRow(
                      label: 'Açúcares adicionados (g)',
                      valorPorcao: tabela.acucaresAdicionados,
                      vdReferencia: 50,
                      indentado: true,
                    ),
                    _dataRow(
                      label: 'Proteínas (g)',
                      valorPorcao: tabela.proteinas,
                      vdReferencia: 50,
                    ),
                    _dataRow(
                      label: 'Gorduras totais (g)',
                      valorPorcao: tabela.gordurasTotais,
                      vdReferencia: 55,
                    ),
                    _dataRow(
                      label: 'Gorduras saturadas (g)',
                      valorPorcao: tabela.gordurasSaturadas,
                      vdReferencia: 22,
                      indentado: true,
                    ),
                    _dataRow(
                      label: 'Gorduras trans (g)',
                      valorPorcao: tabela.gordurasTrans,
                      vdReferencia: 2,
                      indentado: true,
                    ),
                    _dataRow(
                      label: 'Fibra alimentar (g)',
                      valorPorcao: tabela.fibraAlimentar,
                      vdReferencia: 25,
                    ),
                    _dataRow(
                      label: 'Sódio (mg)',
                      valorPorcao: tabela.sodio,
                      vdReferencia: 2000,
                    ),
                  ],
                ),

                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _black, width: _mediumBorder),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    8,
                    compacta ? 5 : 6,
                    8,
                    compacta ? 7 : 8,
                  ),
                  child: Text(
                    '* Percentual de valores diários fornecidos pela porção.',
                    style: TextStyle(
                      color: _black,
                      fontSize: compacta ? 8.8 : 9.8,
                      fontWeight: FontWeight.w500,
                      height: 1.08,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}