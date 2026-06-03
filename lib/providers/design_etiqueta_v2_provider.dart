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


  Future<void> loadTipo(
    TipoEtiquetaModel tipo, {
    required String uid,
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  })async {
    _tipoSelecionado = tipo;
    _preset = preset;

    _loading = true;
    notifyListeners();

    final design = await repo.loadForTipo(
      tipo,
      uid: uid,
      preset: preset,
    );

    debugPrint('PROVIDER LOAD TIPO: ${tipo.id} - ${tipo.nome}');
    debugPrint('PROVIDER RECEBEU CAMPOS: ${design.campos.map((c) => '${c.id}:${c.visivel}:${c.ordem}').join(' | ')}');

    final normalizado = DesignEtiquetaV2Model.fromMap(
      design.toMap(),
    ).copyWith(preset: preset);


     _config = normalizado.copyWith(
      campos: _deduplicarCampos(normalizado.campos),
    );

    _revalidateInternal();

    _loading = false;
    notifyListeners();
  }

  Future<void> setPreset(
    EtiquetaLayoutPreset preset, {
    required String uid,
  }) async {
    if (_tipoSelecionado == null) return;

    _preset = preset;

    await loadTipo(
      _tipoSelecionado!,
      uid: uid,
      preset: preset,
    );
  }

  Future<bool> saveAtual(String uid) async {
    final cfg = _config;
    if (cfg == null) return false;

    final camposSemImagem = cfg.campos.map((c) {
      if (c.tipo == CampoDesignV2Tipo.imagem || c.id == 'imagem') {
        return c.copyWith(visivel: false);
      }
      return c;
    }).toList();

    _config = cfg.copyWith(
      campos: _deduplicarCampos(camposSemImagem),
    );

    _revalidateInternal();

    if (!canSave) {
      notifyListeners();
      return false;
    }

    _saving = true;
    notifyListeners();

    await repo.saveForTipo(
      _config!,
      preset: preset,
      uid: uid,
    );

    final tipo = _tipoSelecionado;

    if (tipo != null) {
      final recarregado = await repo.loadForTipo(
        tipo,
        uid: uid,
        preset: preset,
      );

      final normalizado = recarregado.copyWith(preset: preset);

       _config = normalizado.copyWith(
        campos: _deduplicarCampos(normalizado.campos),
      );

      _revalidateInternal();
    }

    _saving = false;
    notifyListeners();

    return true;
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

    await loadTipo(
      tipo,
      uid: uid,
      preset: _preset,
    );
  }

  String _normalizarCampoId(String id) {
    var key = id.trim().toLowerCase();

    if (key.startsWith('custom_')) {
      key = key.substring(7);
    }

    return key;
  }

  List<CampoDesignEtiquetaV2Model> _deduplicarCampos(
    List<CampoDesignEtiquetaV2Model> campos,
  ) {
    final map = <String, CampoDesignEtiquetaV2Model>{};

    for (final campo in campos) {
      final key = _normalizarCampoId(campo.id);

      if (!map.containsKey(key)) {
        map[key] = campo;
      } else {
        final antigo = map[key]!;

        final preferido = antigo.id.startsWith('custom_') ? antigo : campo;

        map[key] = preferido.copyWith(
          visivel: antigo.visivel || campo.visivel,
          isBold: antigo.isBold || campo.isBold,
          align: antigo.align,
          ordem: antigo.ordem < campo.ordem ? antigo.ordem : campo.ordem,
        );
      }
    }

    return map.values.toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
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