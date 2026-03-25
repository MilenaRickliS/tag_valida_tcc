// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './kpi_card.dart';

class KpiGrid extends StatelessWidget {
  final Map<String, num> kpis;
  const KpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final entries = kpis.entries.toList();

    String tipoForLabel(String label) {
      switch (label) {
        case 'Entradas':
          return EstoqueMovModel.tipoEntrada;
        case 'Vendas':
          return EstoqueMovModel.tipoVenda;
        case 'Cancelamentos':
          return EstoqueMovModel.tipoCancelamento;
        case 'Exclusões':
          return EstoqueMovModel.tipoExclusao;
        case 'Perdas':
          return EstoqueMovModel.tipoExclusao;
        case 'Saldo':
          return EstoqueMovModel.tipoEntrada;
        case 'Ajuste Entrada':
          try {
            return EstoqueMovModel.tipoAjusteEntrada;
          } catch (_) {
            return EstoqueMovModel.tipoEntrada;
          }
        case 'Ajuste Saída':
          try {
            return EstoqueMovModel.tipoAjusteSaida;
          } catch (_) {
            return EstoqueMovModel.tipoCancelamento;
          }
        default:
          return EstoqueMovModel.tipoEntrada;
      }
    }

    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 650 ? 2 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, i) {
            final e = entries[i];
            final tipo = tipoForLabel(e.key);
            return KpiCard(
              label: e.key,
              value: e.value,
              bg: RelatorioCores.bg(tipo),
              fg: RelatorioCores.fg(tipo),
            );
          },
        );
      },
    );
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