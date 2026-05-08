import 'dart:convert';
import 'package:flutter/material.dart';

import 'etiqueta_layout_preset.dart';

enum CampoDesignV2Tipo {
  blocoEmpresa,
  produto,
  info,
  extras,
  qrcode,
  imagem,
  tabelaNutricional,
}

class CampoDesignEtiquetaV2Model {
  final String id;
  final String nome;
  final CampoDesignV2Tipo tipo;
  final String? labelImpresso;
  final bool obrigatorio;
  final String? valorExemplo;

  final bool visivel;
  final bool isBold;
  final TextAlign align;
  final int ordem;

  const CampoDesignEtiquetaV2Model({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.obrigatorio,
    required this.visivel,
    required this.isBold,
    required this.align,
    required this.ordem,
    this.labelImpresso,
    this.valorExemplo,
  });

  factory CampoDesignEtiquetaV2Model.fromMap(Map<String, dynamic> map) {
    return CampoDesignEtiquetaV2Model(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      tipo: CampoDesignV2Tipo.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => CampoDesignV2Tipo.info,
      ),
      labelImpresso: map['labelImpresso'],
      obrigatorio: map['obrigatorio'] ?? false,
      visivel: map['obrigatorio'] == true ? true : map['visivel'] ?? true,
      isBold: map['isBold'] ?? false,
      align: _alignFromString(map['align']),
      ordem: map['ordem'] ?? 0,
      valorExemplo: map['valorExemplo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo.name,
      'labelImpresso': labelImpresso,
      'obrigatorio': obrigatorio,
      'visivel': obrigatorio ? true : visivel,
      'isBold': isBold,
      'align': align.name,
      'ordem': ordem,
      'valorExemplo': valorExemplo,
    };
  }

  CampoDesignEtiquetaV2Model copyWith({
    String? id,
    String? nome,
    CampoDesignV2Tipo? tipo,
    String? labelImpresso,
    bool? obrigatorio,
    bool? visivel,
    bool? isBold,
    TextAlign? align,
    int? ordem,
    String? valorExemplo,
  }) {
    return CampoDesignEtiquetaV2Model(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      labelImpresso: labelImpresso ?? this.labelImpresso,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      visivel: visivel ?? this.visivel,
      isBold: isBold ?? this.isBold,
      align: align ?? this.align,
      ordem: ordem ?? this.ordem,
      valorExemplo: valorExemplo ?? this.valorExemplo,
    );
  }

  static TextAlign _alignFromString(dynamic value) {
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

class DesignEtiquetaV2Model {
  final String tipoEtiquetaId;
  final String tipoEtiquetaNome;

  final EtiquetaLayoutPreset preset;

  final bool mostrarMarcaTagValida;
  final bool destacarValidade;

  final List<CampoDesignEtiquetaV2Model> campos;

  const DesignEtiquetaV2Model({
    required this.tipoEtiquetaId,
    required this.tipoEtiquetaNome,
    required this.preset,
    required this.mostrarMarcaTagValida,
    required this.destacarValidade,
    required this.campos,
  });

  double get larguraMm => preset.larguraMm;
  double get alturaMm => preset.alturaMm;

  factory DesignEtiquetaV2Model.fromMap(Map<String, dynamic> map) {
    final preset = EtiquetaLayoutPresetX.fromStorageKey(
      map['preset']?.toString(),
    );

    final camposMap = (map['campos'] as List? ?? [])
        .map(
          (e) => CampoDesignEtiquetaV2Model.fromMap(
            Map<String, dynamic>.from(e),
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

  Map<String, dynamic> toMap() {
    return {
      'version': 3,
      'preset': preset.storageKey,
      'tipoEtiquetaId': tipoEtiquetaId,
      'tipoEtiquetaNome': tipoEtiquetaNome,
      'larguraMm': preset.larguraMm,
      'alturaMm': preset.alturaMm,
      'mostrarMarcaTagValida': mostrarMarcaTagValida,
      'destacarValidade': destacarValidade,
      'campos': campos
          .asMap()
          .entries
          .map((e) => e.value.copyWith(ordem: e.key).toMap())
          .toList(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory DesignEtiquetaV2Model.fromJson(String source) {
    return DesignEtiquetaV2Model.fromMap(jsonDecode(source));
  }

  DesignEtiquetaV2Model copyWith({
    String? tipoEtiquetaId,
    String? tipoEtiquetaNome,
    EtiquetaLayoutPreset? preset,
    bool? mostrarMarcaTagValida,
    bool? destacarValidade,
    List<CampoDesignEtiquetaV2Model>? campos,
  }) {
    return DesignEtiquetaV2Model(
      tipoEtiquetaId: tipoEtiquetaId ?? this.tipoEtiquetaId,
      tipoEtiquetaNome: tipoEtiquetaNome ?? this.tipoEtiquetaNome,
      preset: preset ?? this.preset,
      mostrarMarcaTagValida:
          mostrarMarcaTagValida ?? this.mostrarMarcaTagValida,
      destacarValidade: destacarValidade ?? this.destacarValidade,
      campos: campos ?? this.campos,
    );
  }
}