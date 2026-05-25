import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/categoria_model.dart';
import '../models/setor_model.dart';
import '../models/tipo_etiqueta_model.dart';
import '../models/etiqueta_model.dart';
import '../models/estoque_mov_model.dart';
import '../models/etiqueta_template_model.dart';
import '../models/tabela_nutricional_model.dart';

import '../data/local/repos/etiquetas_local_repo.dart';
import '../data/local/repos/etiqueta_template_local_repo.dart';
import '../providers/estoque_mov_provider.dart';

class GerarEtiquetaProvider extends ChangeNotifier {
  final EtiquetasLocalRepo? repo;
  final EstoqueMovProvider? mov;
  final EtiquetasTemplatesLocalRepo? templateRepo;
  final FirebaseFirestore firestore;

  GerarEtiquetaProvider({
    required this.firestore,
    this.repo,
    this.mov,
    this.templateRepo,
  }) {
    debugPrint("GerarEtiquetaProvider criado | mov: $mov");
  }
    

  String? tipoId;
  CategoriaModel? categoria;
  SetorModel? setor;
  String? setorIdSelecionado;
  String? categoriaIdSelecionada;

  final produtoCtrl = TextEditingController();

  DateTime? fabricacao;
  DateTime? validade;

  final quantidadeCtrl = TextEditingController(text: "1");
  String unidadeMedida = 'un';

  final Map<String, Map<String, dynamic>> camposValores = {};
  bool saving = false;

  String? editingEtiquetaId;
  DateTime? editingCreatedAt;

  num? editingQuantidade;
  num? editingQuantidadeRestante;
  String? editingStatusEstoque;
  DateTime? editingSoldAt;

  bool incluirTabelaNutricional = false;

  final porcoesPorEmbalagemCtrl = TextEditingController();
  final porcaoCtrl = TextEditingController();
  final quantidadeMedidaCtrl = TextEditingController();
  final medidaCaseiraCtrl = TextEditingController();
  final valorEnergeticoCtrl = TextEditingController();
  final carboidratosCtrl = TextEditingController();
  final acucaresTotaisCtrl = TextEditingController();
  final acucaresAdicionadosCtrl = TextEditingController();
  final proteinasCtrl = TextEditingController();
  final gordurasTotaisCtrl = TextEditingController();
  final gordurasSaturadasCtrl = TextEditingController();
  final gordurasTransCtrl = TextEditingController();
  final fibraAlimentarCtrl = TextEditingController();
  final sodioCtrl = TextEditingController();

  final Map<String, TextEditingController> customCtrls = {};

  CollectionReference<Map<String, dynamic>> _etiquetasCol(String uid) {
    return firestore.collection('usuarios').doc(uid).collection('etiquetas');
  }

  CollectionReference<Map<String, dynamic>> _templatesCol(String uid) {
    return firestore
        .collection('usuarios')
        .doc(uid)
        .collection('etiquetas_templates');
  }

  Map<String, Map<String, dynamic>> _sanitizeCamposValores(
    Map<String, Map<String, dynamic>> input,
  ) {
    dynamic fix(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.millisecondsSinceEpoch;
      if (v is Map) return v.map((k, val) => MapEntry(k.toString(), fix(val)));
      if (v is List) return v.map(fix).toList();
      return v;
    }

    return input.map((k, v) {
      final map = Map<String, dynamic>.from(v);

      return MapEntry(k, {
        "label": (map["label"] ?? "").toString(),
        "tipo": (map["tipo"] ?? "text").toString(),
        "value": fix(map["value"]),
        "prefixo": map["prefixo"]?.toString(),
        "sufixo": map["sufixo"]?.toString(),
        "casasDecimais": (map["casasDecimais"] as num?)?.toInt() ?? 2,
      });
    });
  }

  void setQuantidadeText(String v) {
    quantidadeCtrl.text = v;
    notifyListeners();
  }

  void setUnidadeMedida(String value) {
    unidadeMedida = value == 'kg' ? 'kg' : 'un';

    if (unidadeMedida == 'un') {
      final n = num.tryParse(
        quantidadeCtrl.text.replaceAll(',', '.'),
      );

      if (n != null) {
        quantidadeCtrl.text = n.toInt().toString();
      }
    }

    notifyListeners();
  }

  void setCancelado(bool cancelado) {
    editingStatusEstoque = cancelado ? "cancelado" : "ativo";
    notifyListeners();
  }

  bool get isCancelado => editingStatusEstoque == "cancelado";

  TextEditingController ctrlFor(String key, {String initial = ""}) {
    return customCtrls.putIfAbsent(key, () => TextEditingController(text: initial));
  }

  void _setCtrlText(String key, String text) {
    final c = customCtrls[key];
    if (c == null) {
      customCtrls[key] = TextEditingController(text: text);
    } else {
      if (c.text != text) c.text = text;
    }
  }

