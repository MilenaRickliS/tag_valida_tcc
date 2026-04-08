import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_model.dart';
import '../../../models/tipo_etiqueta_model.dart';

class DesignEtiquetaDefaultMapper {
  static DesignEtiquetaModel fromTipoEtiqueta(TipoEtiquetaModel tipo) {
    final campos = <CampoDesignEtiquetaModel>[
      CampoDesignEtiquetaModel(
        id: 'empresa',
        nome: 'Dados da empresa',
        tipo: CampoDesignTipo.blocoEmpresa,
        obrigatorio: false,
        visivel: true,
        fontSize: 7,
        isBold: true,
        align: TextAlign.left,
        ordem: 0,
      ),

      CampoDesignEtiquetaModel(
        id: 'produto',
        nome: 'Nome do produto',
        tipo: CampoDesignTipo.produto,
        obrigatorio: true,
        visivel: true,
        fontSize: 15,
        isBold: true,
        align: TextAlign.left,
        ordem: 1,
      ),

      CampoDesignEtiquetaModel(
        id: 'fabricacao',
        nome: 'Data de fabricação',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'FABRICAÇÃO',
        obrigatorio: true,
        visivel: true,
        fontSize: 8,
        isBold: true,
        align: TextAlign.left,
        ordem: 2,
      ),

      CampoDesignEtiquetaModel(
        id: 'validade',
        nome: 'Data de validade',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'VALIDADE',
        obrigatorio: true,
        visivel: true,
        fontSize: 9,
        isBold: true,
        align: TextAlign.left,
        ordem: 3,
      ),

      CampoDesignEtiquetaModel(
        id: 'categoria',
        nome: 'Categoria',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'CATEGORIA',
        obrigatorio: false,
        visivel: true,
        fontSize: 8,
        isBold: true,
        align: TextAlign.left,
        ordem: 4,
      ),

      CampoDesignEtiquetaModel(
        id: 'setor',
        nome: 'Setor',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'SETOR',
        obrigatorio: false,
        visivel: true,
        fontSize: 8,
        isBold: true,
        align: TextAlign.left,
        ordem: 5,
      ),

      CampoDesignEtiquetaModel(
        id: 'quantidade',
        nome: 'Quantidade',
        tipo: CampoDesignTipo.info,
        labelImpresso: 'QUANTIDADE',
        obrigatorio: false,
        visivel: true,
        fontSize: 8,
        isBold: true,
        align: TextAlign.left,
        ordem: 6,
      ),
    ];

    if (tipo.controlaLote) {
      campos.add(
        CampoDesignEtiquetaModel(
          id: 'lote',
          nome: 'Lote',
          tipo: CampoDesignTipo.info,
          labelImpresso: 'LOTE',
          obrigatorio: false,
          visivel: true,
          fontSize: 8,
          isBold: true,
          align: TextAlign.left,
          ordem: campos.length,
        ),
      );
    }

    for (final campoCustom in tipo.camposCustom) {
      final safeId = campoCustom.label
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      campos.add(
        CampoDesignEtiquetaModel(
          id: 'custom_$safeId',
          nome: campoCustom.label,
          tipo: campoCustom.tipo == CampoTipo.image
              ? CampoDesignTipo.imagem
              : CampoDesignTipo.extras,
          obrigatorio: false,
          visivel: true,
          fontSize: campoCustom.tipo == CampoTipo.image ? 8 : 7,
          isBold: false,
          align: TextAlign.left,
          ordem: campos.length,
        ),
      );
    }

    if (tipo.permiteTabelaNutricional) {
      campos.add(
        CampoDesignEtiquetaModel(
          id: 'tabela_nutricional',
          nome: 'Tabela nutricional',
          tipo: CampoDesignTipo.extras,
          obrigatorio: false,
          visivel: false,
          fontSize: 7,
          isBold: false,
          align: TextAlign.left,
          ordem: campos.length,
        ),
      );
    }

    campos.add(
      CampoDesignEtiquetaModel(
        id: 'qrcode',
        nome: 'QR Code',
        tipo: CampoDesignTipo.qrcode,
        obrigatorio: false,
        visivel: true,
        fontSize: 8,
        isBold: false,
        align: TextAlign.right,
        ordem: campos.length,
      ),
    );

    return DesignEtiquetaModel(
      tipoEtiquetaId: tipo.id,
      tipoEtiquetaNome: tipo.nome,
      larguraMm: 60,
      alturaMm: 40,
      mostrarMarcaTagValida: true,
      destacarValidade: true,
      campos: campos,
    );
  }
}