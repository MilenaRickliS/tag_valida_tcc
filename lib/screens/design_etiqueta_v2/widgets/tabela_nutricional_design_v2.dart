import 'package:flutter/material.dart';
import '../../../models/tabela_nutricional_model.dart';

Widget buildTabelaNutricionalPreviewV2({double width = 150}) {
  return Container(
    width: width,
    height: 120,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black12),
    ),
    child: const Text(
      'Tabela nutricional',
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}

Widget buildTabelaNutricionalPreviewRealV2(
  TabelaNutricionalModel? tabela, {
  double width = 200,
}) {
  if (tabela == null) {
    return buildTabelaNutricionalPreviewV2(width: width);
  }

  String fmt(num v) {
    if (v == 0) return '–'; 
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1).replaceAll('.', ',');
  }

  double parsePorcao(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  String vd(num valorPorcao, num referencia) {
    if (referencia == 0) return '0%';
    final result = (valorPorcao / referencia) * 100;
    return '${result.round()}%';
  }

  String por100(num valorPorcao) {
    final base = parsePorcao(tabela.porcao);
    if (base <= 0) return '0';
    final result = (valorPorcao / base) * 100;
    return fmt(result);
  }

  Widget row({
    required String nome,
    required String v100,
    required String vPorcao,
    required String vvd,
    bool bold = false,
    bool thickBottom = false,
    double leftPad = 0,
  }) {
    const fs = 5.4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: thickBottom ? 1.2 : 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 46,
            child: Padding(
              padding: EdgeInsets.only(left: leftPad),
              child: Text(
                nome,
                style: TextStyle(
                  fontSize: fs,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Text(v100, textAlign: TextAlign.center, style: const TextStyle(fontSize: fs)),
          ),
          Expanded(
            flex: 18,
            child: Text(vPorcao, textAlign: TextAlign.center, style: const TextStyle(fontSize: fs)),
          ),
          Expanded(
            flex: 12,
            child: Text(vvd, textAlign: TextAlign.center, style: const TextStyle(fontSize: fs)),
          ),
        ],
      ),
    );
  }

  return Container(
    width: width,
    padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'RobotoMono',
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMAÇÃO NUTRICIONAL',
            style: TextStyle(
              fontSize: 7.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Container(height: 1, color: Colors.black),
          const SizedBox(height: 2),

          Text(
            'Porções: ${tabela.porcoesPorEmbalagem}',
            style: const TextStyle(fontSize: 6.2, fontWeight: FontWeight.w700),
          ),

          Text(
            'Porção: ${tabela.porcao}g (${tabela.quantidadeMedida} ${tabela.medidaCaseira})',
            style: const TextStyle(fontSize: 6.2, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 2),
          Container(height: 1.2, color: Colors.black),
          const SizedBox(height: 2),

          const Row(
            children: [
              Expanded(flex: 46, child: SizedBox()),
              Expanded(flex: 16, child: Text('100g', textAlign: TextAlign.center)),
              Expanded(flex: 18, child: Text('Porção', textAlign: TextAlign.center)),
              Expanded(flex: 12, child: Text('%VD', textAlign: TextAlign.center)),
            ],
          ),

          const SizedBox(height: 2),
          Container(height: 0.8, color: Colors.black),

          row(
            nome: 'Valor energético',
            v100: por100(tabela.valorEnergetico),
            vPorcao: fmt(tabela.valorEnergetico),
            vvd: vd(tabela.valorEnergetico, 2000),
          ),

          row(
            nome: 'Carboidratos',
            v100: por100(tabela.carboidratos),
            vPorcao: fmt(tabela.carboidratos),
            vvd: vd(tabela.carboidratos, 300),
          ),

          row(
            nome: 'Açúcares totais',
            v100: por100(tabela.acucaresTotais),
            vPorcao: fmt(tabela.acucaresTotais),
            vvd: vd(tabela.acucaresTotais, 50),
            leftPad: 6,
          ),

          row(
            nome: 'Aç. adicionados',
            v100: por100(tabela.acucaresAdicionados),
            vPorcao: fmt(tabela.acucaresAdicionados),
            vvd: vd(tabela.acucaresAdicionados, 50),
            leftPad: 6,
          ),

          row(
            nome: 'Proteínas',
            v100: por100(tabela.proteinas),
            vPorcao: fmt(tabela.proteinas),
            vvd: vd(tabela.proteinas, 50),
          ),

          row(
            nome: 'Gorduras totais',
            v100: por100(tabela.gordurasTotais),
            vPorcao: fmt(tabela.gordurasTotais),
            vvd: vd(tabela.gordurasTotais, 55),
          ),

          row(
            nome: 'Sódio',
            v100: por100(tabela.sodio),
            vPorcao: fmt(tabela.sodio),
            vvd: vd(tabela.sodio, 2000),
            thickBottom: true,
          ),

          const SizedBox(height: 4),

          const Text(
            '* %VD por porção.',
            style: TextStyle(fontSize: 5.4),
          ),
        ],
      ),
    ),
  );
}