  void setIncluirTabelaNutricional(bool v) {
    incluirTabelaNutricional = v;
    notifyListeners();
  }

  void setQuantidadeMedida(String value) {
    quantidadeMedidaCtrl.text = value;
    notifyListeners();
  }

  double _toDouble(TextEditingController c) {
    return double.tryParse(c.text.trim().replaceAll(",", ".")) ?? 0;
  }

  TabelaNutricionalModel? _buildTabelaNutricional() {
    if (!incluirTabelaNutricional) return null;

    int toInt(TextEditingController c) {
      return int.tryParse(c.text.trim()) ?? 1;
    }

    return TabelaNutricionalModel(
      porcoesPorEmbalagem: toInt(porcoesPorEmbalagemCtrl),
      porcao: porcaoCtrl.text.trim(),
      quantidadeMedida: quantidadeMedidaCtrl.text.trim(),
      medidaCaseira: medidaCaseiraCtrl.text.trim(),
      valorEnergetico: _toDouble(valorEnergeticoCtrl),
      carboidratos: _toDouble(carboidratosCtrl),
      acucaresTotais: _toDouble(acucaresTotaisCtrl),
      acucaresAdicionados: _toDouble(acucaresAdicionadosCtrl),
      proteinas: _toDouble(proteinasCtrl),
      gordurasTotais: _toDouble(gordurasTotaisCtrl),
      gordurasSaturadas: _toDouble(gordurasSaturadasCtrl),
      gordurasTrans: _toDouble(gordurasTransCtrl),
      fibraAlimentar: _toDouble(fibraAlimentarCtrl),
      sodio: _toDouble(sodioCtrl),
    );
  }

  void clearEditing() {
    editingEtiquetaId = null;
    editingCreatedAt = null;
    editingQuantidade = null;
    editingQuantidadeRestante = null;
    editingStatusEstoque = null;
    editingSoldAt = null;
  }

  void resetAll() {
    clearEditing();
    tipoId = null;
    categoria = null;
    setor = null;
    categoriaIdSelecionada = null;
    setorIdSelecionado = null;
    fabricacao = null;
    validade = null;
    produtoCtrl.clear();

    quantidadeCtrl.text = "1";
    unidadeMedida = 'un';
    editingStatusEstoque = "ativo";

    incluirTabelaNutricional = false;
    porcoesPorEmbalagemCtrl.clear();
    porcaoCtrl.clear();
    quantidadeMedidaCtrl.clear();
    medidaCaseiraCtrl.clear();
    valorEnergeticoCtrl.clear();
    carboidratosCtrl.clear();
    acucaresTotaisCtrl.clear();
    acucaresAdicionadosCtrl.clear();
    proteinasCtrl.clear();
    gordurasTotaisCtrl.clear();
    gordurasSaturadasCtrl.clear();
    gordurasTransCtrl.clear();
    fibraAlimentarCtrl.clear();
    sodioCtrl.clear();

    camposValores.clear();
    for (final c in customCtrls.values) {
      c.dispose();
    }
    customCtrls.clear();

    notifyListeners();
  }

  num _parseQtdOrThrow() {
    final raw = quantidadeCtrl.text
        .trim()
        .replaceAll(",", ".");

    final v = num.tryParse(raw);

    if (v == null || v <= 0) {
      throw Exception("Quantidade inválida.");
    }

    if (unidadeMedida == 'un' && v % 1 != 0) {
      throw Exception(
        "Quantidade em unidade deve ser inteira.",
      );
    }

    return v;
  }

