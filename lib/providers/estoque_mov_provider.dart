import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/local/repos/estoque_mov_local_repo.dart';
import '../models/estoque_mov_model.dart';
import '../models/estoque_mov_resumo.dart';

class EstoqueMovProvider extends ChangeNotifier {
  final EstoqueMovLocalRepo? repo;
  final FirebaseFirestore firestore;

  EstoqueMovProvider({
    required this.firestore,
    this.repo,
  });

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return firestore.collection('usuarios').doc(uid).collection('estoque_mov');
  }

  Future<List<EstoqueMovModel>> listAll({
    required String uid,
    int limit = 500,
  }) async {
    if (kIsWeb) {
      final snap = await _col(uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map(EstoqueMovModel.fromDoc).toList();
    } else {
      return repo!.listAll(uid: uid, limit: limit);
    }
  }

 Future<List<EstoqueMovModel>> listByEtiqueta({
    required String uid,
    required String etiquetaId,
    int limit = 200,
  }) async {
    if (kIsWeb) {
      final snap = await _col(uid)
          .orderBy('createdAt', descending: true)
          .limit(limit * 5)
          .get();

      var itens = snap.docs
          .map(EstoqueMovModel.fromDoc)
          .where((e) => e.etiquetaId == etiquetaId)
          .toList();

      if (itens.length > limit) {
        itens = itens.take(limit).toList();
      }

      return itens;
    } else {
      return repo!.listByEtiqueta(
        uid: uid,
        etiquetaId: etiquetaId,
        limit: limit,
      );
    }
  }

  Future<EstoqueMovResumo> resumo({
    required String uid,
    String unidadeMedida = 'un',
  }) async {
    final itens = await listAll(uid: uid, limit: 2000);

    final filtrados = itens
        .where((e) => e.unidadeMedida == unidadeMedida)
        .toList();

    num sumTipo(String tipo) {
      return filtrados
          .where((e) => e.tipo == tipo)
          .fold<num>(0, (s, e) => s + e.quantidade);
    }

    final entradas = sumTipo(EstoqueMovModel.tipoEntrada) +
        sumTipo(EstoqueMovModel.tipoAjusteEntrada);

    final saidasVenda = sumTipo(EstoqueMovModel.tipoVenda);

    final outrasSaidas = sumTipo(EstoqueMovModel.tipoCancelamento) +
        sumTipo(EstoqueMovModel.tipoAjusteSaida) +
        sumTipo(EstoqueMovModel.tipoUso) +
        sumTipo(EstoqueMovModel.tipoDescarte);

    final saldo = entradas - (saidasVenda + outrasSaidas);

    return EstoqueMovResumo(
      entradas: entradas,
      saidasVenda: saidasVenda,
      saidasCancelamento: outrasSaidas,
      saldo: saldo,
    );
  }

  Future<void> _saveMov(String uid, EstoqueMovModel mov) async {
    if (kIsWeb) {
      await _col(uid).doc(mov.id).set(mov.toMap());
    } else {
      await repo!.insertAndEnqueue(uid, mov);
    }
  }

  Future<void> registrar({
    required String uid,
    required String etiquetaId,
    required String tipo,
    required num quantidade,
    required String unidadeMedida,
    String? produtoNome,
    String? motivo,
  }) async {
    final now = DateTime.now();

    final mov = EstoqueMovModel(
      id: now.millisecondsSinceEpoch.toString(),
      etiquetaId: etiquetaId,
      produtoNome: produtoNome,
      tipo: tipo,
      quantidade: quantidade,
      unidadeMedida: unidadeMedida,
      motivo: motivo,
      createdAt: now,
      updatedAt: now,
    );

    await _saveMov(uid, mov);
    notifyListeners();
  }

  Future<void> registrarEntrada({
    required String uid,
    required String etiquetaId,
    required num quantidade,
    required String unidadeMedida,
    String? produtoNome,
    String? motivo,
  }) async {
    await registrar(
      uid: uid,
      etiquetaId: etiquetaId,
      tipo: EstoqueMovModel.tipoEntrada,
      quantidade: quantidade,
      unidadeMedida: unidadeMedida,
      produtoNome: produtoNome,
      motivo: motivo ?? "Entrada",
    );
  }

  Future<void> registrarVenda({
    required String uid,
    required String etiquetaId,
    required num quantidade,
    required String unidadeMedida,
    String? produtoNome,
    String? motivo,
  }) async {
    await registrar(
      uid: uid,
      etiquetaId: etiquetaId,
      tipo: EstoqueMovModel.tipoVenda,
      quantidade: quantidade,
      unidadeMedida: unidadeMedida,
      produtoNome: produtoNome,
      motivo: motivo ?? "Venda",
    );
  }

  Future<void> registrarCancelamento({
    required String uid,
    required String etiquetaId,
    required num quantidade,
    required String unidadeMedida,
    String? produtoNome,
    String? motivo,
  }) async {
    await registrar(
      uid: uid,
      etiquetaId: etiquetaId,
      tipo: EstoqueMovModel.tipoCancelamento,
      quantidade: quantidade,
      unidadeMedida: unidadeMedida,
      produtoNome: produtoNome,
      motivo: motivo ?? "Cancelamento",
    );
  }

  Future<void> registrarExclusao({
    required String uid,
    required String etiquetaId,
    num quantidade = 0,
    String unidadeMedida = 'un',
    String? produtoNome,
    String? motivo,
  }) async {
    await registrar(
      uid: uid,
      etiquetaId: etiquetaId,
      tipo: EstoqueMovModel.tipoExclusao,
      quantidade: quantidade,
      unidadeMedida: unidadeMedida,
      produtoNome: produtoNome,
      motivo: motivo ?? "Exclusão (suave)",
    );
  }

  Future<void> registrarMovimento({
    required String uid,
    required EstoqueMovModel mov,
  }) async {
    await _saveMov(uid, mov);
    notifyListeners();
  }
}