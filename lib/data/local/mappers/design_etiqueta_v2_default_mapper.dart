import 'package:flutter/material.dart';

import '../../../../models/design_etiqueta_v2_model.dart';
import '../../../../models/tipo_etiqueta_model.dart';
import '../../../models/etiqueta_layout_preset.dart';

class DesignEtiquetaV2DefaultMapper {
  static DesignEtiquetaV2Model fromTipoEtiqueta(
    TipoEtiquetaModel tipo, {
    EtiquetaLayoutPreset preset = EtiquetaLayoutPreset.mm60x40,
  }) {
    final campos = <CampoDesignEtiquetaV2Model>[
      _campo(
        id: 'empresa',
        nome: 'Dados da empresa',
        tipo: CampoDesignV2Tipo.blocoEmpresa,
        obrigatorio: false,
        visivel: true,
        isBold: true,
        ordem: 0,
      ),
      _campo(
        id: 'produto',
        nome: 'Nome do produto',
        tipo: CampoDesignV2Tipo.produto,
        obrigatorio: true,
        visivel: true,
        isBold: true,
        ordem: 1,
      ),
      _campo(
        id: 'fabricacao',
        nome: 'Data de fabricação',
        tipo: CampoDesignV2Tipo.info,
        labelImpresso: 'FABRICAÇÃO',
        obrigatorio: true,
        visivel: true,
        isBold: true,
        ordem: 2,
      ),
      _campo(
        id: 'validade',
        nome: 'Data de validade',
        tipo: CampoDesignV2Tipo.info,
        labelImpresso: 'VALIDADE',
        obrigatorio: true,
        visivel: true,
        isBold: true,
        ordem: 3,
      ),
      _campo(
        id: 'categoria',
        nome: 'Categoria',
        tipo: CampoDesignV2Tipo.info,
        labelImpresso: 'CATEGORIA',
        visivel: true,
        isBold: true,
        ordem: 4,
      ),
      _campo(
        id: 'setor',
        nome: 'Setor',
        tipo: CampoDesignV2Tipo.info,
        labelImpresso: 'SETOR',
        visivel: true,
        isBold: true,
        ordem: 5,
      ),
      _campo(
        id: 'quantidade',
        nome: 'Quantidade',
        tipo: CampoDesignV2Tipo.info,
        labelImpresso: 'QUANTIDADE',
        visivel: true,
        isBold: true,
        ordem: 6,
      ),
    ];

    if (tipo.controlaLote) {
      campos.add(
        _campo(
          id: 'lote',
          nome: 'Lote',
          tipo: CampoDesignV2Tipo.info,
          labelImpresso: 'LOTE',
          visivel: true,
          isBold: true,
          ordem: campos.length,
        ),
      );
    }

    for (final campoCustom in tipo.camposCustom) {
      final safeId = _safeId(campoCustom.label);

      campos.add(
        _campo(
          id: 'custom_$safeId',
          nome: campoCustom.label,
          tipo: campoCustom.tipo == CampoTipo.image
              ? CampoDesignV2Tipo.imagem
              : CampoDesignV2Tipo.extras,
          visivel: true,
          isBold: false,
          ordem: campos.length,
        ),
      );
    }

    if (tipo.permiteTabelaNutricional) {
      campos.add(
        _campo(
          id: 'tabela_nutricional',
          nome: 'Tabela nutricional',
          tipo: CampoDesignV2Tipo.extras,
          visivel: false,
          isBold: false,
          ordem: campos.length,
        ),
      );
    }

    campos.add(
      _campo(
        id: 'qrcode',
        nome: 'QR Code',
        tipo: CampoDesignV2Tipo.qrcode,
        visivel: true,
        align: TextAlign.right,
        ordem: campos.length,
      ),
    );

    return DesignEtiquetaV2Model(
      tipoEtiquetaId: tipo.id,
      tipoEtiquetaNome: tipo.nome,
      preset: preset,
      mostrarMarcaTagValida: true,
      tamanhoFonte: TamanhoFonteEtiqueta.media,
      destacarValidade: true,
      campos: campos,
    );
  }

  static CampoDesignEtiquetaV2Model _campo({
    required String id,
    required String nome,
    required CampoDesignV2Tipo tipo,
    String? labelImpresso,
    bool obrigatorio = false,
    bool visivel = true,
    bool isBold = false,
    TextAlign align = TextAlign.left,
    required int ordem,
  }) {
    return CampoDesignEtiquetaV2Model(
      id: id,
      nome: nome,
      tipo: tipo,
      labelImpresso: labelImpresso,
      obrigatorio: obrigatorio,
      visivel: obrigatorio ? true : visivel,
      isBold: isBold,
      align: align,
      ordem: ordem,
    );
  }

  static String _safeId(String label) {
    return label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}