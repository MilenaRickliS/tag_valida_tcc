import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tag_valida/screens/etiqueta_detalhes/widgets/etiqueta_details_card.dart';

void main() {
  testWidgets('deve exibir botão de acessibilidade para ouvir etiqueta',
      (tester) async {
    var clicou = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EtiquetaDetailsCard(
            isDark: false,
            cardColor: Colors.white,
            borderColor: Colors.black12,
            textColor: Colors.black,
            mutedColor: Colors.black54,
            tipoNome: 'Etiqueta 60x40',
            produtoNome: 'Pão francês',
            statusLabel: 'Ativo',
            statusColor: Colors.green,
            validadeLabel: 'Boa',
            validadeHint: 'Faltam 3 dia(s)',
            validadeColor: Colors.green,
            categoriaNome: 'Pães',
            setorNome: 'Produção',
            fabricacaoFormatada: '27/04/2026',
            validadeFormatada: '30/04/2026',
            hasLote: false,
            loteLabel: 'Lote',
            loteFormatado: null,
            lotePrefixo: null,
            quantidade: '10',
            saidas: '0',
            restante: '10',
            customSemLote: const {},
            formatCustomDate: (_) => '27/04/2026',
            incluirTabelaNutricional: false,
            tabelaNutricional: null,
            onOuvirEtiqueta: () {
              clicou = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Ouvir detalhes da etiqueta'), findsOneWidget);
    expect(find.text('Toque no botão para ouvir os alertas'), findsOneWidget);

    await tester.tap(find.text('Ouvir detalhes da etiqueta'));
    await tester.pump();

    expect(clicou, true);
  });
}