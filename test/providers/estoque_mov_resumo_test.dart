import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tag_valida/data/local/repos/estoque_mov_local_repo.dart';
import 'package:tag_valida/models/estoque_mov_model.dart';
import 'package:tag_valida/providers/estoque_mov_provider.dart';

class MockEstoqueMovLocalRepo extends Mock implements EstoqueMovLocalRepo {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late MockEstoqueMovLocalRepo repo;
  late MockFirebaseFirestore firestore;
  late EstoqueMovProvider provider;

  EstoqueMovModel mov({
    required String tipo,
    required num quantidade,
  }) {
    final now = DateTime.now();

    return EstoqueMovModel(
      id: '${tipo}_$quantidade',
      etiquetaId: 'etiqueta1',
      tipo: tipo,
      quantidade: quantidade,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    repo = MockEstoqueMovLocalRepo();
    firestore = MockFirebaseFirestore();

    provider = EstoqueMovProvider(
      firestore: firestore,
      repo: repo,
    );

    when(() => repo.listAll(uid: 'user1', limit: 2000)).thenAnswer(
      (_) async => [
        mov(tipo: EstoqueMovModel.tipoEntrada, quantidade: 10),
        mov(tipo: EstoqueMovModel.tipoAjusteEntrada, quantidade: 5),
        mov(tipo: EstoqueMovModel.tipoVenda, quantidade: 3),
        mov(tipo: EstoqueMovModel.tipoCancelamento, quantidade: 2),
        mov(tipo: EstoqueMovModel.tipoUso, quantidade: 1),
        mov(tipo: EstoqueMovModel.tipoDescarte, quantidade: 4),
        mov(tipo: EstoqueMovModel.tipoAjusteSaida, quantidade: 2),
      ],
    );
  });

  test('deve calcular movimentações por tipo no histórico', () async {
    final resumo = await provider.resumo(uid: 'user1');

    expect(resumo.entradas, 15);
    expect(resumo.saidasVenda, 3);
    expect(resumo.saidasCancelamento, 9);
    expect(resumo.saldo, 3);
  });
}