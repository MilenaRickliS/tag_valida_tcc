import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/design_etiqueta_v2_model.dart';
import '../../../../models/tipo_etiqueta_model.dart';
import '../../../models/etiqueta_layout_preset.dart';
import '../mappers/design_etiqueta_v2_default_mapper.dart';
import '../mappers/design_etiqueta_v2_mapper.dart';

class DesignEtiquetaV2LocalRepo {
  static const _prefix = 'design_etiqueta_config_v3_';

  String _key(String tipoId, EtiquetaLayoutPreset preset) {
    return '$_prefix${tipoId}_${preset.storageKey}';
  }

  Future<DesignEtiquetaV2Model> loadForTipo(
    TipoEtiquetaModel tipo, {
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(tipo.id, preset));

    final defaultModel = DesignEtiquetaV2DefaultMapper.fromTipoEtiqueta(
      tipo,
      preset: preset,
    );

    if (raw == null || raw.trim().isEmpty) {
      return defaultModel;
    }

    try {
      final saved = DesignEtiquetaV2Mapper.fromJson(raw);
      return _mergeWithDefault(saved, defaultModel, preset);
    } catch (_) {
      return defaultModel;
    }
  }

  Future<DesignEtiquetaV2Model?> loadSavedByTipoId(
    String tipoId, {
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(tipoId, preset));

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      return DesignEtiquetaV2Mapper.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  DesignEtiquetaV2Model _mergeWithDefault(
    DesignEtiquetaV2Model saved,
    DesignEtiquetaV2Model defaultModel,
    EtiquetaLayoutPreset preset,
  ) {
    final savedMap = {
      for (final c in saved.campos) c.id: c,
    };

    final mergedCampos = defaultModel.campos.map((defaultCampo) {
      final savedCampo = savedMap[defaultCampo.id];

      if (savedCampo == null) {
        return defaultCampo;
      }

      return defaultCampo.copyWith(
        visivel: defaultCampo.obrigatorio ? true : savedCampo.visivel,
        isBold: savedCampo.isBold,
        align: savedCampo.align,
        ordem: savedCampo.ordem,
      );
    }).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return DesignEtiquetaV2Model(
      tipoEtiquetaId: defaultModel.tipoEtiquetaId,
      tipoEtiquetaNome: defaultModel.tipoEtiquetaNome,
      preset: preset,
      mostrarMarcaTagValida: saved.mostrarMarcaTagValida,
      destacarValidade: saved.destacarValidade,
      campos: mergedCampos,
    );
  }

  Future<void> saveForTipo(
    DesignEtiquetaV2Model model, {
    required EtiquetaLayoutPreset preset,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(model.tipoEtiquetaId, preset),
      DesignEtiquetaV2Mapper.toJson(model, preset: preset),
    );
  }

  Future<void> resetForTipo(
    TipoEtiquetaModel tipo, {
    required EtiquetaLayoutPreset preset,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(tipo.id, preset));
  }

  Future<void> resetAllPresetsForTipo(TipoEtiquetaModel tipo) async {
    final prefs = await SharedPreferences.getInstance();

    for (final preset in EtiquetaLayoutPreset.values) {
      await prefs.remove(_key(tipo.id, preset));
    }
  }
}