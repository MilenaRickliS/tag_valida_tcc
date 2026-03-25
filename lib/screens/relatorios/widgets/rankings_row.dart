// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './rank_list.dart';
import './section_card.dart';
import '../models/named_value.dart';


class RankingsRow extends StatelessWidget {
  final List<NamedValue> topSold;
  final List<NamedValue> topLost;

  const RankingsRow({super.key, required this.topSold, required this.topLost});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;

        final soldCard = SectionCard(
          title: 'Top 5 vendidos',
          child: RankList(items: topSold, tipo: EstoqueMovModel.tipoVenda),
        );

        final lostCard = SectionCard(
          title: 'Top 5 perdas',
          child: RankList(items: topLost, tipo: EstoqueMovModel.tipoExclusao),
        );

        if (isNarrow) {
          return Column(
            children: [soldCard, const SizedBox(height: 12), lostCard],
          );
        }
        return Row(
          children: [
            Expanded(child: soldCard),
            const SizedBox(width: 12),
            Expanded(child: lostCard),
          ],
        );
      },
    );
  }
}
