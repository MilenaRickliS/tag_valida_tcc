import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/local/repos/etiqueta_template_local_repo.dart';
import '../models/etiqueta_template_model.dart';

class TemplatesProvider extends ChangeNotifier {
  final EtiquetasTemplatesLocalRepo? repo;
  final FirebaseFirestore firestore;

  TemplatesProvider({
    required this.firestore,
    this.repo,
  });

  bool loading = false;
  List<EtiquetaTemplateModel> items = [];

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return firestore
        .collection('usuarios')
        .doc(uid)
        .collection('etiquetas_templates');
  }

  String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r"\s+"), " ").trim();

  Future<void> fetch(String uid) async {
    loading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        final snap = await _col(uid).orderBy('updatedAt', descending: true).get();
        items = snap.docs.map(EtiquetaTemplateModel.fromDoc).toList();
      } else {
        items = await repo!.listAll(uid: uid);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> delete({
    required String uid,
    required String id,
  }) async {
    if (kIsWeb) {
      await _col(uid).doc(id).delete();
    } else {
      await repo!.delete(uid: uid, id: id);
    }
    await fetch(uid);
  }

  Future<EtiquetaTemplateModel?> getById({
    required String uid,
    required String id,
  }) async {
    if (kIsWeb) {
      final doc = await _col(uid).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return EtiquetaTemplateModel.fromDoc(doc);
    } else {
      return repo!.getById(uid: uid, id: id);
    }
  }

  Future<EtiquetaTemplateModel?> findByKey({
    required String uid,
    required String produtoNome,
    required String categoriaId,
    required String setorId,
  }) async {
    if (kIsWeb) {
      final snap = await _col(uid)
          .where('categoriaId', isEqualTo: categoriaId)
          .where('setorId', isEqualTo: setorId)
          .get();

      final alvo = _norm(produtoNome);

      for (final doc in snap.docs) {
        final t = EtiquetaTemplateModel.fromDoc(doc);
        if (_norm(t.produtoNome) == alvo) {
          return t;
        }
      }
      return null;
    } else {
      return repo!.findByKey(
        uid: uid,
        produtoNome: produtoNome,
        categoriaId: categoriaId,
        setorId: setorId,
      );
    }
  }
}