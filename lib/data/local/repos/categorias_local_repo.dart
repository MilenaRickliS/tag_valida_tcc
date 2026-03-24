import 'package:sqflite/sqflite.dart';
import '../app_db.dart';
import '../outbox/outbox_helper.dart';
import '../mappers/categoria_local.dart';
import '../../../models/categoria_model.dart';

class CategoriasLocalRepo {
  Future<List<CategoriaModel>> listActive(String uid) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'categorias',
      where: 'uid = ? AND ativo = 1',
      whereArgs: [uid],
      orderBy: 'nome COLLATE NOCASE ASC',
    );

    return rows.map(CategoriaLocalMapper.fromLocalMap).toList();
  }

  Future<void> upsert(String uid, CategoriaModel cat) async {
    final db = await AppDb.instance.db;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.insert(
        'categorias',
        cat.toLocalMap(uid: uid, nowMs: nowMs),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

    
      final payload = {
        "nome": cat.nome,
        "diasVencimento": cat.diasVencimento,
        "ativo": cat.ativo,
        "createdAtMs": (cat.createdAt?.millisecondsSinceEpoch ?? nowMs),
        "updatedAtMs": nowMs,
      };

      await OutboxHelper.enqueueUpsert(
        txn: txn,
        uid: uid,
        entity: "categorias",
        entityId: cat.id,
        payload: payload,
        nowMs: nowMs,
      );
    });
  }

  Future<void> softDelete(String uid, String id) async {
    final db = await AppDb.instance.db;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.update(
        'categorias',
        {'ativo': 0, 'updatedAt': nowMs},
        where: 'uid = ? AND id = ?',
        whereArgs: [uid, id],
      );

      await OutboxHelper.enqueueUpsert(
        txn: txn,
        uid: uid,
        entity: "categorias",
        entityId: id,
        payload: {
          "ativo": false,
          "updatedAtMs": nowMs,
        },
        nowMs: nowMs,
      );
    });
  }
}