  void loadFromEtiqueta({
    required EtiquetaModel e,
    required CategoriaModel? categoriaObj,
    required SetorModel? setorObj,
    required TipoEtiquetaModel? tipoAtual,
  }) {
    editingEtiquetaId = e.id;
    editingCreatedAt = e.createdAt;

    tipoId = e.tipoId;
    produtoCtrl.text = e.produtoNome;

    categoria = categoriaObj;
    setor = setorObj;

    categoriaIdSelecionada = e.categoriaId;
    setorIdSelecionado = e.setorId;

    fabricacao = e.dataFabricacao;
    validade = e.dataValidade;

    editingQuantidade = e.quantidade;
    editingQuantidadeRestante = e.quantidadeRestante;
    editingStatusEstoque = e.statusEstoque;
    editingSoldAt = e.soldAt;

    quantidadeCtrl.text = _normalizarQuantidade(
      e.quantidade,
      unidade: e.unidadeMedida,
    );

    unidadeMedida = e.unidadeMedida;

    incluirTabelaNutricional = e.incluirTabelaNutricional;

    if (e.tabelaNutricional != null) {
      porcoesPorEmbalagemCtrl.text =
          e.tabelaNutricional!.porcoesPorEmbalagem.toString();
      porcaoCtrl.text = e.tabelaNutricional!.porcao;
      quantidadeMedidaCtrl.text = e.tabelaNutricional!.quantidadeMedida;
      medidaCaseiraCtrl.text = e.tabelaNutricional!.medidaCaseira;
      valorEnergeticoCtrl.text = e.tabelaNutricional!.valorEnergetico.toString();
      carboidratosCtrl.text = e.tabelaNutricional!.carboidratos.toString();
      acucaresTotaisCtrl.text = e.tabelaNutricional!.acucaresTotais.toString();
      acucaresAdicionadosCtrl.text =
          e.tabelaNutricional!.acucaresAdicionados.toString();
      proteinasCtrl.text = e.tabelaNutricional!.proteinas.toString();
      gordurasTotaisCtrl.text = e.tabelaNutricional!.gordurasTotais.toString();
      gordurasSaturadasCtrl.text =
          e.tabelaNutricional!.gordurasSaturadas.toString();
      gordurasTransCtrl.text = e.tabelaNutricional!.gordurasTrans.toString();
      fibraAlimentarCtrl.text = e.tabelaNutricional!.fibraAlimentar.toString();
      sodioCtrl.text = e.tabelaNutricional!.sodio.toString();
    }

    camposValores
      ..clear()
      ..addAll(
        e.camposCustomValores.map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
        ),
      );

    if (tipoAtual != null) {
      for (final c in tipoAtual.camposCustom) {
        final v = camposValores[c.key]?["value"];
        if (c.tipo == CampoTipo.text || c.tipo == CampoTipo.multiline) {
          _setCtrlText(c.key, (v ?? "").toString());
        } else if (c.tipo == CampoTipo.integer ||
            c.tipo == CampoTipo.decimal ||
            c.tipo == CampoTipo.currency ||
            c.tipo == CampoTipo.priceMode) {
          _setCtrlText(c.key, v == null ? "" : _extractValor(v));
        }
      }
    }

