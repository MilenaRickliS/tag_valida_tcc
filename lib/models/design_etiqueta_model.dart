import 'dart:convert';
import 'package:flutter/material.dart';

enum CampoDesignTipo {
  blocoEmpresa,
  produto,
  info,
  extras,
  qrcode,
  imagem,
}

class CampoDesignEtiquetaModel {
  final String id;
  final String nome;
  final CampoDesignTipo tipo;
  final String? labelImpresso;
  final bool obrigatorio;

  bool visivel;
  double fontSize;
  bool isBold;
  TextAlign align;
  int ordem;

  CampoDesignEtiquetaModel({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.obrigatorio,
    required this.visivel,
    required this.fontSize,
    required this.isBold,
    required this.align,
    required this.ordem,
    this.labelImpresso,
  });

  factory CampoDesignEtiquetaModel.fromMap(Map<String, dynamic> map) {
    return CampoDesignEtiquetaModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      tipo: CampoDesignTipo.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => CampoDesignTipo.info,
      ),
      labelImpresso: map['labelImpresso'],
      obrigatorio: map['obrigatorio'] ?? false,
      visivel: map['visivel'] ?? true,
      fontSize: (map['fontSize'] ?? 10).toDouble(),
      isBold: map['isBold'] ?? false,
      align: _alignFromString(map['align']),
      ordem: map['ordem'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo.name,
      'labelImpresso': labelImpresso,
      'obrigatorio': obrigatorio,
      'visivel': visivel,
      'fontSize': fontSize,
      'isBold': isBold,
      'align': align.name,
      'ordem': ordem,
    };
  }

  CampoDesignEtiquetaModel copyWith({
    String? id,
    String? nome,
    CampoDesignTipo? tipo,
    String? labelImpresso,
    bool? obrigatorio,
    bool? visivel,
    double? fontSize,
    bool? isBold,
    TextAlign? align,
    int? ordem,
  }) {
    return CampoDesignEtiquetaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      labelImpresso: labelImpresso ?? this.labelImpresso,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      visivel: visivel ?? this.visivel,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      align: align ?? this.align,
      ordem: ordem ?? this.ordem,
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

class DesignEtiquetaModel {
  final String tipoEtiquetaId;
  final String tipoEtiquetaNome;

  final double larguraMm;
  final double alturaMm;

  final bool mostrarMarcaTagValida;
  final bool destacarValidade;

  final List<CampoDesignEtiquetaModel> campos;

  DesignEtiquetaModel({
    required this.tipoEtiquetaId,
    required this.tipoEtiquetaNome,
    required this.larguraMm,
    required this.alturaMm,
    required this.mostrarMarcaTagValida,
    required this.destacarValidade,
    required this.campos,
  });

  factory DesignEtiquetaModel.defaultForTipo({
    required String tipoEtiquetaId,
    required String tipoEtiquetaNome,
    required bool controlaLote,
    required bool permiteTabelaNutricional,
    required List<String> camposCustomLabels,
  }) {
    final campos = <CampoDesignEtiquetaModel>[
      CampoDesignEtiquetaModel(
        id: 'empresa',
        nome: 'Dados da empresa',
        tipo: CampoDesignTipo.blocoEmpresa,
        obrigatorio: false,
        visivel: true,
        fontSize: 7,
        isBold: true,
        align: TextAlign.left,
        ordem: 0,
      ),
      CampoDesignEtiquetaModel(
        id: 'produto',
        nome: 'Nome do produto',
        tipo: CampoDesignTipo.produto,
        obrigatorio: true,
        visivel: true,
        fontSize: 15,
        isBold: true,
        align: TextAlign.left,
        ordem: 1,
      ),
      CampoDesignEtiquetaModel(
        id: 'validade',
        nome: 'Data de validade',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'VAL',
        obrigatorio: true,
        visivel: true,
        fontSize: 9,
        isBold: true,
        align: TextAlign.left,
        ordem: 2,
      ),
    ];

    if (controlaLote) {
      campos.add(
        CampoDesignEtiquetaModel(
          id: 'lote',
          nome: 'Lote',
          tipo: CampoDesignTipo.info,
          labelImpresso: 'LOTE',
          obrigatorio: false,
          visivel: true,
          fontSize: 8,
          isBold: true,
          align: TextAlign.left,
          ordem: campos.length,
        ),
      );
    }

    campos.add(
      CampoDesignEtiquetaModel(
        id: 'quantidade',
        nome: 'Quantidade',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'QTD',
        obrigatorio: false,
        visivel: true,
        fontSize: 8,
        isBold: true,
        align: TextAlign.left,
        ordem: campos.length,
      ),
    );

    for (final label in camposCustomLabels) {
      final safeId = label
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      campos.add(
        CampoDesignEtiquetaModel(
          id: 'custom_$safeId',
          nome: label,
          tipo: CampoDesignTipo.extras,
          obrigatorio: false,
          visivel: true,
          fontSize: 7,
          isBold: false,
          align: TextAlign.left,
          ordem: campos.length,
        ),
      );
    }

    if (permiteTabelaNutricional) {
      campos.add(
        CampoDesignEtiquetaModel(
          id: 'tabela_nutricional',
          nome: 'Tabela nutricional',
          tipo: CampoDesignTipo.extras,
          obrigatorio: false,
          visivel: false,
          fontSize: 7,
          isBold: false,
          align: TextAlign.left,
          ordem: campos.length,
        ),
      );
    }

    campos.add(
      CampoDesignEtiquetaModel(
        id: 'qrcode',
        nome: 'QR Code',
        tipo: CampoDesignTipo.qrcode,
        obrigatorio: false,
        visivel: true,
        fontSize: 8,
        isBold: false,
        align: TextAlign.right,
        ordem: campos.length,
      ),
    );

    return DesignEtiquetaModel(
      tipoEtiquetaId: tipoEtiquetaId,
      tipoEtiquetaNome: tipoEtiquetaNome,
      larguraMm: 60,
      alturaMm: 40,
      mostrarMarcaTagValida: true,
      destacarValidade: true,
      campos: campos,
    );
  }

  factory DesignEtiquetaModel.fromMap(Map<String, dynamic> map) {
    final camposMap = (map['campos'] as List? ?? [])
        .map((e) => CampoDesignEtiquetaModel.fromMap(Map<String, dynamic>.from(e)))
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

  Map<String, dynamic> toMap() {
    return {
      'tipoEtiquetaId': tipoEtiquetaId,
      'tipoEtiquetaNome': tipoEtiquetaNome,
      'larguraMm': larguraMm,
      'alturaMm': alturaMm,
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

  factory DesignEtiquetaModel.fromJson(String source) {
    return DesignEtiquetaModel.fromMap(jsonDecode(source));
  }

  DesignEtiquetaModel copyWith({
    String? tipoEtiquetaId,
    String? tipoEtiquetaNome,
    double? larguraMm,
    double? alturaMm,
    bool? mostrarMarcaTagValida,
    bool? destacarValidade,
    List<CampoDesignEtiquetaModel>? campos,
  }) {
    return DesignEtiquetaModel(
      tipoEtiquetaId: tipoEtiquetaId ?? this.tipoEtiquetaId,
      tipoEtiquetaNome: tipoEtiquetaNome ?? this.tipoEtiquetaNome,
      larguraMm: larguraMm ?? this.larguraMm,
      alturaMm: alturaMm ?? this.alturaMm,
      mostrarMarcaTagValida: mostrarMarcaTagValida ?? this.mostrarMarcaTagValida,
      destacarValidade: destacarValidade ?? this.destacarValidade,
      campos: campos ?? this.campos,
    );
  }
}