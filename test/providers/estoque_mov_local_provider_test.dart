import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tag_valida/providers/estoque_mov_local_provider.dart';
import 'package:tag_valida/data/local/repos/estoque_mov_local_repo.dart';
import 'package:tag_valida/models/estoque_mov_model.dart';

class MockEstoqueMovLocalRepo extends Mock implements EstoqueMovLocalRepo {}

class FakeEstoqueMovModel extends Fake implements EstoqueMovModel {}

void main() {
  late MockEstoqueMovLocalRepo repo;
  late EstoqueMovLocalProvider provider;
  int notifyCount = 0;

  setUpAll(() {
    registerFallbackValue(FakeEstoqueMovModel());
  });

  setUp(() {
    repo = MockEstoqueMovLocalRepo();
    provider = EstoqueMovLocalProvider(repo: repo);
    notifyCount = 0;

    provider.addListener(() {
      notifyCount++;
    });

    when(() => repo.insertAndEnqueue(any(), any()))
        .thenAnswer((_) async {});
  });

  group('EstoqueMovLocalProvider', () {
    test('deve registrar entrada no estoque', () async {
      await provider.registrarEntrada(
        uid: 'user1',
        etiquetaId: 'etiqueta1',
        quantidade: 10,
        unidadeMedida: 'un',
        produtoNome: 'Pão francês',
      );

      final mov = verify(
        () => repo.insertAndEnqueue('user1', captureAny()),
      ).captured.single as EstoqueMovModel;

      expect(mov.etiquetaId, 'etiqueta1');
      expect(mov.produtoNome, 'Pão francês');
      expect(mov.tipo, EstoqueMovModel.tipoEntrada);
      expect(mov.quantidade, 10);
      expect(mov.motivo, 'Entrada');
      expect(notifyCount, 1);
    });

    test('deve registrar venda no estoque', () async {
      await provider.registrarVenda(
        uid: 'user1',
        etiquetaId: 'etiqueta1',
        quantidade: 2,
        unidadeMedida: 'un',
        produtoNome: 'Pão francês',
      );

      final mov = verify(
        () => repo.insertAndEnqueue('user1', captureAny()),
      ).captured.single as EstoqueMovModel;

      expect(mov.tipo, EstoqueMovModel.tipoVenda);
      expect(mov.quantidade, 2);
      expect(mov.motivo, 'Venda');
      expect(notifyCount, 1);
    });

    test('deve registrar cancelamento no estoque', () async {
      await provider.registrarCancelamento(
        uid: 'user1',
        etiquetaId: 'etiqueta1',
        quantidade: 5,
        unidadeMedida: 'un',
        produtoNome: 'Pão francês',
      );

      final mov = verify(
        () => repo.insertAndEnqueue('user1', captureAny()),
      ).captured.single as EstoqueMovModel;

      expect(mov.tipo, EstoqueMovModel.tipoCancelamento);
      expect(mov.quantidade, 5);
      expect(mov.motivo, 'Cancelamento');
      expect(notifyCount, 1);
    });

    test('deve registrar exclusão suave no estoque', () async {
      await provider.registrarExclusao(
        uid: 'user1',
        etiquetaId: 'etiqueta1',
        produtoNome: 'Pão francês',
      );

      final mov = verify(
        () => repo.insertAndEnqueue('user1', captureAny()),
      ).captured.single as EstoqueMovModel;

      expect(mov.tipo, EstoqueMovModel.tipoExclusao);
      expect(mov.quantidade, 0);
      expect(mov.motivo, 'Exclusão (suave)');
      expect(notifyCount, 1);
    });

    test('deve registrar movimentação genérica com tipo informado', () async {
      await provider.registrar(
        uid: 'user1',
        etiquetaId: 'etiqueta1',
        tipo: 'descarte',
        quantidade: 3,
        unidadeMedida: 'kg',
        produtoNome: 'Pão francês',
        motivo: 'Produto vencido',
      );

      final mov = verify(
        () => repo.insertAndEnqueue('user1', captureAny()),
      ).captured.single as EstoqueMovModel;

      expect(mov.tipo, 'descarte');
      expect(mov.quantidade, 3);
      expect(mov.motivo, 'Produto vencido');
      expect(notifyCount, 1);
    });
  });
}