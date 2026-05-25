import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../models/setor_model.dart';
import '../models/tipo_etiqueta_model.dart';
import '../models/etiqueta_model.dart';
import '../models/estoque_mov_model.dart';
import '../models/etiqueta_template_model.dart';
import '../models/tabela_nutricional_model.dart';
import './../data/local/repos/etiqueta_template_local_repo.dart';
import '../data/local/repos/etiquetas_local_repo.dart';
import '../providers/estoque_mov_local_provider.dart';
import 'dart:math';

class GerarEtiquetaLocalProvider extends ChangeNotifier {
  final EtiquetasLocalRepo repo;
  final EstoqueMovLocalProvider mov; 
  final EtiquetasTemplatesLocalRepo templateRepo;
  GerarEtiquetaLocalProvider({required this.repo, required this.mov, required this.templateRepo,});

  String? tipoId;
  CategoriaModel? categoria;
  SetorModel? setor;

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

    fabricacao = e.dataFabricacao;
    validade = e.dataValidade;


    editingQuantidade = e.quantidade;
    editingQuantidadeRestante = e.quantidadeRestante;
    editingStatusEstoque = e.statusEstoque;
    editingSoldAt = e.soldAt;


    quantidadeCtrl.text = _normalizarQuantidade(e.quantidade, unidade: e.unidadeMedida);
    unidadeMedida = e.unidadeMedida;

    incluirTabelaNutricional = e.incluirTabelaNutricional;

    if (e.tabelaNutricional != null) {
      porcoesPorEmbalagemCtrl.text = e.tabelaNutricional!.porcoesPorEmbalagem.toString();
      porcaoCtrl.text = e.tabelaNutricional!.porcao;
       quantidadeMedidaCtrl.text = e.tabelaNutricional!.quantidadeMedida;
      medidaCaseiraCtrl.text = e.tabelaNutricional!.medidaCaseira;
      valorEnergeticoCtrl.text = e.tabelaNutricional!.valorEnergetico.toString();
      carboidratosCtrl.text = e.tabelaNutricional!.carboidratos.toString();
      acucaresTotaisCtrl.text = e.tabelaNutricional!.acucaresTotais.toString();
      acucaresAdicionadosCtrl.text = e.tabelaNutricional!.acucaresAdicionados.toString();
      proteinasCtrl.text = e.tabelaNutricional!.proteinas.toString();
      gordurasTotaisCtrl.text = e.tabelaNutricional!.gordurasTotais.toString();
      gordurasSaturadasCtrl.text = e.tabelaNutricional!.gordurasSaturadas.toString();
      gordurasTransCtrl.text = e.tabelaNutricional!.gordurasTrans.toString();
      fibraAlimentarCtrl.text = e.tabelaNutricional!.fibraAlimentar.toString();
      sodioCtrl.text = e.tabelaNutricional!.sodio.toString();
    }

