import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/local/repos/categorias_local_repo.dart';
import '../models/categoria_model.dart';

class CategoriasProvider extends ChangeNotifier {
  final CategoriasLocalRepo? localRepo;
  final FirebaseFirestore firestore;

  CategoriasProvider({
    required this.firestore,
    this.localRepo,
  });

  List<CategoriaModel> _items = [];
  List<CategoriaModel> get items => _items;

  bool loading = false;

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return firestore.collection('usuarios').doc(uid).collection('categorias');
  }

  Future<void> fetch(String uid) async {
    loading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        final snap = await _col(uid)
            .where('ativo', isEqualTo: true)
            .orderBy('nome')
            .get();

        _items = snap.docs.map(CategoriaModel.fromDoc).toList();
      } else {
        _items = await localRepo!.listActive(uid);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create(
    String uid, {
    required String nome,
    required int diasVencimento,
  }) async {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    final model = CategoriaModel(
      id: id,
      nome: nome.trim(),
      diasVencimento: diasVencimento,
      ativo: true,
      createdAt: now,
      updatedAt: now,
    );

    if (kIsWeb) {
      await _col(uid).doc(id).set(model.toMap());
    } else {
      await localRepo!.upsert(uid, model);
    }

    await fetch(uid);
  }

  Future<void> update(String uid, CategoriaModel cat) async {
    final atualizado = CategoriaModel(
      id: cat.id,
      nome: cat.nome.trim(),
      diasVencimento: cat.diasVencimento,
      ativo: cat.ativo,
      createdAt: cat.createdAt,
      updatedAt: DateTime.now(),
    );

    if (kIsWeb) {
      await _col(uid).doc(cat.id).set(atualizado.toMap(), SetOptions(merge: true));
    } else {
      await localRepo!.upsert(uid, atualizado);
    }

    await fetch(uid);
  }

  Future<void> softDelete(String uid, String id) async {
    if (kIsWeb) {
      await _col(uid).doc(id).set({
        'ativo': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await localRepo!.softDelete(uid, id);
    }

    await fetch(uid);
  }
}