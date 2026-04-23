import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/local/repos/tipos_etiqueta_local_repo.dart';
import '../models/tipo_etiqueta_model.dart';

class TiposEtiquetaProvider extends ChangeNotifier {
  final TiposEtiquetaLocalRepo? localRepo;
  final FirebaseFirestore firestore;

  TiposEtiquetaProvider({
    required this.firestore,
    this.localRepo,
  });

  List<TipoEtiquetaModel> _items = [];
  List<TipoEtiquetaModel> get items => _items;

  bool loading = false;

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return firestore
        .collection('usuarios')
        .doc(uid)
        .collection('tipos_etiqueta');
  }

  Future<void> fetch(String uid) async {
    loading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        final snap = await _col(uid).orderBy('nome').get();
        _items = snap.docs.map(TipoEtiquetaModel.fromDoc).toList();
      } else {
        _items = await localRepo!.listAll(uid);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String? _trimOrNull(String? s) {
    final t = s?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  Future<void> create(String uid, TipoEtiquetaModel tipo) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final novo = TipoEtiquetaModel(
      id: id,
      nome: tipo.nome.trim(),
      descricao: _trimOrNull(tipo.descricao),
      usarRegraValidadeCategoria: tipo.usarRegraValidadeCategoria,
      controlaLote: tipo.controlaLote,
      permiteTabelaNutricional: tipo.permiteTabelaNutricional,
      camposCustom: tipo.camposCustom,
      larguraMm: tipo.larguraMm,
      alturaMm: tipo.alturaMm,
      tipoQr: tipo.tipoQr,
    );

    if (kIsWeb) {
      await _col(uid).doc(id).set(novo.toMap());
    } else {
      await localRepo!.upsert(uid, novo);
    }

    await fetch(uid);
  }

  Future<void> update(String uid, TipoEtiquetaModel tipo) async {
    final atualizado = TipoEtiquetaModel(
      id: tipo.id,
      nome: tipo.nome.trim(),
      descricao: _trimOrNull(tipo.descricao),
      usarRegraValidadeCategoria: tipo.usarRegraValidadeCategoria,
      controlaLote: tipo.controlaLote,
      permiteTabelaNutricional: tipo.permiteTabelaNutricional,
      camposCustom: tipo.camposCustom,
      larguraMm: tipo.larguraMm,
      alturaMm: tipo.alturaMm,
      tipoQr: tipo.tipoQr,
    );

    if (kIsWeb) {
      await _col(uid)
          .doc(tipo.id)
          .set(atualizado.toMap(), SetOptions(merge: true));
    } else {
      await localRepo!.upsert(uid, atualizado);
    }

    await fetch(uid);
  }

  Future<void> delete(String uid, String id) async {
    if (kIsWeb) {
      await _col(uid).doc(id).delete();
    } else {
      await localRepo!.delete(uid, id);
    }

    await fetch(uid);
  }

  Future<void> updateMedidas({
    required String uid,
    required String tipoId,
    required double larguraMm,
    required double alturaMm,
  }) async {
    final index = _items.indexWhere((e) => e.id == tipoId);
    if (index == -1) return;

    final atualizado = _items[index].copyWith(
      larguraMm: larguraMm,
      alturaMm: alturaMm,
    );

    if (kIsWeb) {
      await _col(uid).doc(tipoId).set({
        'larguraMm': larguraMm,
        'alturaMm': alturaMm,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await localRepo!.upsert(uid, atualizado);
    }

    _items[index] = atualizado;
    notifyListeners();
  }

  Future<void> updateTipoQr({
    required String uid,
    required String tipoId,
    required TipoQrEtiqueta tipoQr,
  }) async {
    final index = _items.indexWhere((e) => e.id == tipoId);
    if (index == -1) return;

    final atualizado = _items[index].copyWith(tipoQr: tipoQr);

    if (kIsWeb) {
      await _col(uid).doc(tipoId).set({
        'tipoQr': tipoQrEtiquetaToString(tipoQr),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await localRepo!.upsert(uid, atualizado);
    }

    _items[index] = atualizado;
    notifyListeners();
  }
}