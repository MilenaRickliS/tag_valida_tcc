import 'package:cloud_firestore/cloud_firestore.dart';
import './tabela_nutricional_model.dart';

class EtiquetaTemplateModel {
  final String id;
  final String tipoId;
  final String tipoNome;

  final String produtoNome;

  final String categoriaId;
  final String categoriaNome;

  final String setorId;
  final String setorNome;

  final Map<String, dynamic> camposCustomValores;

  final bool incluirTabelaNutricional;
  final TabelaNutricionalModel? tabelaNutricional;

  final num quantidadePadrao;
  final String unidadeMedidaPadrao;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  EtiquetaTemplateModel({
    required this.id,
    required this.tipoId,
    required this.tipoNome,
    required this.produtoNome,
    required this.categoriaId,
    required this.categoriaNome,
    required this.setorId,
    required this.setorNome,
    required this.camposCustomValores,
    required this.quantidadePadrao,
    this.unidadeMedidaPadrao = 'un',
    required this.incluirTabelaNutricional,
    this.tabelaNutricional,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'tipoId': tipoId,
        'tipoNome': tipoNome,
        'produtoNome': produtoNome,
        'categoriaId': categoriaId,
        'categoriaNome': categoriaNome,
        'setorId': setorId,
        'setorNome': setorNome,
        'camposCustomValores': camposCustomValores,
        'quantidadePadrao': quantidadePadrao,
        'unidadeMedidaPadrao': unidadeMedidaPadrao,
        'incluirTabelaNutricional': incluirTabelaNutricional,
        'tabelaNutricional': tabelaNutricional?.toMap(),
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory EtiquetaTemplateModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});

    DateTime? dt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return null;
    }

    final tabelaMap = data['tabelaNutricional'];
    final tabela = tabelaMap is Map<String, dynamic>
        ? TabelaNutricionalModel.fromMap(tabelaMap)
        : tabelaMap is Map
            ? TabelaNutricionalModel.fromMap(
                Map<String, dynamic>.from(tabelaMap),
              )
            : null;

    final unidadeRaw = (data['unidadeMedidaPadrao'] ?? 'un')
        .toString()
        .trim()
        .toLowerCase();

    final unidadeMedidaPadrao = unidadeRaw == 'kg' ? 'kg' : 'un';

    return EtiquetaTemplateModel(
      id: doc.id,
      tipoId: (data['tipoId'] ?? '').toString(),
      tipoNome: (data['tipoNome'] ?? '').toString(),
      produtoNome: (data['produtoNome'] ?? '').toString(),
      categoriaId: (data['categoriaId'] ?? '').toString(),
      categoriaNome: (data['categoriaNome'] ?? '').toString(),
      setorId: (data['setorId'] ?? '').toString(),
      setorNome: (data['setorNome'] ?? '').toString(),
      camposCustomValores: Map<String, dynamic>.from(
        data['camposCustomValores'] ?? {},
      ),
      incluirTabelaNutricional: data['incluirTabelaNutricional'] == true,
      tabelaNutricional: tabela,
      quantidadePadrao: (data['quantidadePadrao'] as num?) ?? 1,
      unidadeMedidaPadrao: unidadeMedidaPadrao,
      createdAt: dt(data['createdAt']),
      updatedAt: dt(data['updatedAt']),
    );
  }
}