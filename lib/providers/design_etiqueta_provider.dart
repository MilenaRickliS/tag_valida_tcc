import 'package:flutter/material.dart';
import '../data/local/repos/design_etiqueta_local_repo.dart';
import '../models/design_etiqueta_model.dart';
import '../models/tipo_etiqueta_model.dart';
import '../models/design_limite_model.dart';
import '../models/design_validacao_model.dart';

class DesignEtiquetaProvider extends ChangeNotifier {
  final DesignEtiquetaLocalRepo repo;

  DesignEtiquetaProvider({required this.repo});

  DesignEtiquetaModel? _config;
  TipoEtiquetaModel? _tipoSelecionado;
  bool _loading = false;
  bool _saving = false;

  DesignValidationResult? _validation;

  DesignEtiquetaModel? get config => _config;
  TipoEtiquetaModel? get tipoSelecionado => _tipoSelecionado;
  bool get loading => _loading;
  bool get saving => _saving;
  DesignValidationResult? get validation => _validation;

  bool get canSave => _validation?.ok ?? true;

  void _revalidateInternal() {
    if (_config == null) {
      _validation = null;
      return;
    }
    _validation = DesignEtiquetaLimiter.validate(_config!);
  }

  void revalidate() {
    _revalidateInternal();
    notifyListeners();
  }

  Future<void> loadTipo(TipoEtiquetaModel tipo) async {
    _tipoSelecionado = tipo;
    _loading = true;
    notifyListeners();

    final designSalvo = await repo.loadForTipo(tipo);

    _config = designSalvo.copyWith(
      larguraMm: tipo.larguraMm,
      alturaMm: tipo.alturaMm,
    );

    _revalidateInternal();

    _loading = false;
    notifyListeners();
  }

  Future<void> saveAtual() async {
    final cfg = _config;
    if (cfg == null) return;

    _revalidateInternal();
    if (!canSave) {
      notifyListeners();
      return;
    }

    _saving = true;
    notifyListeners();

    await repo.saveForTipo(cfg);

    _saving = false;
    notifyListeners();
  }

  Future<void> resetAtual() async {
    final tipo = _tipoSelecionado;
    if (tipo == null) return;

    _loading = true;
    notifyListeners();

    await repo.resetForTipo(tipo);
    _config = await repo.loadForTipo(tipo);

    _revalidateInternal();

    _loading = false;
    notifyListeners();
  }

  void setLarguraMm(double value) {
    if (_config == null) return;

    _config = _config!.copyWith(larguraMm: value);
    _revalidateInternal();
    notifyListeners();
  }

  void setAlturaMm(double value) {
    if (_config == null) return;

    _config = _config!.copyWith(alturaMm: value);
    _revalidateInternal();
    notifyListeners();
  }

  void setMostrarMarcaTagValida(bool value) {
    if (_config == null) return;

    _config = _config!.copyWith(mostrarMarcaTagValida: value);
    _revalidateInternal();
    notifyListeners();
  }

  void setDestacarValidade(bool value) {
    if (_config == null) return;

    _config = _config!.copyWith(destacarValidade: value);
    _revalidateInternal();
    notifyListeners();
  }

  void toggleCampo(String id, bool value) {
    if (_config == null) return;

    final atualizados = _config!.campos.map((c) {
      if (c.id != id) return c;
      if (c.obrigatorio) return c;
      return c.copyWith(visivel: value);
    }).toList();

    final tentativa = _config!.copyWith(campos: atualizados);
    final resultado = DesignEtiquetaLimiter.validate(tentativa);

  
    if (value && !resultado.ok) {
      _validation = resultado;
      notifyListeners();
      return;
    }

    _config = tentativa;
    _validation = resultado;
    notifyListeners();
  }

  void setFontSize(String id, double value) {
    if (_config == null) return;

    final campoAtual = _config!.campos.firstWhere((c) => c.id == id);

    final atualizados = _config!.campos.map((c) {
      if (c.id != id) return c;
      return c.copyWith(fontSize: value);
    }).toList();

    final tentativa = _config!.copyWith(campos: atualizados);
    final resultado = DesignEtiquetaLimiter.validate(tentativa);

   
    if (value > campoAtual.fontSize && !resultado.ok) {
      _validation = resultado;
      notifyListeners();
      return;
    }

    _config = tentativa;
    _validation = resultado;
    notifyListeners();
  }

  void setBold(String id, bool value) {
    if (_config == null) return;

    final campoAtual = _config!.campos.firstWhere((c) => c.id == id);

    final atualizados = _config!.campos.map((c) {
      if (c.id != id) return c;
      return c.copyWith(isBold: value);
    }).toList();

    final tentativa = _config!.copyWith(campos: atualizados);
    final resultado = DesignEtiquetaLimiter.validate(tentativa);

    
    if (!campoAtual.isBold && value && !resultado.ok) {
      _validation = resultado;
      notifyListeners();
      return;
    }

    _config = tentativa;
    _validation = resultado;
    notifyListeners();
  }

  void setAlign(String id, TextAlign value) {
    if (_config == null) return;

    final atualizados = _config!.campos.map((c) {
      if (c.id != id) return c;
      return c.copyWith(align: value);
    }).toList();

    final tentativa = _config!.copyWith(campos: atualizados);
    final resultado = DesignEtiquetaLimiter.validate(tentativa);

  
    _config = tentativa;
    _validation = resultado;
    notifyListeners();
  }

  void reorderCampos(int oldIndex, int newIndex) {
    if (_config == null) return;

    final atual = [..._config!.campos];

    final item = atual[oldIndex];

    final isEmpresa = item.id == 'empresa';
    final isProduto = item.id == 'produto';
    final isQr = item.tipo == CampoDesignTipo.qrcode || item.id == 'qrcode';

    final posicaoFixa = isEmpresa || isProduto || isQr;

    
    if (posicaoFixa) {
      return;
    }

    if (newIndex > oldIndex) newIndex -= 1;

    atual.removeAt(oldIndex);
    atual.insert(newIndex, item);

    
    final empresa = atual.where((c) => c.id == 'empresa');
    final produto = atual.where((c) => c.id == 'produto');
    final qr = atual.where((c) =>
        c.tipo == CampoDesignTipo.qrcode || c.id == 'qrcode');

    final outros = atual.where((c) =>
        c.id != 'empresa' &&
        c.id != 'produto' &&
        c.tipo != CampoDesignTipo.qrcode &&
        c.id != 'qrcode');

    final finalList = [
      ...empresa,
      ...produto,
      ...qr,
      ...outros,
    ];

    final ajustados = finalList.asMap().entries.map((e) {
      return e.value.copyWith(ordem: e.key);
    }).toList();

    final tentativa = _config!.copyWith(campos: ajustados);
    final resultado = DesignEtiquetaLimiter.validate(tentativa);

    _config = tentativa;
    _validation = resultado;
    notifyListeners();
  }
}