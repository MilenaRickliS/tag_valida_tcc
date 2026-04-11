import 'package:sqflite/sqflite.dart';
import '../app_db.dart';
import '../mappers/estoque_mov_local.dart';
import '../../../models/estoque_mov_model.dart';
import '../../../models/estoque_mov_resumo.dart';
import '../outbox/outbox_helper.dart';

class EstoqueMovLocalRepo {
  Future<void> insert(String uid, EstoqueMovModel mov) async {
    final db = await AppDb.instance.db;

    await db.transaction((txn) async {
      final payload = mov.toLocalMap(uid: uid);

      await txn.insert(
        "estoque_mov",
        payload,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      payload["createdAtMs"] = mov.createdAt.millisecondsSinceEpoch;
      payload["updatedAtMs"] = mov.updatedAt.millisecondsSinceEpoch;

      await OutboxHelper.enqueueUpsert(
        txn: txn,
        uid: uid,
        entity: "estoque_mov",
        entityId: mov.id,
        payload: payload,
      );
    });
  }

  Future<void> insertAndEnqueue(String uid, EstoqueMovModel mov) async {
    final db = await AppDb.instance.db;

    await db.transaction((txn) async {
      final payload = mov.toLocalMap(uid: uid);

      await txn.insert(
        "estoque_mov",
        payload,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      payload["createdAtMs"] = mov.createdAt.millisecondsSinceEpoch;
      payload["updatedAtMs"] = mov.updatedAt.millisecondsSinceEpoch;

      await OutboxHelper.enqueueUpsert(
        txn: txn,
        uid: uid,
        entity: "estoque_mov",
        entityId: mov.id,
        payload: payload,
      );
    });
  }

  Future<List<EstoqueMovModel>> listAll({
    required String uid,
    int limit = 500,
  }) async {
    final db = await AppDb.instance.db;
    final rows = await db.query(
      "estoque_mov",
      where: "uid = ?",
      whereArgs: [uid],
      orderBy: "createdAt DESC",
      limit: limit,
    );
    return rows.map(EstoqueMovLocalMapper.fromLocalMap).toList();
  }

  Future<List<EstoqueMovModel>> listByEtiqueta({
    required String uid,
    required String etiquetaId,
    int limit = 200,
  }) async {
    final db = await AppDb.instance.db;
    final rows = await db.query(
      "estoque_mov",
      where: "uid = ? AND etiquetaId = ?",
      whereArgs: [uid, etiquetaId],
      orderBy: "createdAt DESC",
      limit: limit,
    );
    return rows.map(EstoqueMovLocalMapper.fromLocalMap).toList();
  }

  Future<EstoqueMovResumo> resumo({required String uid}) async {
    final db = await AppDb.instance.db;

    Future<num> sumTipo(String tipo) async {
      final r = await db.rawQuery(
        "SELECT COALESCE(SUM(quantidade), 0) AS s FROM estoque_mov WHERE uid = ? AND tipo = ?",
        [uid, tipo],
      );
      return (r.first["s"] as num?) ?? 0;
    }

    final entradas = await sumTipo(EstoqueMovModel.tipoEntrada) +
        await sumTipo(EstoqueMovModel.tipoAjusteEntrada);

    final saidasVenda = await sumTipo(EstoqueMovModel.tipoVenda);

    final outrasSaidas =
        await sumTipo(EstoqueMovModel.tipoCancelamento) +
            await sumTipo(EstoqueMovModel.tipoAjusteSaida) +
            await sumTipo(EstoqueMovModel.tipoUso) +
            await sumTipo(EstoqueMovModel.tipoDescarte);

    final saldo = entradas - (saidasVenda + outrasSaidas);

    return EstoqueMovResumo(
      entradas: entradas,
      saidasVenda: saidasVenda,
      saidasCancelamento: outrasSaidas,
      saldo: saldo,
    );
  }
}