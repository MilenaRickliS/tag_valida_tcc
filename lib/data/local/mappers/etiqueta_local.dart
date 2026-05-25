import 'dart:convert';
import '../../../models/etiqueta_model.dart';
import '../../../models/tabela_nutricional_model.dart';

extension EtiquetaLocalMapper on EtiquetaModel {
  Map<String, dynamic> toLocalMap({
    required String uid,
    required int nowMs,
  }) {
    return {
      'id': id,
      'uid': uid,
      'tipoId': tipoId,
      'tipoNome': tipoNome,
      'produtoNome': produtoNome,
      'categoriaId': categoriaId,
      'categoriaNome': categoriaNome,
      'setorId': setorId,
      'setorNome': setorNome,
      'dataFabricacaoMs': dataFabricacao.millisecondsSinceEpoch,
      'dataValidadeMs': dataValidade.millisecondsSinceEpoch,
      'camposCustomValoresJson': jsonEncode(camposCustomValores),
      'status': status,
      'lote': lote,
      'incluirTabelaNutricional': incluirTabelaNutricional ? 1 : 0,
      'tabelaNutricionalJson': tabelaNutricional == null ? null : jsonEncode(tabelaNutricional!.toMap()),
      'quantidade': quantidade,
      'quantidadeRestante': quantidadeRestante,
      'unidadeMedida': unidadeMedida,
      'statusEstoque': statusEstoque,
      'soldAtMs': soldAt?.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? nowMs,
      'updatedAt': nowMs,
    };
  }

 static EtiquetaModel fromLocalMap(Map<String, dynamic> m) {
    DateTime? dtMsNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      final parsed = int.tryParse(v.toString());
      if (parsed == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(parsed);
    }

    DateTime dtMs(dynamic v) => dtMsNullable(v) ?? DateTime.fromMillisecondsSinceEpoch(0);

    final valoresStr = (m['camposCustomValoresJson'] ?? '{}').toString();
    final Map<String, dynamic> valores = (jsonDecode(valoresStr) as Map).map(
      (k, v) => MapEntry(k.toString(), v),
    );

    num asNum(dynamic v, {num def = 1}) {
      if (v == null) return def;
      if (v is num) return v;
      return num.tryParse(v.toString().replaceAll(",", ".")) ?? def;
    }

    final qtd = asNum(m['quantidade'], def: 1);
    final rest = asNum(m['quantidadeRestante'], def: qtd);
    final unidadeMedidaRaw = (m['unidadeMedida'] ?? 'un').toString().trim().toLowerCase();
    final unidadeMedida = unidadeMedidaRaw == 'kg' ? 'kg' : 'un';
    final soldAt = dtMsNullable(m['soldAtMs']);

    final statusEstoqueRaw = (m['statusEstoque'] ?? '').toString().trim().toLowerCase();

    final statusEstoque = statusEstoqueRaw.isEmpty
        ? EtiquetaModel.calcStatusEstoque(restante: rest, current: null)
        : statusEstoqueRaw;

    final tabelaStr = m['tabelaNutricionalJson']?.toString();
    final tabela = (tabelaStr == null || tabelaStr.trim().isEmpty)
        ? null
        : TabelaNutricionalModel.fromMap(
            Map<String, dynamic>.from(jsonDecode(tabelaStr)),
          );

    return EtiquetaModel(
      id: (m['id'] ?? '').toString(),
      tipoId: (m['tipoId'] ?? '').toString(),
      tipoNome: (m['tipoNome'] ?? '').toString(),
      produtoNome: (m['produtoNome'] ?? '').toString(),
      categoriaId: (m['categoriaId'] ?? '').toString(),
      categoriaNome: (m['categoriaNome'] ?? '').toString(),
      setorId: (m['setorId'] ?? '').toString(),
      setorNome: (m['setorNome'] ?? '').toString(),
      dataFabricacao: dtMs(m['dataFabricacaoMs']),
      dataValidade: dtMs(m['dataValidadeMs']),
      camposCustomValores: valores,
      status: (m['status'] ?? 'ativa').toString(),
      lote: (m['lote'] ?? '').toString().trim().isEmpty ? null : (m['lote'] ?? '').toString(),
      incluirTabelaNutricional: (m['incluirTabelaNutricional'] ?? 0) == 1,
      tabelaNutricional: tabela,
      quantidade: qtd,
      quantidadeRestante: rest,
      unidadeMedida: unidadeMedida,
      statusEstoque: statusEstoque,
      soldAt: soldAt,
      createdAt: dtMsNullable(m['createdAt']),
    );
  }
}