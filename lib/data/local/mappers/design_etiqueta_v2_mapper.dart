import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_layout_preset.dart';

class DesignEtiquetaV2Mapper {
  static DesignEtiquetaV2Model fromMap(Map<String, dynamic> map) {
    final preset = EtiquetaLayoutPresetX.fromStorageKey(
      map['preset']?.toString(),
    );

    final camposMap = (map['campos'] as List? ?? [])
        .map(
          (e) => CampoDesignEtiquetaV2Model(
            id: e['id'] ?? '',
            nome: e['nome'] ?? '',
            tipo: CampoDesignV2Tipo.values.firstWhere(
              (t) => t.name == e['tipo'],
              orElse: () => CampoDesignV2Tipo.info,
            ),
            labelImpresso: e['labelImpresso'],
            obrigatorio: e['obrigatorio'] ?? false,
            visivel: e['obrigatorio'] == true ? true : e['visivel'] ?? true,
            isBold: e['isBold'] ?? false,
            align: _textAlignFromString(e['align']),
            ordem: e['ordem'] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return DesignEtiquetaV2Model(
      tipoEtiquetaId: map['tipoEtiquetaId'] ?? '',
      tipoEtiquetaNome: map['tipoEtiquetaNome'] ?? '',
      preset: preset,
      mostrarMarcaTagValida: map['mostrarMarcaTagValida'] ?? true,
      destacarValidade: map['destacarValidade'] ?? true,
      campos: camposMap,
    );
  }

  static Map<String, dynamic> toMap(
    DesignEtiquetaV2Model model, {
    required EtiquetaLayoutPreset preset,
  }) {
    return {
      'version': 3,
      'preset': preset.storageKey,
      'tipoEtiquetaId': model.tipoEtiquetaId,
      'tipoEtiquetaNome': model.tipoEtiquetaNome,
      'larguraMm': preset.larguraMm,
      'alturaMm': preset.alturaMm,
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
              'visivel': e.value.obrigatorio ? true : e.value.visivel,
              'isBold': e.value.isBold,
              'align': e.value.align.name,
              'ordem': e.key,
            },
          )
          .toList(),
    };
  }

  static String toJson(
    DesignEtiquetaV2Model model, {
    required EtiquetaLayoutPreset preset,
  }) {
    return jsonEncode(toMap(model, preset: preset));
  }

  static DesignEtiquetaV2Model fromJson(String source) {
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