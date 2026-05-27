import 'design_etiqueta_v2_model.dart';
import 'etiqueta_layout_preset.dart';
import 'design_validacao_v2_model.dart';

class DesignEtiquetaV2Limiter {
  static DesignValidationV2Result validate(DesignEtiquetaV2Model config) {
    final campos = [...config.campos]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final visiveis = campos.where((c) => c.visivel).toList();

    final infoCampos = visiveis.where((campo) {
      if (campo.tipo == CampoDesignV2Tipo.qrcode) return false;
      if (campo.tipo == CampoDesignV2Tipo.blocoEmpresa) return false;
      if (campo.tipo == CampoDesignV2Tipo.produto) return false;
      if (campo.tipo == CampoDesignV2Tipo.imagem) return false;
      if (campo.tipo == CampoDesignV2Tipo.tabelaNutricional) return false;
      return true;
    }).toList();

    final rules = _rulesForPreset(config.preset, config.tamanhoFonte);

    final blocking = <String>[];

    if (visiveis.any((c) => c.id == 'empresa') && !rules.showEmpresa) {
      blocking.add('Dados da empresa');
    }

    if (visiveis.any((c) => c.id == 'produto') && !rules.showProduto) {
      blocking.add('Nome do produto');
    }

    if (infoCampos.length > rules.maxInfoFields) {
      final excesso = infoCampos.skip(rules.maxInfoFields).map((e) => e.nome);
      blocking.addAll(excesso);
    }

    for (final campo in infoCampos.take(rules.maxInfoFields)) {
      final sampleText = _sampleTextForCampo(campo);
      final maxChars = _maxCharsForCampo(campo, config.preset);

      if (sampleText.length > maxChars) {
        blocking.add(campo.nome);
      }
    }

    final usedHeight = _estimatedUsedHeightMm(
      config: config,
      visibleInfoCount: infoCampos.length,
    );

    final availableHeight = config.alturaMm;

    if (blocking.isNotEmpty || usedHeight > availableHeight) {
      return DesignValidationV2Result.invalid(
        message: _buildValidationMessage(blocking),
        usedHeight: usedHeight,
        availableHeight: availableHeight,
        visibleCount: visiveis.length,
        maxVisibleCount: rules.maxInfoFields,
        blockingFields: blocking,
      );
    }

    return DesignValidationV2Result.valid(
      usedHeight: usedHeight,
      availableHeight: availableHeight,
      visibleCount: visiveis.length,
      maxVisibleCount: rules.maxInfoFields,
    );
  }

  static double _fontHeightFactor(TamanhoFonteEtiqueta tamanho) {
    switch (tamanho) {
      case TamanhoFonteEtiqueta.pequena:
        return 0.9;
      case TamanhoFonteEtiqueta.media:
        return 1.0;
      case TamanhoFonteEtiqueta.grande:
        return 1.25;
    }
  }

  static _EtiquetaPresetRules _rulesForPreset(
    EtiquetaLayoutPreset preset,
    TamanhoFonteEtiqueta tamanhoFonte,
  ) {
    switch (preset) {
      case EtiquetaLayoutPreset.mm60x40:
        switch (tamanhoFonte) {
          case TamanhoFonteEtiqueta.pequena:
            return const _EtiquetaPresetRules(maxInfoFields: 9, showEmpresa: true, showProduto: true);
          case TamanhoFonteEtiqueta.media:
            return const _EtiquetaPresetRules(maxInfoFields: 7, showEmpresa: true, showProduto: true);
          case TamanhoFonteEtiqueta.grande:
            return const _EtiquetaPresetRules(maxInfoFields: 5, showEmpresa: true, showProduto: true);
        }

      case EtiquetaLayoutPreset.mm100x80:
        switch (tamanhoFonte) {
          case TamanhoFonteEtiqueta.pequena:
            return const _EtiquetaPresetRules(maxInfoFields: 10, showEmpresa: true, showProduto: true);
          case TamanhoFonteEtiqueta.media:
            return const _EtiquetaPresetRules(maxInfoFields: 9, showEmpresa: true, showProduto: true);
          case TamanhoFonteEtiqueta.grande:
            return const _EtiquetaPresetRules(maxInfoFields: 7, showEmpresa: true, showProduto: true);
        }
    }
  }

  static int _maxCharsForCampo(
    CampoDesignEtiquetaV2Model campo,
    EtiquetaLayoutPreset preset,
  ) {
    switch (preset) {
      case EtiquetaLayoutPreset.mm60x40:
        if (campo.id == 'ingredientes' ||
            campo.id == 'alergenicos' ||
            campo.id == 'observacao') {
          return 42;
        }
        return 28;

      case EtiquetaLayoutPreset.mm100x80:
        if (campo.id == 'ingredientes' ||
            campo.id == 'alergenicos' ||
            campo.id == 'observacao') {
          return 90;
        }
        return 48;
    }
  }

  static double _estimatedUsedHeightMm({
    required DesignEtiquetaV2Model config,
    required int visibleInfoCount,
  }) {
    final factor = _fontHeightFactor(config.tamanhoFonte);

    switch (config.preset) {
      case EtiquetaLayoutPreset.mm60x40:
        return 10 + (visibleInfoCount * 2.6 * factor);

      case EtiquetaLayoutPreset.mm100x80:
        return 25 + (visibleInfoCount * 4.2 * factor);
    }
  }

  static String _buildValidationMessage(List<String> blocking) {
    if (blocking.isEmpty) {
      return 'O layout não cabe neste tamanho de etiqueta.';
    }

    if (blocking.length == 1) {
      return 'O campo "${blocking.first}" não cabe neste tamanho de etiqueta.';
    }

    final lista = blocking.take(3).join(', ');
    return 'Alguns campos não cabem neste tamanho de etiqueta: $lista.';
  }

  static String _sampleTextForCampo(CampoDesignEtiquetaV2Model campo) {
    switch (campo.id) {
      case 'categoria':
        return 'CATEGORIA: Pães';
      case 'fabricacao':
        return 'FABRICAÇÃO: 15/03/2026';
      case 'validade':
        return 'VALIDADE: 22/03/2026';
      case 'setor':
        return 'SETOR: Produção';
      case 'quantidade':
        return 'QUANTIDADE: 2,500 kg';
      case 'lote':
        return 'LOTE: A2D3FD20';
      case 'observacao':
        return 'OBSERVAÇÃO: feito por colaborador';
      case 'preco':
        return 'PREÇO: R\$ 20,00';
      case 'ingredientes':
        return 'INGREDIENTES: farinha de trigo, água e sal';
      case 'alergenicos':
        return 'ALERGÊNICOS: contém glúten';
      default:
        final prefixo = (campo.labelImpresso ?? campo.nome).trim();
        return prefixo.isEmpty ? campo.nome : '$prefixo: EXEMPLO';
    }
  }
}

class _EtiquetaPresetRules {
  final int maxInfoFields;
  final bool showEmpresa;
  final bool showProduto;

  const _EtiquetaPresetRules({
    required this.maxInfoFields,
    required this.showEmpresa,
    required this.showProduto,
  });
}