// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';
import './top_sold_bar_chart.dart';

class ChartOnlyBar extends StatelessWidget {
  final List<EstoqueMovModel> movs;
  const ChartOnlyBar({super.key, required this.movs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7D8C2)),
      ),
      child: SizedBox(height: 260, child: TopSoldBarChart(movs: movs)),
    );
  }
}