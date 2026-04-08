import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_model.dart';

class DesignEtiquetaMapper {
  static DesignEtiquetaModel fromMap(Map<String, dynamic> map) {
    final camposMap = (map['campos'] as List? ?? [])
        .map(
          (e) => CampoDesignEtiquetaModel(
            id: e['id'] ?? '',
            nome: e['nome'] ?? '',
            tipo: CampoDesignTipo.values.firstWhere(
              (t) => t.name == e['tipo'],
              orElse: () => CampoDesignTipo.info,
            ),
            labelImpresso: e['labelImpresso'],
            obrigatorio: e['obrigatorio'] ?? false,
            visivel: e['visivel'] ?? true,
            fontSize: (e['fontSize'] ?? 10).toDouble(),
            isBold: e['isBold'] ?? false,
            align: _textAlignFromString(e['align']),
            ordem: e['ordem'] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return DesignEtiquetaModel(
      tipoEtiquetaId: map['tipoEtiquetaId'] ?? '',
      tipoEtiquetaNome: map['tipoEtiquetaNome'] ?? '',
      larguraMm: (map['larguraMm'] ?? 60).toDouble(),
      alturaMm: (map['alturaMm'] ?? 40).toDouble(),
      mostrarMarcaTagValida: map['mostrarMarcaTagValida'] ?? true,
      destacarValidade: map['destacarValidade'] ?? true,
      campos: camposMap,
    );
  }

  static Map<String, dynamic> toMap(DesignEtiquetaModel model) {
    return {
      'tipoEtiquetaId': model.tipoEtiquetaId,
      'tipoEtiquetaNome': model.tipoEtiquetaNome,
      'larguraMm': model.larguraMm,
      'alturaMm': model.alturaMm,
      'mostrarMarcaTagValida': model.mostrarMarcaTagValida,
      'destacarValidade': model.destacarValidade,
      'campos': model.campos
          .asMap()
          .entries
          .map(
            (e) => {
              'id': e.value.id,
              'nome': e.value.nome,
              'tipo': e.value.tipo.name,
              'labelImpresso': e.value.labelImpresso,
              'obrigatorio': e.value.obrigatorio,
              'visivel': e.value.visivel,
              'fontSize': e.value.fontSize,
              'isBold': e.value.isBold,
              'align': e.value.align.name,
              'ordem': e.key,
            },
          )
          .toList(),
    };
  }

  static String toJson(DesignEtiquetaModel model) {
    return jsonEncode(toMap(model));
  }

  static DesignEtiquetaModel fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  static TextAlign _textAlignFromString(dynamic value) {
    switch (value) {
      case 'center':
      case 'TextAlign.center':
        return TextAlign.center;
      case 'right':
      case 'TextAlign.right':
        return TextAlign.right;
      case 'left':
      case 'TextAlign.left':
      default:
        return TextAlign.left;
    }
  }
}