import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tag_valida/screens/home/widgets/produtos_status_card.dart';

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    binding.platformDispatcher.views.first.physicalSize = const Size(1200, 800);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  Widget buildCard({
    required int qtdVencidas,
    required int qtdAlerta,
    bool loading = false,
    VoidCallback? onOuvirResumo,
  }) {
    return MaterialApp(
      routes: {
        '/etiquetas-ativas': (_) => const Scaffold(
              body: Text('Tela etiquetas ativas'),
            ),
      },
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 900,
            child: ProdutosStatusCard(
              qtdVencidas: qtdVencidas,
              qtdAlerta: qtdAlerta,
              loading: loading,
              titleSize: 22,
              subtitleSize: 13,
              onOuvirResumo: onOuvirResumo ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('deve mostrar loading quando estiver carregando', (tester) async {
    await tester.pumpWidget(
      buildCard(
        qtdVencidas: 0,
        qtdAlerta: 0,
        loading: true,
      ),
    );

    expect(find.text('Carregando status dos produtos'), findsOneWidget);
    expect(
      find.text('Aguarde enquanto os indicadores são atualizados.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('deve mostrar produtos vencidos quando houver vencidas',
      (tester) async {
    await tester.pumpWidget(
      buildCard(
        qtdVencidas: 2,
        qtdAlerta: 1,
      ),
    );

    expect(find.text('Produtos vencidos'), findsOneWidget);
    expect(find.text('2 vencido(s)'), findsOneWidget);
    expect(
      find.text('Clique aqui para visualizar seus produtos vencidos'),
      findsOneWidget,
    );
  });

  testWidgets('deve mostrar produtos em alerta quando não houver vencidas',
      (tester) async {
    await tester.pumpWidget(
      buildCard(
        qtdVencidas: 0,
        qtdAlerta: 3,
      ),
    );

    expect(find.text('Produtos em alerta'), findsOneWidget);
    expect(find.text('3 em alerta'), findsOneWidget);
    expect(
      find.text('Clique aqui para visualizar seus produtos em alerta'),
      findsOneWidget,
    );
  });

  testWidgets('deve mostrar todos dentro da validade quando não houver alertas',
      (tester) async {
    await tester.pumpWidget(
      buildCard(
        qtdVencidas: 0,
        qtdAlerta: 0,
      ),
    );

    expect(find.text('Todos os produtos\ndentro da validade'), findsOneWidget);
    expect(find.text('Clique aqui para visualizar seus produtos'), findsOneWidget);
  });

  testWidgets('deve executar ação de ouvir resumo ao tocar no botão',
      (tester) async {
    var clicou = false;

    await tester.pumpWidget(
      buildCard(
        qtdVencidas: 1,
        qtdAlerta: 0,
        onOuvirResumo: () {
          clicou = true;
        },
      ),
    );

    expect(find.text('Ouvir resumo'), findsOneWidget);
    expect(find.text('Toque no botão para ouvir os alertas'), findsOneWidget);

    await tester.tap(find.text('Ouvir resumo'));
    await tester.pump();

    expect(clicou, true);
  });
}