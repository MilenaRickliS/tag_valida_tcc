import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/local/repos/setores_local_repo.dart';
import '../models/setor_model.dart';

class SetoresProvider extends ChangeNotifier {
  final SetoresLocalRepo? localRepo;
  final FirebaseFirestore firestore;

  SetoresProvider({
    required this.firestore,
    this.localRepo,
  });

  List<SetorModel> _items = [];
  List<SetorModel> get items => _items;

  bool loading = false;

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return firestore.collection('usuarios').doc(uid).collection('setores');
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

        _items = snap.docs.map(SetorModel.fromDoc).toList();
      } else {
        _items = await localRepo!.listActive(uid);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create(String uid,
      {required String nome, String? descricao}) async {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    final model = SetorModel(
      id: id,
      nome: nome.trim(),
      descricao: descricao,
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

  Future<void> update(String uid, SetorModel s) async {
    final atualizado = SetorModel(
      id: s.id,
      nome: s.nome.trim(),
      descricao: s.descricao,
      ativo: s.ativo,
      createdAt: s.createdAt,
      updatedAt: DateTime.now(),
    );

    if (kIsWeb) {
      await _col(uid)
          .doc(s.id)
          .set(atualizado.toMap(), SetOptions(merge: true));
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