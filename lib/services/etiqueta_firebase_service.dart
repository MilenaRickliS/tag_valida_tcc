import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/etiqueta_model.dart';
import '../models/tabela_nutricional_model.dart';

class EtiquetaFirebaseService {
  Future<EtiquetaModel?> getById({
    required String uid,
    required String id,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .collection("etiquetas")
        .doc(id)
        .get();

    if (!doc.exists) return null;
    final data = doc.data()!;

    DateTime dt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      return DateTime.now();
    }

    bool toBool(dynamic v, {bool defaultValue = false}) {
      if (v == null) return defaultValue;
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is num) return v.toInt() == 1;
      final s = v.toString().trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
      return defaultValue;
    }

    final tabelaMap = data["tabelaNutricional"];
    final tabelaNutricional = (tabelaMap is Map)
        ? TabelaNutricionalModel.fromMap(
            Map<String, dynamic>.from(tabelaMap),
          )
        : null;

    return EtiquetaModel(
      id: doc.id,
      tipoId: (data["tipoId"] ?? "").toString(),
      tipoNome: (data["tipoNome"] ?? "").toString(),
      produtoNome: (data["produtoNome"] ?? "").toString(),
      categoriaId: (data["categoriaId"] ?? "").toString(),
      categoriaNome: (data["categoriaNome"] ?? "").toString(),
      setorId: (data["setorId"] ?? "").toString(),
      setorNome: (data["setorNome"] ?? "").toString(),
      dataFabricacao: dt(data["dataFabricacao"]),
      dataValidade: dt(data["dataValidade"]),
      camposCustomValores: Map<String, dynamic>.from(
        data["camposCustomValores"] ?? {},
      ),
      status: (data["status"] ?? "").toString(),
      lote: data["lote"]?.toString(),
      quantidade: (data["quantidade"] ?? 0) as num,
      quantidadeRestante: (data["quantidadeRestante"] ?? 0) as num,
      statusEstoque: (data["statusEstoque"] ?? "").toString(),
      soldAt: data["soldAt"] == null ? null : dt(data["soldAt"]),
      createdAt: data["createdAt"] == null ? null : dt(data["createdAt"]),
      incluirTabelaNutricional: toBool(data["incluirTabelaNutricional"]),
      tabelaNutricional: tabelaNutricional,
    );
  }
}