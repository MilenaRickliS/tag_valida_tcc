// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './top_sold_bar_chart.dart';
import './section_card.dart';
import 'package:fl_chart/fl_chart.dart';


class ChartsRow extends StatelessWidget {
  final GlobalKey pieKey;
  final GlobalKey barKey;
  final List<EstoqueMovModel> movs;

  const ChartsRow({super.key, 
    required this.pieKey,
    required this.barKey,
    required this.movs,
  });

  @override
  Widget build(BuildContext context) {
    final byType = <String, num>{};
    for (final m in movs) {
      byType[m.tipo] = (byType[m.tipo] ?? 0) + m.quantidade;
    }

    final total = byType.values.fold<num>(0, (a, b) => a + b);
    final entries = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;

        final pieCard = SectionCard(
          title: 'Distribuição por tipo',
          child: RepaintBoundary(
            key: pieKey,
            child: SizedBox(
              height: 240,
              child: total == 0
                  ? const Center(child: Text('Sem dados no período'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 48,
                        sections: List.generate(entries.length, (i) {
                          final e = entries[i];
                          final pct = total == 0 ? 0 : (e.value / total * 100);
                          final color = RelatorioCores.solid(e.key);
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            title: '${e.key}\n${pct.toStringAsFixed(0)}%',
                            radius: 78,
                            color: color,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
            ),
          ),
        );

        final barCard = SectionCard(
          title: 'Top vendidos (barras)',
          child: RepaintBoundary(
            key: barKey,
            child: SizedBox(height: 240, child: TopSoldBarChart(movs: movs)),
          ),
        );

        if (isNarrow) {
          return Column(
            children: [pieCard, const SizedBox(height: 12), barCard],
          );
        }

        return Row(
          children: [
            Expanded(child: pieCard),
            const SizedBox(width: 12),
            Expanded(child: barCard),
          ],
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
