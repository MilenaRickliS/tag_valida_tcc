import 'package:cloud_firestore/cloud_firestore.dart';

enum CampoTipo {
  text,
  integer,
  decimal,
  currency,
  priceMode,
  multiline,
  date,
  boolType,
  image,
}

enum CampoPosicaoSimbolo {
  none,
  prefix,
  suffix,
}

CampoTipo campoTipoFromString(String s) {
  switch (s) {
    case 'integer':
      return CampoTipo.integer;
    case 'decimal':
      return CampoTipo.decimal;
    case 'currency':
      return CampoTipo.currency;
    case 'priceMode':
      return CampoTipo.priceMode;
    case 'multiline':
      return CampoTipo.multiline;
    case 'date':
      return CampoTipo.date;
    case 'bool':
      return CampoTipo.boolType;
    case 'image':
      return CampoTipo.image;
    default:
      return CampoTipo.text;
  }
}

String campoTipoToString(CampoTipo t) {
  switch (t) {
    case CampoTipo.integer:
      return 'integer';
    case CampoTipo.decimal:
      return 'decimal';
    case CampoTipo.currency:
      return 'currency';
    case CampoTipo.priceMode:
      return 'priceMode';
    case CampoTipo.multiline:
      return 'multiline';
    case CampoTipo.date:
      return 'date';
    case CampoTipo.boolType:
      return 'bool';
    case CampoTipo.image:
      return 'image';
    case CampoTipo.text:
      return 'text';
  }
}

CampoPosicaoSimbolo campoPosicaoFromString(String s) {
  switch (s) {
    case 'prefix':
      return CampoPosicaoSimbolo.prefix;
    case 'suffix':
      return CampoPosicaoSimbolo.suffix;
    default:
      return CampoPosicaoSimbolo.none;
  }
}

String campoPosicaoToString(CampoPosicaoSimbolo p) {
  switch (p) {
    case CampoPosicaoSimbolo.prefix:
      return 'prefix';
    case CampoPosicaoSimbolo.suffix:
      return 'suffix';
    case CampoPosicaoSimbolo.none:
      return 'none';
  }
}

class CampoCustomModel {
  final String key;
  final String label;
  final CampoTipo tipo;
  final bool obrigatorio;
  final String? prefixo; 
  final String? sufixo; 
  final String? unidadePadrao; 
  final List<String> opcoesUnidade; 
  final bool permitirUnidadeCustom;
  final CampoPosicaoSimbolo posicaoSimbolo;
  final int casasDecimais; 
  final bool habilitarModoPreco;
  final List<String> opcoesModoPreco; 
  final String? modoPrecoPadrao;

  const CampoCustomModel({
    required this.key,
    required this.label,
    required this.tipo,
    required this.obrigatorio,
    this.prefixo,
    this.sufixo,
    this.unidadePadrao,
    this.opcoesUnidade = const [],
    this.permitirUnidadeCustom = false,
    this.posicaoSimbolo = CampoPosicaoSimbolo.none,
    this.casasDecimais = 2,
    this.habilitarModoPreco = false,
    this.opcoesModoPreco = const [],
    this.modoPrecoPadrao,
  });

  CampoCustomModel copyWith({
    String? key,
    String? label,
    CampoTipo? tipo,
    bool? obrigatorio,
    String? prefixo,
    String? sufixo,
    String? unidadePadrao,
    List<String>? opcoesUnidade,
    bool? permitirUnidadeCustom,
    CampoPosicaoSimbolo? posicaoSimbolo,
    int? casasDecimais,
    bool? habilitarModoPreco,
    List<String>? opcoesModoPreco,
    String? modoPrecoPadrao,
  }) {
    return CampoCustomModel(
      key: key ?? this.key,
      label: label ?? this.label,
      tipo: tipo ?? this.tipo,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      prefixo: prefixo ?? this.prefixo,
      sufixo: sufixo ?? this.sufixo,
      unidadePadrao: unidadePadrao ?? this.unidadePadrao,
      opcoesUnidade: opcoesUnidade ?? this.opcoesUnidade,
      permitirUnidadeCustom:
          permitirUnidadeCustom ?? this.permitirUnidadeCustom,
      posicaoSimbolo: posicaoSimbolo ?? this.posicaoSimbolo,
      casasDecimais: casasDecimais ?? this.casasDecimais,
      habilitarModoPreco: habilitarModoPreco ?? this.habilitarModoPreco,
      opcoesModoPreco: opcoesModoPreco ?? this.opcoesModoPreco,
      modoPrecoPadrao: modoPrecoPadrao ?? this.modoPrecoPadrao,
    );
  }

