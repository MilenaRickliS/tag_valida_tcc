// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';

class TipoChip extends StatelessWidget {
  final String tipo;
  const TipoChip({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final fg = TipoColors.fg(tipo);
    final bg = TipoColors.bg(tipo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        tipo,
        style: TextStyle(fontWeight: FontWeight.w900, color: fg, fontSize: 12),
      ),
    );
  }
}

class TipoColors {
  static Color fg(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return Colors.green.shade800;
      case EstoqueMovModel.tipoVenda:
        return Colors.orange.shade800;
      case EstoqueMovModel.tipoCancelamento:
        return Colors.red.shade800;
      case EstoqueMovModel.tipoAjusteEntrada:
        return Colors.blue.shade800;
      case EstoqueMovModel.tipoAjusteSaida:
        return Colors.purple.shade800;
      case EstoqueMovModel.tipoExclusao:
        return Colors.red.shade900;
      default:
        return Colors.black87;
    }
  }

  static Color bg(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return Colors.green.withOpacity(0.10);
      case EstoqueMovModel.tipoVenda:
        return Colors.orange.withOpacity(0.10);
      case EstoqueMovModel.tipoCancelamento:
        return Colors.red.withOpacity(0.10);
      case EstoqueMovModel.tipoAjusteEntrada:
        return Colors.blue.withOpacity(0.10);
      case EstoqueMovModel.tipoAjusteSaida:
        return Colors.purple.withOpacity(0.10);
      case EstoqueMovModel.tipoExclusao:
        return Colors.red.withOpacity(0.08);
      default:
        return Colors.black.withOpacity(0.06);
    }
  }
}