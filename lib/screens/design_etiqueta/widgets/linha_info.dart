 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';

Widget buildLinhaInfo(CampoDesignEtiquetaModel campo) {
  final valor = getValorExemplo(campo);

  return Align(
    alignment: toAlignment(campo.align),
    child: RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: campo.fontSize.clamp(10, 18),
        color: Colors.black87,
        height: 1.25,
      ),
      children: [
        TextSpan(
          text: '${campo.labelImpresso ?? campo.nome}: ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: valor,
          style: TextStyle(
            fontWeight: campo.isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    ),
    maxLines: campo.id == 'ingredientes' || campo.id == 'alergenicos' ? 3 : 1,
    overflow: TextOverflow.ellipsis,
  
    ),
  );

}

 String exampleValue(String id, String nome) {
  switch (id) {
    case 'empresa':
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90\nRua Exemplo, 123';
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
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90\nRua Exemplo, 123';
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


