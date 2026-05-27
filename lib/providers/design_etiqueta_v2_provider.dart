import 'package:flutter/material.dart';

import '../data/local/repos/design_etiqueta_v2_local_repo.dart';
import '../../models/design_etiqueta_v2_model.dart';
import '../../models/design_etiqueta_v2_limiter.dart';
import '../../models/design_validacao_v2_model.dart';
import '../../models/etiqueta_layout_preset.dart';
import '../../../../models/tipo_etiqueta_model.dart';

class DesignEtiquetaV2Provider extends ChangeNotifier {
  final DesignEtiquetaV2LocalRepo repo;

  DesignEtiquetaV2Provider({required this.repo});

  DesignEtiquetaV2Model? _config;
  TipoEtiquetaModel? _tipoSelecionado;

  EtiquetaLayoutPreset _preset = EtiquetaLayoutPreset.mm60x40;

  bool _loading = false;
  bool _saving = false;

  DesignValidationV2Result? _validation;

  DesignEtiquetaV2Model? get config => _config;
  TipoEtiquetaModel? get tipoSelecionado => _tipoSelecionado;
  EtiquetaLayoutPreset get preset => _preset;

  bool get loading => _loading;
  bool get saving => _saving;

  DesignValidationV2Result? get validation => _validation;

  bool get canSave => _validation?.ok ?? true;

  DesignEtiquetaV2Model _mergeCamposCustomDoTipo(
  DesignEtiquetaV2Model design,
  TipoEtiquetaModel tipo,
) {
  final campos = [...design.campos];

  String normalizar(String s) {
    return s
        .toLowerCase()
        .trim()
        .replaceAll('ç', 'c')
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u');
  }

  for (final custom in tipo.camposCustom) {
    if (custom.tipo == CampoTipo.image) continue;

    final indexMesmoId = campos.indexWhere((c) => c.id == custom.key);
    if (indexMesmoId != -1) continue;

    final nomeCustom = normalizar(custom.label);

    final indexMesmoNome = campos.indexWhere(
      (c) => normalizar(c.nome) == nomeCustom,
    );

    if (indexMesmoNome != -1) {
      final antigo = campos[indexMesmoNome];

      campos[indexMesmoNome] = antigo.copyWith(
        id: custom.key,
        nome: custom.label,
        tipo: CampoDesignV2Tipo.info,
        labelImpresso: custom.label,
        valorExemplo: custom.label,
        obrigatorio: custom.obrigatorio,
      );

      continue;
    }

    campos.add(
      CampoDesignEtiquetaV2Model(
        id: custom.key,
        nome: custom.label,
        tipo: CampoDesignV2Tipo.info,
        ordem: campos.length,
        visivel: true,
        obrigatorio: custom.obrigatorio,
        isBold: false,
        align: TextAlign.left,
        labelImpresso: custom.label,
        valorExemplo: custom.label,
      ),
    );
  }

  return design.copyWith(campos: campos);
}

  Future<void> loadTipo(
    TipoEtiquetaModel tipo, {
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  }) async {
    _tipoSelecionado = tipo;
    _preset = preset;

    _loading = true;
    notifyListeners();

    final design = await repo.loadForTipo(
      tipo,
      preset: preset,
    );

    final designComCamposCustom = _mergeCamposCustomDoTipo(
      DesignEtiquetaV2Model.fromMap(design.toMap()).copyWith(preset: preset),
      tipo,
    );

    _config = designComCamposCustom;

    _revalidateInternal();

    _loading = false;
    notifyListeners();
  }

  Future<void> setPreset(EtiquetaLayoutPreset preset) async {
    if (_tipoSelecionado == null) return;

    _preset = preset;

    await loadTipo(_tipoSelecionado!, preset: preset);
  }

  Future<void> saveAtual(String uid) async {
    final cfg = _config;
    if (cfg == null) return;

    _revalidateInternal();
    if (!canSave) {
      notifyListeners();
      return;
    }


    _saving = true;
    notifyListeners();

    await repo.saveForTipo(
      cfg,
      preset: preset,
      uid: uid,
    );

    _saving = false;
    notifyListeners();
  }

  Future<void> resetAtual(String uid) async {
    final tipo = _tipoSelecionado;
    if (tipo == null) return;

    _loading = true;
    notifyListeners();

    await repo.resetForTipo(
      tipo,
      preset: _preset,
      uid: uid,
    );

    await loadTipo(tipo, preset: _preset);
  }

  void _revalidateInternal() {
    if (_config == null) {
      _validation = null;
      return;
    }

    _validation = DesignEtiquetaV2Limiter.validate(_config!);
  }

  void revalidate() {
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
    final resultado = DesignEtiquetaV2Limiter.validate(tentativa);

    if (value && !resultado.ok) {
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

    final atualizados = _config!.campos.map((c) {
      if (c.id != id) return c;
      return c.copyWith(isBold: value);
    }).toList();

    _config = _config!.copyWith(campos: atualizados);
    _revalidateInternal();
    notifyListeners();
  }

  void setAlign(String id, TextAlign value) {
    if (_config == null) return;

    final atualizados = _config!.campos.map((c) {
      if (c.id != id) return c;
      return c.copyWith(align: value);
    }).toList();

    _config = _config!.copyWith(campos: atualizados);
    _revalidateInternal();
    notifyListeners();
  }

  void reorderCampos(int oldIndex, int newIndex) {
    if (_config == null) return;

    final atual = [..._config!.campos];
    final item = atual[oldIndex];

    if (item.id == 'empresa' ||
        item.id == 'produto' ||
        item.tipo == CampoDesignV2Tipo.qrcode) {
      return;
    }

    if (newIndex > oldIndex) newIndex -= 1;

    atual.removeAt(oldIndex);
    atual.insert(newIndex, item);

    final ajustados = atual.asMap().entries.map((e) {
      return e.value.copyWith(ordem: e.key);
    }).toList();

    _config = _config!.copyWith(campos: ajustados);
    _revalidateInternal();
    notifyListeners();
  }

  void setMostrarMarcaTagValida(bool value) {
    if (_config == null) return;

    _config = _config!.copyWith(
      mostrarMarcaTagValida: value,
    );

    _revalidateInternal();
    notifyListeners();
  }

  void setDestacarValidade(bool value) {
    if (_config == null) return;

    _config = _config!.copyWith(
      destacarValidade: value,
    );

    _revalidateInternal();
    notifyListeners();
  }

  void setTamanhoFonte(TamanhoFonteEtiqueta value) {
    if (_config == null) return;

    final tentativa = _config!.copyWith(
      tamanhoFonte: value,
    );

    final resultado = DesignEtiquetaV2Limiter.validate(tentativa);

    if (!resultado.ok) {
      _validation = resultado;
      notifyListeners();
      return;
    }

    _config = tentativa;
    _validation = resultado;
    notifyListeners();
  }
}