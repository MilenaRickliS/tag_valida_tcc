// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import 'package:intl/intl.dart';

class MovList extends StatelessWidget {
  final List<EstoqueMovModel> movs;
  const MovList({super.key, required this.movs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.65);

    if (movs.isEmpty) return const Text('Sem movimentações no período.');

    final df = DateFormat('dd/MM HH:mm');

    return Column(
      children: movs.map((m) {
        final produto = (m.produtoNome?.trim().isNotEmpty ?? false)
            ? m.produtoNome!.trim()
            : 'Sem nome';
        final bg = RelatorioCores.bg(m.tipo);
        final fg = RelatorioCores.fg(m.tipo);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fg.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: fg.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForTipo(m.tipo), color: fg, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${df.format(m.createdAt)} • ${m.tipo} • ${m.motivo ?? ""}',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                (m.quantidade % 1 == 0)
                    ? m.quantidade.toInt().toString()
                    : m.quantidade.toStringAsFixed(2),
                style: TextStyle(fontWeight: FontWeight.w900, color: fg),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return Icons.add_circle_outline;
      case EstoqueMovModel.tipoVenda:
        return Icons.shopping_cart_outlined;
      case EstoqueMovModel.tipoCancelamento:
        return Icons.cancel_outlined;
      case EstoqueMovModel.tipoExclusao:
        return Icons.delete_outline;
      default:
        try {
          if (tipo == EstoqueMovModel.tipoAjusteEntrada) return Icons.tune;
        } catch (_) {}
        try {
          if (tipo == EstoqueMovModel.tipoAjusteSaida) return Icons.tune;
        } catch (_) {}
        return Icons.analytics_outlined;
    }
  }
}

class RelatorioCores {
  static Color bg(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return Colors.green.withOpacity(0.10);
      case EstoqueMovModel.tipoVenda:
        return Colors.orange.withOpacity(0.10);
      case EstoqueMovModel.tipoCancelamento:
        return Colors.red.withOpacity(0.10);
      case EstoqueMovModel.tipoExclusao:
        return Colors.red.withOpacity(0.08);
      default:
        try {
          if (tipo == EstoqueMovModel.tipoAjusteEntrada) {
            return Colors.blue.withOpacity(0.10);
          }
        } catch (_) {}
        try {
          if (tipo == EstoqueMovModel.tipoAjusteSaida) {
            return Colors.purple.withOpacity(0.10);
          }
        } catch (_) {}
        return Colors.black.withOpacity(0.06);
    }
  }

  static Color fg(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return const Color(0xff2e7d32);
      case EstoqueMovModel.tipoVenda:
        return const Color(0xffef6c00);
      case EstoqueMovModel.tipoCancelamento:
        return const Color(0xffc62828);
      case EstoqueMovModel.tipoExclusao:
        return const Color(0xffc62828);
      default:
        try {
          if (tipo == EstoqueMovModel.tipoAjusteEntrada) {
            return const Color(0xff1565c0);
          }
        } catch (_) {}
        try {
          if (tipo == EstoqueMovModel.tipoAjusteSaida) {
            return const Color(0xff6a1b9a);
          }
        } catch (_) {}
        return Colors.black87;
    }
  }

  static Color solid(String tipo) => fg(tipo);
}