    _recalcularValidadeSePossivel(tipoAtual);
    notifyListeners();
  }

  String _extractValor(dynamic v) {
    if (v == null) return "";

    if (v is Map) {
      final valor = v['valor'];
      if (valor == null) return "";
      return valor.toString();
    }

    return v.toString();
  }

  void setTipoId(String? id, {TipoEtiquetaModel? tipoAtual}) {
    tipoId = id;

    clearEditing();
    editingStatusEstoque = "ativo";

    camposValores.clear();
    for (final c in customCtrls.values) {
      c.dispose();
    }
    customCtrls.clear();

    if (tipoAtual?.permiteTabelaNutricional != true) {
      incluirTabelaNutricional = false;
      porcoesPorEmbalagemCtrl.clear();
      porcaoCtrl.clear();
      quantidadeMedidaCtrl.clear();
      medidaCaseiraCtrl.clear();
      valorEnergeticoCtrl.clear();
      carboidratosCtrl.clear();
      acucaresTotaisCtrl.clear();
      acucaresAdicionadosCtrl.clear();
      proteinasCtrl.clear();
      gordurasTotaisCtrl.clear();
      gordurasSaturadasCtrl.clear();
      gordurasTransCtrl.clear();
      fibraAlimentarCtrl.clear();
      sodioCtrl.clear();
    }

    _recalcularValidadeSePossivel(tipoAtual);
    notifyListeners();
  }

  void setCategoria(CategoriaModel? c, {TipoEtiquetaModel? tipoAtual}) {
    categoria = c;
    categoriaIdSelecionada = c?.id;
    _recalcularValidadeSePossivel(tipoAtual);
    notifyListeners();
  }

  void setSetor(SetorModel? s) {
    setor = s;
    setorIdSelecionado = s?.id;
    notifyListeners();
  }

  void setFabricacao(DateTime d, {TipoEtiquetaModel? tipoAtual}) {
    fabricacao = d;
    _recalcularValidadeSePossivel(tipoAtual);
    notifyListeners();
  }

  void setValidadeManual(DateTime d) {
    validade = d;
    notifyListeners();
  }

  void setCampoValor({
    required String key,
    required String label,
    required dynamic value,
    required CampoTipo tipo,
    String? prefixo,
    String? sufixo,
    int? casasDecimais,
  }) {
    camposValores[key] = {
      "label": label,
      "tipo": campoTipoToString(tipo),
      "value": value,
      "prefixo": prefixo,
      "sufixo": sufixo,
      "casasDecimais": casasDecimais,
    };
    notifyListeners();
  }

  void _recalcularValidadeSePossivel(TipoEtiquetaModel? tipoAtual) {
    if (tipoAtual == null || categoria == null || fabricacao == null) return;
    if (tipoAtual.usarRegraValidadeCategoria) {
      validade = fabricacao!.add(Duration(days: categoria!.diasVencimento));
    }
  }

  String _gerarLotePadrao() {
    final nowBr = DateTime.now().toUtc().subtract(const Duration(hours: 3));

    String two(int n) => n.toString().padLeft(2, "0");

    final yy = two(nowBr.year % 100);
    final mm = two(nowBr.month);
    final dd = two(nowBr.day);

    final random = Random().nextInt(1000).toString().padLeft(3, "0");

    return "PV-$yy$mm$dd-$random";
  }

  void ensureLoteAuto({required TipoEtiquetaModel tipoAtual}) {
    if (!tipoAtual.controlaLote) return;

    final existing = camposValores["lote"]?["value"]?.toString().trim();
    if (existing != null && existing.isNotEmpty) return;

    final lote = _gerarLotePadrao();

    setCampoValor(
      key: "lote",
      label: "Lote",
      value: lote,
      tipo: CampoTipo.text,
    );
  }

  void setStatusEstoqueEdicao(String? v) {
    editingStatusEstoque = v ?? "ativo";
    notifyListeners();
  }

  String? validar(TipoEtiquetaModel? tipoAtual) {
    if (tipoAtual == null) return "Selecione o tipo de etiqueta.";
    if (produtoCtrl.text.trim().isEmpty) return "Informe o nome do produto.";
    if (categoria == null) return "Selecione a categoria.";
    if (setor == null) return "Selecione o setor/responsável.";
    if (fabricacao == null) return "Selecione a data de fabricação.";
    if (validade == null) return "Selecione a data de validade.";

    if (tipoAtual.permiteTabelaNutricional && incluirTabelaNutricional) {
      if (porcoesPorEmbalagemCtrl.text.trim().isEmpty) {
        return "Informe as porções por embalagem.";
      }
      if (porcaoCtrl.text.trim().isEmpty) {
        return "Informe a porção da tabela nutricional.";
      }
      if (quantidadeMedidaCtrl.text.trim().isEmpty) {
        return "Informe a quantidade da medida caseira da tabela nutricional.";
      }
      if (medidaCaseiraCtrl.text.trim().isEmpty) {
        return "Informe a medida caseira da tabela nutricional.";
      }
      if (valorEnergeticoCtrl.text.trim().isEmpty) {
        return "Informe o valor energético.";
      }
      if (carboidratosCtrl.text.trim().isEmpty) {
        return "Informe os carboidratos.";
      }
      if (acucaresTotaisCtrl.text.trim().isEmpty) {
        return "Informe os açúcares totais.";
      }
      if (acucaresAdicionadosCtrl.text.trim().isEmpty) {
        return "Informe os açúcares adicionados.";
      }
      if (proteinasCtrl.text.trim().isEmpty) {
        return "Informe as proteínas.";
      }
      if (gordurasTotaisCtrl.text.trim().isEmpty) {
        return "Informe as gorduras totais.";
      }
      if (gordurasSaturadasCtrl.text.trim().isEmpty) {
        return "Informe as gorduras saturadas.";
      }
      if (gordurasTransCtrl.text.trim().isEmpty) {
        return "Informe as gorduras trans.";
      }
      if (fibraAlimentarCtrl.text.trim().isEmpty) {
        return "Informe a fibra alimentar.";
      }
      if (sodioCtrl.text.trim().isEmpty) {
        return "Informe o sódio.";
      }
    }

    final raw = quantidadeCtrl.text.trim();
    final qtd = num.tryParse(raw.replaceAll(",", "."));
    if (qtd == null || qtd <= 0) return "Informe uma quantidade válida.";
    if (unidadeMedida == 'un' && qtd % 1 != 0) {
      return "Quantidade em unidade deve ser inteira.";
    }
    for (final c in tipoAtual.camposCustom) {
      if (c.obrigatorio) {
        final v = camposValores[c.key]?["value"];
        final vazio = v == null || (v is String && v.trim().isEmpty);
        if (vazio) return "Preencha o campo obrigatório: ${c.label}.";
      }
    }
    return null;
  }

 String _normalizarQuantidade(
    dynamic value, {
    String unidade = 'un',
  }) {
    if (value == null) return '';

    final s = value.toString().trim().replaceAll(',', '.');

    final n = num.tryParse(s);

    if (n == null) return s;

    if (unidade == 'kg') {
      return n
          .toStringAsFixed(3)
          .replaceAll('.', ',');
    }

    return n.toInt().toString();
  }

  Future<EtiquetaModel?> getEtiquetaById({
    required String uid,
    required String id,
  }) async {
    if (kIsWeb) {
      final doc = await _etiquetasCol(uid).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      DateTime dt(dynamic v) =>
          v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      DateTime? dtN(dynamic v) => v is Timestamp ? v.toDate() : null;

      final tabelaMap = data["tabelaNutricional"];
      final tabela = tabelaMap is Map<String, dynamic>
          ? TabelaNutricionalModel.fromMap(tabelaMap)
          : tabelaMap is Map
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
        status: (data["status"] ?? "ativa").toString(),
        lote: data["lote"]?.toString(),
        incluirTabelaNutricional: data["incluirTabelaNutricional"] == true,
        tabelaNutricional: tabela,
        quantidade: (data["quantidade"] as num?) ?? 1,
        quantidadeRestante: (data["quantidadeRestante"] as num?) ?? 1,
        unidadeMedida: (data["unidadeMedida"] ?? "un").toString(),
        statusEstoque: (data["statusEstoque"] ?? "ativo").toString(),
        soldAt: dtN(data["soldAt"]),
        createdAt: dtN(data["createdAt"]),
      );
    } else {
      return repo!.getById(uid: uid, id: id);
    }
  }

  Future<EtiquetaTemplateModel?> getTemplateById({
    required String uid,
    required String id,
  }) async {
    if (kIsWeb) {
      final doc = await _templatesCol(uid).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      final tabelaMap = data["tabelaNutricional"];
      final tabela = tabelaMap is Map<String, dynamic>
          ? TabelaNutricionalModel.fromMap(tabelaMap)
          : tabelaMap is Map
              ? TabelaNutricionalModel.fromMap(
                  Map<String, dynamic>.from(tabelaMap),
                )
              : null;

      DateTime? dt(dynamic v) => v is Timestamp ? v.toDate() : null;

      return EtiquetaTemplateModel(
        id: doc.id,
        tipoId: (data["tipoId"] ?? "").toString(),
        tipoNome: (data["tipoNome"] ?? "").toString(),
        produtoNome: (data["produtoNome"] ?? "").toString(),
        categoriaId: (data["categoriaId"] ?? "").toString(),
        categoriaNome: (data["categoriaNome"] ?? "").toString(),
        setorId: (data["setorId"] ?? "").toString(),
        setorNome: (data["setorNome"] ?? "").toString(),
        camposCustomValores: Map<String, dynamic>.from(
          data["camposCustomValores"] ?? {},
        ),
        quantidadePadrao: (data["quantidadePadrao"] as num?) ?? 1,
        unidadeMedidaPadrao: (data["unidadeMedidaPadrao"] ?? "un").toString(),
        incluirTabelaNutricional: data["incluirTabelaNutricional"] == true,
        tabelaNutricional: tabela,
        createdAt: dt(data["createdAt"]) ?? DateTime.now(),
        updatedAt: dt(data["updatedAt"]) ?? DateTime.now(),
      );
    } else {
      return templateRepo!.getById(uid: uid, id: id);
    }
  }

  Future<String> salvarEtiqueta({
    required String uid,
    required TipoEtiquetaModel tipoAtual,
  }) async {
    final err = validar(tipoAtual);
    if (err != null) throw Exception(err);

    ensureLoteAuto(tipoAtual: tipoAtual);

    saving = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final id = now.millisecondsSinceEpoch.toString();
      final qtd = _parseQtdOrThrow();
      final safeCampos = _sanitizeCamposValores(camposValores);
      final lote = (safeCampos["lote"]?["value"] ?? "").toString().trim();
      final loteFinal = lote.isEmpty ? null : lote;
      final tabela = _buildTabelaNutricional();

      final etiqueta = EtiquetaModel(
        id: id,
        tipoId: tipoAtual.id,
        tipoNome: tipoAtual.nome,
        produtoNome: produtoCtrl.text.trim(),
        categoriaId: categoria!.id,
        categoriaNome: categoria!.nome,
        setorId: setor!.id,
        setorNome: setor!.nome,
        dataFabricacao: fabricacao!,
        dataValidade: validade!,
        camposCustomValores: safeCampos,
        lote: loteFinal,
        incluirTabelaNutricional: incluirTabelaNutricional,
        tabelaNutricional: tabela,
        status: "ativa",
        createdAt: now,
        quantidade: qtd,
        quantidadeRestante: qtd,
        unidadeMedida: unidadeMedida,
        statusEstoque: "ativo",
        soldAt: null,
      );
      
      if (kIsWeb) {
        await _etiquetasCol(uid).doc(id).set(etiqueta.toMap());

        final templateId = DateTime.now().millisecondsSinceEpoch.toString();
        final template = EtiquetaTemplateModel(
          id: templateId,
          tipoId: etiqueta.tipoId,
          tipoNome: etiqueta.tipoNome,
          produtoNome: etiqueta.produtoNome,
          categoriaId: etiqueta.categoriaId,
          categoriaNome: etiqueta.categoriaNome,
          setorId: etiqueta.setorId,
          setorNome: etiqueta.setorNome,
          camposCustomValores: safeCampos,
          quantidadePadrao: etiqueta.quantidade,
          unidadeMedidaPadrao: unidadeMedida,
          incluirTabelaNutricional: etiqueta.incluirTabelaNutricional,
          tabelaNutricional: etiqueta.tabelaNutricional,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _templatesCol(uid).doc(template.id).set(template.toMap());

        if (mov == null) {
          throw Exception("EstoqueMovProvider não foi inicializado.");
        }

       if (mov != null) {
          await mov!.registrarEntrada(
            uid: uid,
            etiquetaId: id,
            quantidade: qtd,
            unidadeMedida: unidadeMedida,
            produtoNome: etiqueta.produtoNome,
            motivo: "Criação da etiqueta",
          );
        } else {
          debugPrint("⚠️ mov está NULL no salvarEtiqueta");
        }
      }else {
        await repo!.upsert(uid, etiqueta);

        final existing = await templateRepo!.findByKey(
          uid: uid,
          produtoNome: etiqueta.produtoNome,
          categoriaId: etiqueta.categoriaId,
          setorId: etiqueta.setorId,
        );

        final templateId =
            existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

        final template = EtiquetaTemplateModel(
          id: templateId,
          tipoId: etiqueta.tipoId,
          tipoNome: etiqueta.tipoNome,
          produtoNome: etiqueta.produtoNome,
          categoriaId: etiqueta.categoriaId,
          categoriaNome: etiqueta.categoriaNome,
          setorId: etiqueta.setorId,
          setorNome: etiqueta.setorNome,
          camposCustomValores: safeCampos,
          quantidadePadrao: etiqueta.quantidade,
          unidadeMedidaPadrao: unidadeMedida,
          incluirTabelaNutricional: etiqueta.incluirTabelaNutricional,
          tabelaNutricional: etiqueta.tabelaNutricional,
          createdAt: existing?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await templateRepo!.upsert(uid, template);

        await mov!.registrarEntrada(
          uid: uid,
          etiquetaId: id,
          quantidade: qtd,
          unidadeMedida: unidadeMedida,
          produtoNome: etiqueta.produtoNome,
          motivo: "Criação da etiqueta",
        );
      }

      return id;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

 Future<void> salvarEdicao({
    required String uid,
    required TipoEtiquetaModel tipoAtual,
  }) async {
    final err = validar(tipoAtual);
    if (err != null) throw Exception(err);
    if (editingEtiquetaId == null) {
      throw Exception("Etiqueta de edição não identificada.");
    }

    ensureLoteAuto(tipoAtual: tipoAtual);

    saving = true;
    notifyListeners();

    try {
      final atualAntes = await getEtiquetaById(uid: uid, id: editingEtiquetaId!);
      if (atualAntes == null) {
        throw Exception("Etiqueta não encontrada para edição.");
      }

      final qtdInformada = _parseQtdOrThrow();
      final safeCampos = _sanitizeCamposValores(camposValores);
      final lote = (safeCampos["lote"]?["value"] ?? "").toString().trim();
      final loteFinal = lote.isEmpty ? null : lote;

      final quantidadeAntiga = atualAntes.quantidade;
      final restanteAntigo = atualAntes.quantidadeRestante;
      final statusAntigo = atualAntes.statusEstoque.trim().toLowerCase();

      final statusSelecionado =
          (editingStatusEstoque ?? statusAntigo).trim().toLowerCase();

      num novoRestante;

      if (statusSelecionado == "cancelado") {
        novoRestante = 0;
      } else if (statusSelecionado == "vendido") {
        novoRestante = 0;
      } else {
        final consumidoAntes = quantidadeAntiga - restanteAntigo;
        novoRestante = qtdInformada - consumidoAntes;
        if (novoRestante < 0) {
          throw Exception(
            "A quantidade informada não pode ser menor que o já consumido/vendido.",
          );
        }
      }

      final statusEstoqueFinal = EtiquetaModel.calcStatusEstoque(
        restante: novoRestante,
        current: statusSelecionado,
      );

      final soldAtFinal = statusEstoqueFinal == "vendido"
          ? (atualAntes.soldAt ?? DateTime.now())
          : null;

      final tabela = _buildTabelaNutricional();

      final atualizado = EtiquetaModel(
        id: editingEtiquetaId!,
        tipoId: tipoAtual.id,
        tipoNome: tipoAtual.nome,
        produtoNome: produtoCtrl.text.trim(),
        categoriaId: categoria!.id,
        categoriaNome: categoria!.nome,
        setorId: setor!.id,
        setorNome: setor!.nome,
        dataFabricacao: fabricacao!,
        dataValidade: validade!,
        camposCustomValores: safeCampos,
        status: "ativa",
        lote: loteFinal,
        createdAt: atualAntes.createdAt ?? editingCreatedAt ?? DateTime.now(),
        incluirTabelaNutricional: incluirTabelaNutricional,
        tabelaNutricional: tabela,
        quantidade: qtdInformada,
        quantidadeRestante: novoRestante,
        unidadeMedida: unidadeMedida,
        statusEstoque: statusEstoqueFinal,
        soldAt: soldAtFinal,
      );

      if (kIsWeb) {
        await _etiquetasCol(uid)
            .doc(atualizado.id)
            .set(atualizado.toMap(), SetOptions(merge: true));
      } else {
        await repo!.update(uid, atualizado);
      }

      final deltaQuantidade = qtdInformada - quantidadeAntiga;

      if (statusAntigo != "cancelado" &&
          statusEstoqueFinal == "cancelado" &&
          restanteAntigo > 0) {
        await mov!.registrarCancelamento(
          uid: uid,
          etiquetaId: atualizado.id,
          quantidade: restanteAntigo,
          unidadeMedida: unidadeMedida,
          produtoNome: atualizado.produtoNome,
          motivo: "Cancelamento ao editar etiqueta",
        );
      } else if (statusAntigo != "vendido" &&
          statusEstoqueFinal == "vendido" &&
          restanteAntigo > 0) {
        await mov!.registrarVenda(
          uid: uid,
          etiquetaId: atualizado.id,
          quantidade: restanteAntigo,
          unidadeMedida: unidadeMedida,
          produtoNome: atualizado.produtoNome,
          motivo: "Venda ao editar etiqueta",
        );
      } else if (statusEstoqueFinal == "ativo" && deltaQuantidade != 0) {
        if (deltaQuantidade > 0) {
          await mov!.registrar(
            uid: uid,
            etiquetaId: atualizado.id,
            tipo: EstoqueMovModel.tipoAjusteEntrada,
            quantidade: deltaQuantidade,
            unidadeMedida: unidadeMedida,
            produtoNome: atualizado.produtoNome,
            motivo: "Ajuste ao editar etiqueta",
          );
        } else {
          await mov!.registrar(
            uid: uid,
            etiquetaId: atualizado.id,
            tipo: EstoqueMovModel.tipoAjusteSaida,
            quantidade: deltaQuantidade.abs(),
            unidadeMedida: unidadeMedida,
            produtoNome: atualizado.produtoNome,
            motivo: "Ajuste ao editar etiqueta",
          );
        }
      }

      editingQuantidade = qtdInformada;
      editingQuantidadeRestante = novoRestante;
      editingStatusEstoque = statusEstoqueFinal;
      editingSoldAt = soldAtFinal;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<EtiquetaModel?> getById({
    required String uid,
    required String id,
  }) async {
    return getEtiquetaById(uid: uid, id: id);
  }

  Future<void> deleteSoft(String uid, String id) async {
    if (kIsWeb) {
      final current = await getEtiquetaById(uid: uid, id: id);
      if (current == null) return;

      final updated = EtiquetaModel(
        id: current.id,
        tipoId: current.tipoId,
        tipoNome: current.tipoNome,
        produtoNome: current.produtoNome,
        categoriaId: current.categoriaId,
        categoriaNome: current.categoriaNome,
        setorId: current.setorId,
        setorNome: current.setorNome,
        dataFabricacao: current.dataFabricacao,
        dataValidade: current.dataValidade,
        camposCustomValores: current.camposCustomValores,
        quantidade: current.quantidade,
        quantidadeRestante: current.quantidadeRestante,
        unidadeMedida: current.unidadeMedida,
        statusEstoque: "cancelado",
        soldAt: current.soldAt,
        status: "excluida",
        lote: current.lote,
        createdAt: current.createdAt,
        incluirTabelaNutricional: current.incluirTabelaNutricional,
        tabelaNutricional: current.tabelaNutricional,
      );

      await _etiquetasCol(uid)
          .doc(id)
          .set(updated.toMap(), SetOptions(merge: true));
    } else {
      await repo!.deleteSoft(uid, id);
    }

    notifyListeners();
  }

  Future<void> reabrirEtiqueta({
    required String uid,
    required String etiquetaId,
    required num quantidadeRestante,
  }) async {
    if (kIsWeb) {
      final current = await getEtiquetaById(uid: uid, id: etiquetaId);
      if (current == null) {
        throw Exception("Etiqueta não encontrada.");
      }

      final now = DateTime.now();
      final novoStatusEstoque = quantidadeRestante <= 0 ? "vendido" : "ativo";
      final soldAt = novoStatusEstoque == "vendido" ? (current.soldAt ?? now) : null;

      final updated = EtiquetaModel(
        id: current.id,
        tipoId: current.tipoId,
        tipoNome: current.tipoNome,
        produtoNome: current.produtoNome,
        categoriaId: current.categoriaId,
        categoriaNome: current.categoriaNome,
        setorId: current.setorId,
        setorNome: current.setorNome,
        dataFabricacao: current.dataFabricacao,
        dataValidade: current.dataValidade,
        camposCustomValores: current.camposCustomValores,
        status: "ativa",
        lote: current.lote,
        createdAt: current.createdAt,
        quantidade: quantidadeRestante,
        quantidadeRestante: quantidadeRestante,
        unidadeMedida: current.unidadeMedida,
        statusEstoque: novoStatusEstoque,
        soldAt: soldAt,
        incluirTabelaNutricional: current.incluirTabelaNutricional,
        tabelaNutricional: current.tabelaNutricional,
      );

      await _etiquetasCol(uid)
          .doc(etiquetaId)
          .set(updated.toMap(), SetOptions(merge: true));
    } else {
        final current = await repo!.getById(uid: uid, id: etiquetaId);
        if (current == null) {
          throw Exception("Etiqueta não encontrada.");
        }

        final updated = EtiquetaModel(
          id: current.id,
          tipoId: current.tipoId,
          tipoNome: current.tipoNome,
          produtoNome: current.produtoNome,
          categoriaId: current.categoriaId,
          categoriaNome: current.categoriaNome,
          setorId: current.setorId,
          setorNome: current.setorNome,
          dataFabricacao: current.dataFabricacao,
          dataValidade: current.dataValidade,
          camposCustomValores: current.camposCustomValores,
          status: "ativa",
          lote: current.lote,
          createdAt: current.createdAt,
          quantidade: quantidadeRestante,
          quantidadeRestante: quantidadeRestante,
          unidadeMedida: current.unidadeMedida,
          statusEstoque: "ativo",
          soldAt: null,
          incluirTabelaNutricional: current.incluirTabelaNutricional,
          tabelaNutricional: current.tabelaNutricional,
        );

        await repo!.upsert(uid, updated);
      }

    notifyListeners();
  }

  Future<void> salvarEtiquetaAtualizada({
    required String uid,
    required EtiquetaModel etiqueta,
  }) async {
    if (kIsWeb) {
      await _etiquetasCol(uid)
          .doc(etiqueta.id)
          .set(etiqueta.toMap(), SetOptions(merge: true));
    } else {
      await repo!.update(uid, etiqueta);
    }

    notifyListeners();
  }

  Future<List<EtiquetaModel>> listByPeriodo({
    required String uid,
    required DateTime inicio,
    required DateTime fim,
    String? status,
    String? statusEstoque,
    String? tipoId,
  }) async {
    if (kIsWeb) {
      Query<Map<String, dynamic>> query = _etiquetasCol(uid)
          .where(
            'dataValidade',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
          )
          .where(
            'dataValidade',
            isLessThanOrEqualTo: Timestamp.fromDate(fim),
          );

      final snap = await query.get();

      DateTime dt(dynamic v) =>
          v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

      DateTime? dtN(dynamic v) => v is Timestamp ? v.toDate() : null;

      var itens = snap.docs.map((doc) {
        final data = doc.data();

        final tabelaMap = data["tabelaNutricional"];
        final tabela = tabelaMap is Map<String, dynamic>
            ? TabelaNutricionalModel.fromMap(tabelaMap)
            : tabelaMap is Map
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
          status: (data["status"] ?? "ativa").toString(),
          lote: data["lote"]?.toString(),
          incluirTabelaNutricional: data["incluirTabelaNutricional"] == true,
          tabelaNutricional: tabela,
          quantidade: (data["quantidade"] as num?) ?? 1,
          quantidadeRestante: (data["quantidadeRestante"] as num?) ?? 1,
          unidadeMedida: (data["unidadeMedida"] ?? "un").toString(),
          statusEstoque: (data["statusEstoque"] ?? "ativo").toString(),
          soldAt: dtN(data["soldAt"]),
          createdAt: dtN(data["createdAt"]),
        );
      }).toList();

      if (status != null) {
        itens = itens.where((e) => e.status == status).toList();
      }

      if (statusEstoque != null) {
        itens = itens.where((e) => e.statusEstoque == statusEstoque).toList();
      }

      if (tipoId != null) {
        itens = itens.where((e) => e.tipoId == tipoId).toList();
      }

      return itens;
    } else {
      return repo!.listByPeriodo(
        uid: uid,
        inicio: inicio,
        fim: fim,
        status: status,
        statusEstoque: statusEstoque,
        tipoId: tipoId,
      );
    }
  }
}