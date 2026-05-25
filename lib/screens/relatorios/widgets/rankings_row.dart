// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './rank_list.dart';
import './section_card.dart';
import '../models/named_value.dart';


class RankingsRow extends StatelessWidget {
  final List<NamedValue> topSoldUn;
  final List<NamedValue> topSoldKg;

  final List<NamedValue> topLostUn;
  final List<NamedValue> topLostKg;

  const RankingsRow({
    super.key,
    required this.topSoldUn,
    required this.topSoldKg,
    required this.topLostUn,
    required this.topLostKg,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;

        final cards = [
          SectionCard(
            title: 'Top vendidos (un)',
            child: RankList(
              items: topSoldUn,
              tipo: EstoqueMovModel.tipoVenda,
              unidade: 'un',
            ),
          ),
          SectionCard(
            title: 'Top vendidos (kg)',
            child: RankList(
              items: topSoldKg,
              tipo: EstoqueMovModel.tipoVenda,
              unidade: 'kg',
            ),
          ),
          SectionCard(
            title: 'Top perdas (un)',
            child: RankList(
              items: topLostUn,
              tipo: EstoqueMovModel.tipoExclusao,
              unidade: 'un',
            ),
          ),
          SectionCard(
            title: 'Top perdas (kg)',
            child: RankList(
              items: topLostKg,
              tipo: EstoqueMovModel.tipoExclusao,
              unidade: 'kg',
            ),
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              for (final card in cards) ...[
                card,
                const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}