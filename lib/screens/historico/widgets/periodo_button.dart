// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PeriodoButton extends StatelessWidget {
  final DateTimeRange? range;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const PeriodoButton({
    super.key,
    required this.range,
    required this.onPick,
    required this.onClear,
  });

  String _fmt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year}";
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final has = range != null;
    final text = has
        ? "${_fmt(range!.start)} • ${_fmt(range!.end)}"
        : "Período";

    final isDark = _isDark(context);

    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    final fg = isDark ? Colors.white : Colors.black.withOpacity(0.78);

    final iconColor =
        isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.55);

    final buttonColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color.fromARGB(255, 38, 116, 28);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.14 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.date_range_rounded, color: iconColor),
          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ),

          const SizedBox(width: 8),

          TextButton(
            onPressed: onPick,
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
            child: const Text("Selecionar"),
          ),

          if (has)
            IconButton(
              tooltip: "Limpar período",
              onPressed: onClear,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}