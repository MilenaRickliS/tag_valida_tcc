import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../../../../models/design_etiqueta_v2_model.dart';
import '../../../../models/tipo_etiqueta_model.dart';
import '../../../models/etiqueta_layout_preset.dart';
import '../app_db.dart';
import '../mappers/design_etiqueta_v2_default_mapper.dart';
import '../mappers/design_etiqueta_v2_mapper.dart';

class DesignEtiquetaV2LocalRepo {
  static const _table = 'design_etiqueta_v2_configs';
  static const _entity = 'design_etiqueta_v2_configs';

  String _entityId(String tipoId, EtiquetaLayoutPreset preset) {
    return '${tipoId}_${preset.storageKey}';
  }

  Future<DesignEtiquetaV2Model> loadForTipo(
    TipoEtiquetaModel tipo, {
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  }) async {
    final defaultModel = DesignEtiquetaV2DefaultMapper.fromTipoEtiqueta(
      tipo,
      preset: preset,
    );

    final saved = await loadSavedByTipoId(tipo.id, preset: preset);

    if (saved == null) return defaultModel;

    return _mergeWithDefault(saved, defaultModel, preset);
  }

  Future<DesignEtiquetaV2Model?> loadSavedByTipoId(
    String tipoId, {
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  }) async {
    final local = await AppDb.instance.db;

    final rows = await local.query(
      _table,
      where: 'tipoEtiquetaId = ? AND preset = ?',
      whereArgs: [tipoId, preset.storageKey],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    try {
      final row = rows.first;

      return DesignEtiquetaV2Mapper.fromMap({
        'tipoEtiquetaId': row['tipoEtiquetaId'],
        'tipoEtiquetaNome': row['tipoEtiquetaNome'],
        'preset': row['preset'],
        'tamanhoFonte': row['tamanhoFonte'] ?? 'media',
        'mostrarMarcaTagValida':
            (row['mostrarMarcaTagValida'] as int? ?? 1) == 1,
        'destacarValidade':
            (row['destacarValidade'] as int? ?? 1) == 1,
        'campos': jsonDecode(row['camposJson'].toString()),
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> saveForTipo(
    DesignEtiquetaV2Model model, {
    required EtiquetaLayoutPreset preset,
    required String uid,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final local = await AppDb.instance.db;

    final camposJson = jsonEncode(
      DesignEtiquetaV2Mapper.toMap(model, preset: preset)['campos'],
    );

    final row = {
      'tipoEtiquetaId': model.tipoEtiquetaId,
      'uid': uid,
      'tipoEtiquetaNome': model.tipoEtiquetaNome,
      'preset': preset.storageKey,
      'tamanhoFonte': model.tamanhoFonte.name,
      'mostrarMarcaTagValida': model.mostrarMarcaTagValida ? 1 : 0,
      'destacarValidade': model.destacarValidade ? 1 : 0,
      'camposJson': camposJson,
      'createdAt': now,
      'updatedAt': now,
    };

    final payload = {
      'tipoEtiquetaId': model.tipoEtiquetaId,
      'tipoEtiquetaNome': model.tipoEtiquetaNome,
      'preset': preset.storageKey,
      'tamanhoFonte': model.tamanhoFonte.name,
      'mostrarMarcaTagValida': model.mostrarMarcaTagValida,
      'destacarValidade': model.destacarValidade,
      'campos': jsonDecode(camposJson),
      'createdAtMs': now,
      'updatedAtMs': now,
    };

    await local.transaction((txn) async {
      await txn.insert(
        _table,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'outbox',
        {
          'uid': uid,
          'entity': _entity,
          'entityId': _entityId(model.tipoEtiquetaId, preset),
          'op': 'UPSERT',
          'payloadJson': jsonEncode(payload),
          'createdAt': now,
          'tries': 0,
          'lastError': null,
        },
      );
    });
  }

  Future<void> resetForTipo(
    TipoEtiquetaModel tipo, {
    required EtiquetaLayoutPreset preset,
    required String uid,
  }) async {
    final local = await AppDb.instance.db;
    final now = DateTime.now().millisecondsSinceEpoch;

    await local.transaction((txn) async {
      await txn.delete(
        _table,
        where: 'uid = ? AND tipoEtiquetaId = ? AND preset = ?',
        whereArgs: [uid, tipo.id, preset.storageKey],
      );

      await txn.insert(
        'outbox',
        {
          'uid': uid,
          'entity': _entity,
          'entityId': _entityId(tipo.id, preset),
          'op': 'DELETE',
          'payloadJson': null,
          'createdAt': now,
          'tries': 0,
          'lastError': null,
        },
      );
    });
  }

  Future<void> resetAllPresetsForTipo(
    TipoEtiquetaModel tipo, {
    required String uid,
  }) async {
    for (final preset in EtiquetaLayoutPreset.values) {
      await resetForTipo(
        tipo,
        preset: preset,
        uid: uid,
      );
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

      if (savedCampo == null) return defaultCampo;

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
      tamanhoFonte: saved.tamanhoFonte,
      mostrarMarcaTagValida: saved.mostrarMarcaTagValida,
      destacarValidade: saved.destacarValidade,
      campos: mergedCampos,
    );
  }
}