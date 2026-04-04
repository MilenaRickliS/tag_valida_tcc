import 'package:cloud_firestore/cloud_firestore.dart';

enum CampoTipo { text, number, multiline, date, boolType, image }

CampoTipo campoTipoFromString(String s) {
  switch (s) {
    case "number":
      return CampoTipo.number;
    case "multiline":
      return CampoTipo.multiline;
    case "date":
      return CampoTipo.date;
    case "bool":
      return CampoTipo.boolType;
    case "image":
      return CampoTipo.image;
    default:
      return CampoTipo.text;
  }
}

String campoTipoToString(CampoTipo t) {
  switch (t) {
    case CampoTipo.number:
      return "number";
    case CampoTipo.multiline:
      return "multiline";
    case CampoTipo.date:
      return "date";
    case CampoTipo.boolType:
      return "bool";
    case CampoTipo.image:
      return "image";
    case CampoTipo.text:
      return "text";
  }
}

class CampoCustomModel {
  final String key;
  final String label;
  final CampoTipo tipo;
  final bool obrigatorio;

  CampoCustomModel({
    required this.key,
    required this.label,
    required this.tipo,
    required this.obrigatorio,
  });

  Map<String, dynamic> toMap() => {
        "key": key,
        "label": label,
        "tipo": campoTipoToString(tipo),
        "obrigatorio": obrigatorio,
      };

  factory CampoCustomModel.fromMap(Map<String, dynamic> m) => CampoCustomModel(
        key: (m["key"] ?? "").toString(),
        label: (m["label"] ?? "").toString(),
        tipo: campoTipoFromString((m["tipo"] ?? "text").toString()),
        obrigatorio: m["obrigatorio"] == true,
      );
}

class TipoEtiquetaModel {
  final String id;
  final String nome;
  final String? descricao;
  final bool usarRegraValidadeCategoria;
  final List<CampoCustomModel> camposCustom;
  final bool controlaLote;
  final bool permiteTabelaNutricional;
  final double larguraMm;
  final double alturaMm;

  TipoEtiquetaModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.usarRegraValidadeCategoria,
    required this.controlaLote,
    required this.camposCustom,
    required this.permiteTabelaNutricional,
    this.larguraMm = 60,
    this.alturaMm = 40,
  });

  TipoEtiquetaModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    bool? usarRegraValidadeCategoria,
    List<CampoCustomModel>? camposCustom,
    bool? controlaLote,
    bool? permiteTabelaNutricional,
    double? larguraMm,
    double? alturaMm,
  }) {
    return TipoEtiquetaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      usarRegraValidadeCategoria:
          usarRegraValidadeCategoria ?? this.usarRegraValidadeCategoria,
      controlaLote: controlaLote ?? this.controlaLote,
      camposCustom: camposCustom ?? this.camposCustom,
      permiteTabelaNutricional:
          permiteTabelaNutricional ?? this.permiteTabelaNutricional,
      larguraMm: larguraMm ?? this.larguraMm,
      alturaMm: alturaMm ?? this.alturaMm,
    );
  }

  Map<String, dynamic> toMap() => {
        "nome": nome,
        "descricao": descricao,
        "usarRegraValidadeCategoria": usarRegraValidadeCategoria,
        "controlaLote": controlaLote,
        "permiteTabelaNutricional": permiteTabelaNutricional,
        "larguraMm": larguraMm,
        "alturaMm": alturaMm,
        "camposCustom": camposCustom.map((c) => c.toMap()).toList(),
        "updatedAt": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      };

  factory TipoEtiquetaModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final list = (data["camposCustom"] as List? ?? [])
        .map((e) => CampoCustomModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return TipoEtiquetaModel(
      id: doc.id,
      nome: (data["nome"] ?? "").toString(),
      descricao: data["descricao"]?.toString(),
      usarRegraValidadeCategoria:
          data["usarRegraValidadeCategoria"] == null
              ? true
              : data["usarRegraValidadeCategoria"] == true,
      camposCustom: list,
      controlaLote: data["controlaLote"] == true,
      permiteTabelaNutricional: data["permiteTabelaNutricional"] == true,
      larguraMm: (data["larguraMm"] as num?)?.toDouble() ?? 60,
      alturaMm: (data["alturaMm"] as num?)?.toDouble() ?? 40,
    );
  }
}