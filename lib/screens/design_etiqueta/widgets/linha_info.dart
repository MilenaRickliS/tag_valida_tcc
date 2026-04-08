// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './validade.dart';

Widget buildLinhaInfo(CampoDesignEtiquetaModel campo, {required bool destacarValidade,}) {
  final valor = getValorExemplo(campo);

  if (campo.id == 'validade') {
    return Align(
      alignment: toAlignment(campo.align),
      child: buildValidadeTermica(
        valor: valor,
        destacar: destacarValidade,
        // StatusValidadePreview.normal
        // StatusValidadePreview.alerta
        // StatusValidadePreview.vencido
        status: StatusValidadePreview.vencido,
        fontSize: campo.fontSize.clamp(9, 11).toDouble(),
        align: campo.align,
        isBold: campo.isBold,
      ),
    );
  }

  return Align(
    alignment: toAlignment(campo.align),
    child: RichText(
      textAlign: campo.align,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: campo.fontSize.clamp(9, 11).toDouble(),
          color: Colors.black,
          height: 1.05,
          fontWeight: campo.isBold ? FontWeight.w600 : FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: '${campo.labelImpresso ?? campo.nome}: ',
            style: TextStyle(
              fontWeight: campo.isBold ? FontWeight.w800 : FontWeight.w500,
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
      maxLines:
          campo.id == 'ingredientes' || campo.id == 'alergenicos' ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}


String exampleValue(String id, String nome) {
  switch (id) {
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
      return '20';
    case 'lote':
      return 'A2D3FD20';
    case 'observacao':
      return 'feito por alice';
    case 'preco':
      return '20,00';
    case 'ingredientes':
      return 'farinha de trigo, amido, creme, sal';
    case 'alergenicos':
      return 'farinha de trigo, creme de leite';
    case 'contem_gluten':
      return 'Sim';
    case 'contem_lactose':
      return 'Sim';
    case 'tabela_nutricional':
      return 'Tabela nutricional';
    case 'texto':
      return 'sdsad';
    case 'numero':
      return '12';
    case 'data':
      return '12/02/2025';
    default:
      return nome;
  }
}

String getValorExemplo(CampoDesignEtiquetaModel campo) {
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
      return '20';
    case 'lote':
      return 'A2D3FD20';
    case 'observacao':
      return 'feito por alice';
    case 'preco':
      return '20,00';
    case 'ingredientes':
      return 'farinha de trigo, amido, creme, sal, fds, sdkasl, saskdjsak';
    case 'alergenicos':
      return 'farinha de trigo, amido, creme de leite';
    case 'contem_gluten':
      return 'Sim';
    case 'contem_lactose':
      return 'Sim';
    case 'texto':
      return 'sdsad';
    case 'numero':
      return '12';
    case 'data':
      return '12/02/2025';
    case 'tabela_nutricional':
      return 'Tabela nutricional';
    default:
      if (campo.tipo == CampoDesignTipo.imagem) {
        return 'Imagem do produto';
      }
      return campo.nome;
  }
}

Alignment toAlignment(TextAlign align) {
  switch (align) {
    case TextAlign.center:
      return Alignment.center;
    case TextAlign.right:
      return Alignment.centerRight;
    case TextAlign.left:
    default:
      return Alignment.centerLeft;
  }
}

CrossAxisAlignment toCrossAxis(TextAlign align) {
  switch (align) {
    case TextAlign.center:
      return CrossAxisAlignment.center;
    case TextAlign.right:
      return CrossAxisAlignment.end;
    case TextAlign.left:
    default:
      return CrossAxisAlignment.start;
  }
}
