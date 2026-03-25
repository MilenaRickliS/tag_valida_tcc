// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import 'package:fl_chart/fl_chart.dart';

class TopSoldBarChart extends StatelessWidget {
  final List<EstoqueMovModel> movs;
  const TopSoldBarChart({super.key, required this.movs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final map = <String, num>{};
    for (final m in movs) {
      if (m.tipo != EstoqueMovModel.tipoVenda) continue;
      final name = (m.produtoNome?.trim().isNotEmpty ?? false)
          ? m.produtoNome!.trim()
          : 'Sem nome';
      map[name] = (map[name] ?? 0) + m.quantidade;
    }

    final list = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = list.take(6).toList();

    if (top.isEmpty) {
      return const Center(child: Text('Sem vendas no período'));
    }

    final rodColor = RelatorioCores.solid(EstoqueMovModel.tipoVenda);
    final axisColor = isDark ? Colors.white70 : Colors.black87;
    final gridColor = isDark ? Colors.white12 : Colors.black12;

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) {
          return FlLine(color: gridColor, strokeWidth: 1);
        }),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: axisColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= top.length) return const SizedBox.shrink();
                final name = top[i].key;
                final short =
                    name.length > 10 ? '${name.substring(0, 10)}…' : name;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    short,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: axisColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(top.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: top[i].value.toDouble(),
                width: 16,
                color: rodColor,
                borderRadius: BorderRadius.circular(8),
              )
            ],
          );
        }),
      ),
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