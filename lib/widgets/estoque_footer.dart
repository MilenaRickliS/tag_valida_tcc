// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class EstoqueFooter extends StatelessWidget {
  final Map<String, num> entradasPorUnidade;
  final Map<String, num> saidasPorUnidade;
  final Map<String, num> totalPorUnidade;

  const EstoqueFooter({
    super.key,
    required this.entradasPorUnidade,
    required this.saidasPorUnidade,
    required this.totalPorUnidade,
  });

  String _fmt(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(3).replaceAll('.', ',');
  }

  String _fmtMap(Map<String, num> values) {
    if (values.isEmpty) return '0 un';

    final entries = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .map((e) => '${_fmt(e.value)} ${e.key}')
        .join(' • ');
  }

  Widget _pill({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
    required Color fg,
    required Color border,
    bool expand = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: fg.withOpacity(0.90),
                fontSize: 12.5,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: fg,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    if (expand) {
      return Expanded(child: child);
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final entradasText = _fmtMap(entradasPorUnidade);
    final saidasText = _fmtMap(saidasPorUnidade);
    final totalText = _fmtMap(totalPorUnidade);

    final containerBg =
        isDark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.70);

    final containerBorder = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: containerBorder),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 700;

            if (isSmall) {
              return Column(
                children: [
                  _pill(
                    context: context,
                    icon: Icons.input_rounded,
                    label: "Entradas",
                    value: entradasText,
                    bg: isDark
                        ? Colors.green.withOpacity(0.14)
                        : Colors.green.withOpacity(0.08),
                    fg: isDark
                        ? Colors.greenAccent.shade200
                        : Colors.green.shade800,
                    border: isDark
                        ? Colors.greenAccent.withOpacity(0.22)
                        : Colors.green.withOpacity(0.20),
                    expand: false,
                  ),
                  const SizedBox(height: 10),
                  _pill(
                    context: context,
                    icon: Icons.output_rounded,
                    label: "Saídas",
                    value: saidasText,
                    bg: isDark
                        ? Colors.orange.withOpacity(0.14)
                        : Colors.orange.withOpacity(0.08),
                    fg: isDark
                        ? Colors.orangeAccent.shade100
                        : Colors.orange.shade800,
                    border: isDark
                        ? Colors.orangeAccent.withOpacity(0.22)
                        : Colors.orange.withOpacity(0.20),
                    expand: false,
                  ),
                  const SizedBox(height: 10),
                  _pill(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    label: "Total em estoque",
                    value: totalText,
                    bg: isDark
                        ? const Color(0xFFD4AF37).withOpacity(0.12)
                        : Colors.black.withOpacity(0.04),
                    fg: isDark ? const Color(0xFFD4AF37) : Colors.black87,
                    border: isDark
                        ? const Color(0xFFD4AF37).withOpacity(0.22)
                        : Colors.black.withOpacity(0.12),
                    expand: false,
                  ),
                ],
              );
            }

            return Row(
              children: [
                _pill(
                  context: context,
                  icon: Icons.input_rounded,
                  label: "Entradas",
                  value: entradasText,
                  bg: isDark
                      ? Colors.green.withOpacity(0.14)
                      : Colors.green.withOpacity(0.08),
                  fg: isDark
                      ? Colors.greenAccent.shade200
                      : Colors.green.shade800,
                  border: isDark
                      ? Colors.greenAccent.withOpacity(0.22)
                      : Colors.green.withOpacity(0.20),
                ),
                const SizedBox(width: 10),
                _pill(
                  context: context,
                  icon: Icons.output_rounded,
                  label: "Saídas",
                  value: saidasText,
                  bg: isDark
                      ? Colors.orange.withOpacity(0.14)
                      : Colors.orange.withOpacity(0.08),
                  fg: isDark
                      ? Colors.orangeAccent.shade100
                      : Colors.orange.shade800,
                  border: isDark
                      ? Colors.orangeAccent.withOpacity(0.22)
                      : Colors.orange.withOpacity(0.20),
                ),
                const SizedBox(width: 10),
                _pill(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  label: "Total em estoque",
                  value: totalText,
                  bg: isDark
                      ? const Color(0xFFD4AF37).withOpacity(0.12)
                      : Colors.black.withOpacity(0.04),
                  fg: isDark ? const Color(0xFFD4AF37) : Colors.black87,
                  border: isDark
                      ? const Color(0xFFD4AF37).withOpacity(0.22)
                      : Colors.black.withOpacity(0.12),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}