    camposValores
      ..clear()
      ..addAll((e.camposCustomValores).map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map))));

    if (tipoAtual != null) {
      for (final c in tipoAtual.camposCustom) {
        final v = camposValores[c.key]?["value"];
        if (c.tipo == CampoTipo.text || c.tipo == CampoTipo.multiline) {
          _setCtrlText(c.key, (v ?? "").toString());
        } else if (
          c.tipo == CampoTipo.integer ||
          c.tipo == CampoTipo.decimal ||
          c.tipo == CampoTipo.currency ||
          c.tipo == CampoTipo.priceMode
        ) {
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
    _recalcularValidadeSePossivel(tipoAtual);
    notifyListeners();
  }

  void setSetor(SetorModel? s) {
    setor = s;
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

  Future<String> salvarEtiqueta({
    required String uid,
    required TipoEtiquetaModel tipoAtual,
  }) async {
    final err = validar(tipoAtual);
    if (err != null) throw Exception(err);

    ensureLoteAuto(tipoAtual: tipoAtual);

    saving = true;
    notifyListeners();

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

    await repo.upsert(uid, etiqueta);
    
    final existing = await templateRepo.findByKey(
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


    await templateRepo.upsert(uid, template);

    await mov.registrarEntrada(
      uid: uid,
      etiquetaId: id,
      quantidade: qtd,
      unidadeMedida: etiqueta.unidadeMedida,
      produtoNome: etiqueta.produtoNome,
      motivo: "Criação da etiqueta",
    );

    saving = false;
    notifyListeners();

    return id;
  }

  Future<void> salvarEdicao({
    required String uid,
    required TipoEtiquetaModel tipoAtual,
  }) async {
    final err = validar(tipoAtual);
    if (err != null) throw Exception(err);
    if (editingEtiquetaId == null) throw Exception("Nada para editar.");

    saving = true;
    notifyListeners();

    final now = DateTime.now();
    final qtdNova = _parseQtdOrThrow();
    final statusWanted = (editingStatusEstoque ?? "ativo").trim().toLowerCase();

    final before = await repo.getById(uid: uid, id: editingEtiquetaId!);
    if (before == null) {
      saving = false;
      notifyListeners();
      throw Exception("Etiqueta não encontrada para edição.");
    }

    final oldQtd = before.quantidade;
    final oldRest = before.quantidadeRestante;
    final oldStatus = before.statusEstoque.trim().toLowerCase();
    final oldCancelado = oldStatus == "cancelado";

    num restNovo;
    if (statusWanted == "cancelado") {
      restNovo = 0;
    } else if (statusWanted == "vendido") {
      restNovo = 0;
    } else {
      final saiuAntes = (oldQtd - oldRest);
      restNovo = max<num>(0, qtdNova - saiuAntes);
    }

    if (oldCancelado && statusWanted != "cancelado") {
      final voltou = restNovo;
      if (voltou > 0) {
        await mov.registrar(
          uid: uid,
          etiquetaId: before.id,
          tipo: EstoqueMovModel.tipoAjusteEntrada,
          quantidade: voltou,
          unidadeMedida: unidadeMedida,
          produtoNome: before.produtoNome,
          motivo: "Reativação (saindo de cancelado)",
        );
      }
    }

    if (!oldCancelado && statusWanted == "cancelado" && oldRest > 0) {
      await mov.registrarCancelamento(
        uid: uid,
        etiquetaId: before.id,
        quantidade: oldRest,
        unidadeMedida: unidadeMedida,
        produtoNome: before.produtoNome,
        motivo: "Cancelado na edição",
      );
    }

    if (statusWanted == "vendido") {
      final vendeu = oldRest - restNovo;
      if (vendeu > 0) {
        await mov.registrarVenda(
          uid: uid,
          etiquetaId: before.id,
          quantidade: vendeu,
          unidadeMedida: unidadeMedida,
          produtoNome: before.produtoNome,
          motivo: "Venda (na edição)",
        );
      }
    }

    if (statusWanted != "cancelado" && statusWanted != "vendido") {
      final diff = restNovo - oldRest;
      if (diff > 0) {
        await mov.registrar(
          uid: uid,
          etiquetaId: before.id,
          tipo: EstoqueMovModel.tipoAjusteEntrada,
          quantidade: diff,
          unidadeMedida: unidadeMedida,
          produtoNome: before.produtoNome,
          motivo: "Ajuste na edição (entrada)",
        );
      } else if (diff < 0) {
        await mov.registrar(
          uid: uid,
          etiquetaId: before.id,
          tipo: EstoqueMovModel.tipoAjusteSaida,
          quantidade: diff.abs(),
          unidadeMedida: unidadeMedida,
          produtoNome: before.produtoNome,
          motivo: "Ajuste na edição (saída)",
        );
      }
    }

    final statusEstoque = EtiquetaModel.calcStatusEstoque(
      restante: restNovo,
      current: statusWanted,
    );

    final safeCampos = _sanitizeCamposValores(camposValores);
    final lote = (safeCampos["lote"]?["value"] ?? "").toString().trim();
    final loteFinal = lote.isEmpty ? null : lote;
    final tabela = _buildTabelaNutricional();

    final etiqueta = EtiquetaModel(
      id: before.id,
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
      createdAt: before.createdAt,
      quantidade: qtdNova,
      quantidadeRestante: restNovo,
      unidadeMedida: unidadeMedida,
      statusEstoque: statusEstoque,
      soldAt: statusEstoque == "vendido" ? (before.soldAt ?? now) : null,
    );

    await repo.upsert(uid, etiqueta);

    editingQuantidade = qtdNova;
    editingQuantidadeRestante = restNovo;
    editingStatusEstoque = statusEstoque;

    saving = false;
    notifyListeners();
  }

  Future<void> ajustarRestante({
    required String uid,
    required String etiquetaId,
    required num novoRestante,
  }) async {
   final before = await repo.getById(uid: uid, id: etiquetaId);
    if (before == null) throw Exception("Etiqueta não encontrada.");

    final oldRest = before.quantidadeRestante;

    await repo.ajustarQuantidade(uid: uid, etiquetaId: etiquetaId, novoRestante: novoRestante);

    final diff = novoRestante - oldRest;
    if (diff > 0) {
      await mov.registrar(
        uid: uid,
        etiquetaId: etiquetaId,
        tipo: EstoqueMovModel.tipoAjusteEntrada,
        quantidade: diff,
        unidadeMedida: before.unidadeMedida,
        produtoNome: before.produtoNome,
        motivo: "Ajuste manual (entrada)",
      );
    } else if (diff < 0) {
      await mov.registrar(
        uid: uid,
        etiquetaId: etiquetaId,
        tipo: EstoqueMovModel.tipoAjusteSaida,
        quantidade: diff.abs(),
        unidadeMedida: before.unidadeMedida,
        produtoNome: before.produtoNome,
        motivo: "Ajuste manual (saída)",
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    produtoCtrl.dispose();
    quantidadeCtrl.dispose();

    porcoesPorEmbalagemCtrl.dispose();
    porcaoCtrl.dispose();
    quantidadeMedidaCtrl.dispose();
    medidaCaseiraCtrl.dispose();
    valorEnergeticoCtrl.dispose();
    carboidratosCtrl.dispose();
    acucaresTotaisCtrl.dispose();
    acucaresAdicionadosCtrl.dispose();
    proteinasCtrl.dispose();
    gordurasTotaisCtrl.dispose();
    gordurasSaturadasCtrl.dispose();
    gordurasTransCtrl.dispose();
    fibraAlimentarCtrl.dispose();
    sodioCtrl.dispose();

    for (final c in customCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

   Future<void> reabrirEtiqueta({
      required String uid,
      required String etiquetaId,
      required num quantidadeRestante,
    }) async {
      final before = await repo.getById(uid: uid, id: etiquetaId);
      if (before == null) {
        throw Exception("Etiqueta não encontrada.");
      }

      final updated = EtiquetaModel(
        id: before.id,
        tipoId: before.tipoId,
        tipoNome: before.tipoNome,
        produtoNome: before.produtoNome,
        categoriaId: before.categoriaId,
        categoriaNome: before.categoriaNome,
        setorId: before.setorId,
        setorNome: before.setorNome,
        dataFabricacao: before.dataFabricacao,
        dataValidade: before.dataValidade,
        camposCustomValores: before.camposCustomValores,
        status: "ativa",
        lote: before.lote,
        createdAt: before.createdAt,

        quantidade: quantidadeRestante,
        quantidadeRestante: quantidadeRestante,

        unidadeMedida: before.unidadeMedida,
        statusEstoque: "ativo",
        soldAt: null,
        incluirTabelaNutricional: before.incluirTabelaNutricional,
        tabelaNutricional: before.tabelaNutricional,
      );

      await repo.upsert(uid, updated);
    }

  void setQuantidadeMedida(String value) {
    quantidadeMedidaCtrl.text = value;
    notifyListeners();
  }
}