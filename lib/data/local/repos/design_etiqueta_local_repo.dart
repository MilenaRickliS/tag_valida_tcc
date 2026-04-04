import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/design_etiqueta_model.dart';
import '../../../models/tipo_etiqueta_model.dart';
import '../mappers/design_etiqueta_mapper.dart';
import '../mappers/design_etiqueta_default_mapper.dart';

class DesignEtiquetaLocalRepo {
  static const _prefix = 'design_etiqueta_config_v2_';

  String _key(String tipoId) => '$_prefix$tipoId';

  Future<DesignEtiquetaModel> loadForTipo(TipoEtiquetaModel tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(tipo.id));

    final defaultModel = DesignEtiquetaDefaultMapper.fromTipoEtiqueta(tipo);

    if (raw == null || raw.trim().isEmpty) {
      return defaultModel;
    }

    try {
      final saved = DesignEtiquetaMapper.fromJson(raw);
      return _mergeWithDefault(saved, defaultModel);
    } catch (_) {
      return defaultModel;
    }
  }

  DesignEtiquetaModel _mergeWithDefault(
    DesignEtiquetaModel saved,
    DesignEtiquetaModel defaultModel,
  ) {
    final savedMap = {
      for (final c in saved.campos) c.id: c,
    };

    final mergedCampos = defaultModel.campos.map((defaultCampo) {
      final savedCampo = savedMap[defaultCampo.id];
      if (savedCampo == null) return defaultCampo;

      return defaultCampo.copyWith(
        visivel: defaultCampo.obrigatorio ? true : savedCampo.visivel,
        fontSize: savedCampo.fontSize,
        isBold: savedCampo.isBold,
        align: savedCampo.align,
        ordem: savedCampo.ordem,
      );
    }).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return DesignEtiquetaModel(
      tipoEtiquetaId: defaultModel.tipoEtiquetaId,
      tipoEtiquetaNome: defaultModel.tipoEtiquetaNome,
      larguraMm: saved.larguraMm,
      alturaMm: saved.alturaMm,
      mostrarLogo: saved.mostrarLogo,
      mostrarBordaInterna: saved.mostrarBordaInterna,
      destacarValidade: saved.destacarValidade,
      campos: mergedCampos,
    );
  }

  Future<void> saveForTipo(DesignEtiquetaModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(model.tipoEtiquetaId), DesignEtiquetaMapper.toJson(model));
  }

  Future<void> resetForTipo(TipoEtiquetaModel tipo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(tipo.id));
  }
}