// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_layout_preset.dart';
import '../../../utils/preview_align_utils_v2.dart';
import 'validade_v2.dart';
import 'preview_font_size_v2.dart';

Widget buildLinhaInfoV2(
  CampoDesignEtiquetaV2Model campo, {
  required DesignEtiquetaV2Model config,
}) {
  final valor = getValorExemploLinhaV2(campo);
  final previewFont = _previewFontForCampoV2(campo, config);
  final label = (campo.labelImpresso ?? campo.nome).toUpperCase();

  if (campo.id == 'validade') {
    return Align(
      alignment: toAlignmentV2(campo.align),
      child: buildValidadeTermicaV2(
        valor: valor,
        destacar: config.destacarValidade,
        status: StatusValidadePreviewV2.vencido,
        fontSize: previewFont,
        align: campo.align,
        isBold: campo.isBold,
      ),
    );
  }

  return Align(
    alignment: toAlignmentV2(campo.align),
    child: RichText(
      textAlign: campo.align,
      maxLines: _maxLinesForCampoV2(campo),
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: previewFont,
          color: Colors.black,
          height: config.preset == EtiquetaLayoutPreset.mm60x40 ? 0.94 : 1.0,
          fontWeight: campo.isBold ? FontWeight.w600 : FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontWeight: campo.isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          TextSpan(
            text: valor,
            style: TextStyle(
              fontWeight: campo.isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

double _previewFontForCampoV2(
  CampoDesignEtiquetaV2Model campo,
  DesignEtiquetaV2Model config,
) {
  double base;

  switch (config.preset) {
    case EtiquetaLayoutPreset.mm60x40:
      if (campo.id == 'validade') {
        base = 16.0;
      } else if (campo.id == 'observacao' ||
          campo.id == 'ingredientes' ||
          campo.id == 'alergenicos') {
        base = 14.0;
      } else {
        base = 15.0;
      }
      break;

    case EtiquetaLayoutPreset.mm100x80:
      if (campo.id == 'validade') {
        base = 11.0;
      } else if (campo.id == 'observacao' ||
          campo.id == 'ingredientes' ||
          campo.id == 'alergenicos') {
        base = 10.5;
      } else {
        base = 10.8;
      }
      break;
  }

  return base * previewFontFactorV2(config.tamanhoFonte);
}

int _maxLinesForCampoV2(CampoDesignEtiquetaV2Model campo) {
  if (campo.id == 'ingredientes' || campo.id == 'alergenicos') {
    return 4;
  }

  if (campo.id == 'observacao') {
    return 3;
  }

  return 1;
}

String getValorExemploLinhaV2(CampoDesignEtiquetaV2Model campo) {
  switch (campo.id) {
    case 'empresa':
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90';
    case 'produto':
      return 'Pão Francês';
    case 'fabricacao':
      return '12/02/2025';
    case 'validade':
      return '12/02/2025';
    case 'categoria':
      return 'Pães';
    case 'setor':
      return 'Produção';
    case 'quantidade':
      return '2,500 kg';
    case 'lote':
      return 'A2D3FD20';
    case 'observacao':
      return 'feito por alice';
    case 'preco':
      return '20,00';
    case 'ingredientes':
      return 'farinha de trigo, água e sal';
    case 'alergenicos':
      return 'contém glúten';
    case 'contem_gluten':
      return 'Sim';
    case 'contem_lactose':
      return 'Sim';
    case 'texto':
      return 'Exemplo';
    case 'numero':
      return '12';
    case 'data':
      return '12/02/2025';
    default:
      if (campo.tipo == CampoDesignV2Tipo.imagem) {
        return 'Imagem do produto';
      }
      return campo.valorExemplo ?? campo.nome;
  }
}