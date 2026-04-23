import 'package:cloud_firestore/cloud_firestore.dart';
import 'tabela_nutricional_model.dart';

class EtiquetaModel {
  final String id;
  final String tipoId;
  final String tipoNome;

  final String produtoNome;

  final String categoriaId;
  final String categoriaNome;

  final String setorId;
  final String setorNome;

  final DateTime dataFabricacao;
  final DateTime dataValidade;

  final Map<String, dynamic> camposCustomValores;

  final String status; 
  final String? lote;

  final bool incluirTabelaNutricional;
  final TabelaNutricionalModel? tabelaNutricional;

  final num quantidade; 
  final num quantidadeRestante; 
  final String statusEstoque; 
  final DateTime? soldAt; 
  final DateTime? createdAt;

  EtiquetaModel({
    required this.id,
    required this.tipoId,
    required this.tipoNome,
    required this.produtoNome,
    required this.categoriaId,
    required this.categoriaNome,
    required this.setorId,
    required this.setorNome,
    required this.dataFabricacao,
    required this.dataValidade,
    required this.camposCustomValores,
    required this.status,
    required this.lote,
    required this.incluirTabelaNutricional,
    this.tabelaNutricional,
    required this.quantidade,
    required this.quantidadeRestante,
    required this.statusEstoque,
    this.soldAt,
    this.createdAt,
  });

  static String calcStatusEstoque({
    required num restante,
    String? current,
  }) {
    final c = (current ?? "").trim().toLowerCase();
    if (c == "cancelado") return "cancelado";
    if (c == "vendido") return "vendido";
    if (restante <= 0) return "vendido";
    return "ativo";
  }

  Map<String, dynamic> toMap() => {
        "tipoId": tipoId,
        "tipoNome": tipoNome,
        "produtoNome": produtoNome,
        "categoriaId": categoriaId,
        "categoriaNome": categoriaNome,
        "setorId": setorId,
        "setorNome": setorNome,
        "dataFabricacao": Timestamp.fromDate(dataFabricacao),
        "dataValidade": Timestamp.fromDate(dataValidade),
        "camposCustomValores": camposCustomValores,
        "status": status,
        "lote": lote,
        "incluirTabelaNutricional": incluirTabelaNutricional,
        "tabelaNutricional": tabelaNutricional?.toMap(),
        "quantidade": quantidade,
        "quantidadeRestante": quantidadeRestante,
        "statusEstoque": statusEstoque,
        "soldAt": soldAt == null ? null : Timestamp.fromDate(soldAt!),
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

   EtiquetaModel copyWith({
      String? tipoId,
      String? tipoNome,
      String? produtoNome,
      String? categoriaId,
      String? categoriaNome,
      String? setorId,
      String? setorNome,
      DateTime? dataFabricacao,
      DateTime? dataValidade,
      Map<String, dynamic>? camposCustomValores,
      String? status,
      String? lote,
      bool? incluirTabelaNutricional,
      TabelaNutricionalModel? tabelaNutricional,
      num? quantidade,
      num? quantidadeRestante,
      String? statusEstoque,
      DateTime? soldAt,
      DateTime? createdAt,
    }) {
      final novoRestante = quantidadeRestante ?? this.quantidadeRestante;

      final novoStatusEstoque = statusEstoque ??
          calcStatusEstoque(
            restante: novoRestante,
            current: this.statusEstoque,
          );

      return EtiquetaModel(
        id: id,
        tipoId: tipoId ?? this.tipoId,
        tipoNome: tipoNome ?? this.tipoNome,
        produtoNome: produtoNome ?? this.produtoNome,
        categoriaId: categoriaId ?? this.categoriaId,
        categoriaNome: categoriaNome ?? this.categoriaNome,
        setorId: setorId ?? this.setorId,
        setorNome: setorNome ?? this.setorNome,
        dataFabricacao: dataFabricacao ?? this.dataFabricacao,
        dataValidade: dataValidade ?? this.dataValidade,
        camposCustomValores: camposCustomValores ?? this.camposCustomValores,
        status: status ?? this.status,
        lote: lote ?? this.lote,
        incluirTabelaNutricional:
            incluirTabelaNutricional ?? this.incluirTabelaNutricional,
        tabelaNutricional: tabelaNutricional ?? this.tabelaNutricional,
        quantidade: quantidade ?? this.quantidade,
        quantidadeRestante: novoRestante,
        statusEstoque: novoStatusEstoque,
        soldAt: soldAt ?? this.soldAt,
        createdAt: createdAt ?? this.createdAt,
      );
    }
}