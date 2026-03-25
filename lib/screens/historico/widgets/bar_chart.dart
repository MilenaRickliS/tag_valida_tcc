// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BarItem {
  final String label;
  final double value;
  final Color color;
  BarItem({required this.label, required this.value, required this.color});
}

class BarChart extends StatelessWidget {
  final List<BarItem> items;
  const BarChart({super.key, required this.items});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final muted =
        _isDark(context) ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.55);

    if (items.isEmpty) {
      return Center(
        child: Text(
          "Sem dados para o período/filtros.",
          style: TextStyle(color: muted),
        ),
      );
    }

    final maxV =
        items.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;

    return LayoutBuilder(
      builder: (context, c) {
        final barW = (c.maxWidth / items.length).clamp(34.0, 86.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: barW * items.length,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items.map((e) {
                final ratio = (e.value / safeMax).clamp(0.0, 1.0);
                final fill = e.color.withOpacity(0.18);
                final border = e.color.withOpacity(0.40);
                final labelColor = e.color.withOpacity(0.95);

                return SizedBox(
                  width: barW,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 18,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            e.value % 1 == 0
                                ? e.value.toInt().toString()
                                : e.value.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _isDark(context)
                                  ? Colors.white70
                                  : Colors.black.withOpacity(0.70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            widthFactor: 0.62,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: fill,
                                border: Border.all(color: border),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            e.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}