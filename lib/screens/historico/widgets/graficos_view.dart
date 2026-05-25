// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './chart_card.dart';
import 'bar_chart.dart';
import 'tipo_chip.dart';

class MovStats {
  final Map<String, double> byTipoUn;
  final Map<String, double> byTipoKg;
  final Map<String, int> byDay;

  MovStats({
    required this.byTipoUn,
    required this.byTipoKg,
    required this.byDay,
  });

  static MovStats fromMovs(List<EstoqueMovModel> all) {
    final tipoUn = <String, double>{};
    final tipoKg = <String, double>{};
    final day = <String, int>{};

    String two(int v) => v.toString().padLeft(2, '0');
    String dayKey(DateTime d) => "${two(d.day)}/${two(d.month)}";

    for (final m in all) {
      final unidade = m.unidadeMedida.trim().isEmpty ? 'un' : m.unidadeMedida;
      final k = dayKey(m.createdAt);

      day[k] = (day[k] ?? 0) + 1;

      if (unidade == 'kg') {
        tipoKg[m.tipo] = (tipoKg[m.tipo] ?? 0) + m.quantidade.toDouble();
      } else {
        tipoUn[m.tipo] = (tipoUn[m.tipo] ?? 0) + m.quantidade.toDouble();
      }
    }

    Map<String, double> sortMap(Map<String, double> map) {
      final keys = map.keys.toList()
        ..sort((a, b) => (map[b] ?? 0).compareTo(map[a] ?? 0));

      return {
        for (final k in keys) k: map[k]!,
      };
    }

    final sortedDayKeys = day.keys.toList()
      ..sort((a, b) {
        int toNum(String s) {
          final parts = s.split('/');
          final dd = int.tryParse(parts[0]) ?? 0;
          final mm = int.tryParse(parts[1]) ?? 0;
          return mm * 100 + dd;
        }

        return toNum(a).compareTo(toNum(b));
      });

    final daySorted = {
      for (final k in sortedDayKeys) k: day[k]!,
    };

    return MovStats(
      byTipoUn: sortMap(tipoUn),
      byTipoKg: sortMap(tipoKg),
      byDay: daySorted,
    );
  }
}

class GraficosView extends StatelessWidget {
  final MovStats stats;
  const GraficosView({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey("graficos"),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 860;

          final cards = <Widget>[
            ChartCard(
              title: "Volume por tipo (un)",
              subtitle: "Soma das quantidades em unidade.",
              child: BarChart(
                items: stats.byTipoUn.entries
                    .map((e) => BarItem(
                          label: e.key,
                          value: e.value,
                          color: TipoColors.fg(e.key),
                        ))
                    .toList(),
              ),
            ),

            ChartCard(
              title: "Volume por tipo (kg)",
              subtitle: "Soma das quantidades em quilos.",
              child: BarChart(
                items: stats.byTipoKg.entries
                    .map((e) => BarItem(
                          label: e.key,
                          value: e.value,
                          color: TipoColors.fg(e.key),
                        ))
                    .toList(),
              ),
            ),

            ChartCard(
              title: "Movimentações por dia",
              subtitle: "Quantidade de registros por data.",
              child: BarChart(
                items: stats.byDay.entries
                    .map((e) => BarItem(
                          label: e.key,
                          value: e.value.toDouble(),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFD4AF37)
                              : Colors.black87,
                        ))
                    .toList(),
              ),
            ),
          ];

          if (narrow) {
            return ListView.separated(
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => cards[i],
            );
          }

          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
            ],
          );
        },
      ),
    );
  }
}