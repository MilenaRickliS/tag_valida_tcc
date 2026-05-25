// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './top_sold_bar_chart.dart';
import './section_card.dart';
import './chart_only_pie.dart';


class ChartsRow extends StatelessWidget {
  final GlobalKey pieKey;
  final GlobalKey barKey;
  final List<EstoqueMovModel> movs;

  const ChartsRow({
    super.key,
    required this.pieKey,
    required this.barKey,
    required this.movs,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;

        final pieUnCard = SectionCard(
          title: 'Distribuição por tipo (un)',
          child: RepaintBoundary(
            key: pieKey,
            child: ChartOnlyPie(
              movs: movs,
              unidade: 'un',
            ),
          ),
        );

        final pieKgCard = SectionCard(
          title: 'Distribuição por tipo (kg)',
          child: ChartOnlyPie(
            movs: movs,
            unidade: 'kg',
          ),
        );

        final barUnCard = SectionCard(
          title: 'Top vendidos (un)',
          child: RepaintBoundary(
            key: barKey,
            child: SizedBox(
              height: 240,
              child: TopSoldBarChart(
                movs: movs,
                unidade: 'un',
              ),
            ),
          ),
        );

        final barKgCard = SectionCard(
          title: 'Top vendidos (kg)',
          child: SizedBox(
            height: 240,
            child: TopSoldBarChart(
              movs: movs,
              unidade: 'kg',
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            children: [
              pieUnCard,
              const SizedBox(height: 12),
              pieKgCard,
              const SizedBox(height: 12),
              barUnCard,
              const SizedBox(height: 12),

              barKgCard,
            ],
          );
        }

        return Column(
          children: [
             Row(
                children: [
                  Expanded(child: pieUnCard),
                  const SizedBox(width: 12),
                  Expanded(child: pieKgCard),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: barUnCard),
                  const SizedBox(width: 12),
                  Expanded(child: barKgCard),
                ],
              ),
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