  Map<String, dynamic> toMap() => {
        'key': key,
        'label': label,
        'tipo': campoTipoToString(tipo),
        'obrigatorio': obrigatorio,
        'prefixo': prefixo,
        'sufixo': sufixo,
        'unidadePadrao': unidadePadrao,
        'opcoesUnidade': opcoesUnidade,
        'permitirUnidadeCustom': permitirUnidadeCustom,
        'posicaoSimbolo': campoPosicaoToString(posicaoSimbolo),
        'casasDecimais': casasDecimais,
        'habilitarModoPreco': habilitarModoPreco,
        'opcoesModoPreco': opcoesModoPreco,
        'modoPrecoPadrao': modoPrecoPadrao,
      };

  factory CampoCustomModel.fromMap(Map<String, dynamic> m) {
    return CampoCustomModel(
      key: (m['key'] ?? '').toString(),
      label: (m['label'] ?? '').toString(),
      tipo: campoTipoFromString((m['tipo'] ?? 'text').toString()),
      obrigatorio: m['obrigatorio'] == true,
      prefixo: m['prefixo']?.toString(),
      sufixo: m['sufixo']?.toString(),
      unidadePadrao: m['unidadePadrao']?.toString(),
      opcoesUnidade: ((m['opcoesUnidade'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      permitirUnidadeCustom: m['permitirUnidadeCustom'] == true,
      posicaoSimbolo: campoPosicaoFromString(
        (m['posicaoSimbolo'] ?? 'none').toString(),
      ),
      casasDecimais: (m['casasDecimais'] as num?)?.toInt() ?? 2,
      habilitarModoPreco: m['habilitarModoPreco'] == true,
      opcoesModoPreco: ((m['opcoesModoPreco'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      modoPrecoPadrao: m['modoPrecoPadrao']?.toString(),
    );
  }
}

enum TipoQrEtiqueta {
  privado,
  publico,
}

TipoQrEtiqueta tipoQrEtiquetaFromString(String s) {
  switch (s) {
    case 'publico':
      return TipoQrEtiqueta.publico;
    default:
      return TipoQrEtiqueta.privado;
  }
}

String tipoQrEtiquetaToString(TipoQrEtiqueta t) {
  switch (t) {
    case TipoQrEtiqueta.publico:
      return 'publico';
    case TipoQrEtiqueta.privado:
      return 'privado';
  }
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
  final TipoQrEtiqueta tipoQr;

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
    this.tipoQr = TipoQrEtiqueta.privado,
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
    TipoQrEtiqueta? tipoQr,
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
      tipoQr: tipoQr ?? this.tipoQr,
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'descricao': descricao,
        'usarRegraValidadeCategoria': usarRegraValidadeCategoria,
        'controlaLote': controlaLote,
        'permiteTabelaNutricional': permiteTabelaNutricional,
        'larguraMm': larguraMm,
        'alturaMm': alturaMm,
        'tipoQr': tipoQrEtiquetaToString(tipoQr),
        'camposCustom': camposCustom.map((c) => c.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory TipoEtiquetaModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final list = (data['camposCustom'] as List? ?? [])
        .map((e) => CampoCustomModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return TipoEtiquetaModel(
      id: doc.id,
      nome: (data['nome'] ?? '').toString(),
      descricao: data['descricao']?.toString(),
      usarRegraValidadeCategoria:
          data['usarRegraValidadeCategoria'] == null
              ? true
              : data['usarRegraValidadeCategoria'] == true,
      camposCustom: list,
      controlaLote: data['controlaLote'] == true,
      permiteTabelaNutricional: data['permiteTabelaNutricional'] == true,
      larguraMm: (data['larguraMm'] as num?)?.toDouble() ?? 60,
      alturaMm: (data['alturaMm'] as num?)?.toDouble() ?? 40,
      tipoQr: tipoQrEtiquetaFromString(
        (data['tipoQr'] ?? 'privado').toString(),
      ),
    );
  }
}
