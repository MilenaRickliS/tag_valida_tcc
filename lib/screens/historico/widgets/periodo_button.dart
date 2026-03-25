// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PeriodoButton extends StatelessWidget {
  final DateTimeRange? range;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const PeriodoButton({super.key, 
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
    final text = has ? "${_fmt(range!.start)} • ${_fmt(range!.end)}" : "Período";
    final border = _isDark(context)
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);
    final fg = _isDark(context) ? Colors.white : Colors.black.withOpacity(0.78);
    final icon = _isDark(context) ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.55);
    final buttonColor =
        _isDark(context) ? const Color(0xFFD4AF37) : const Color.fromARGB(255, 38, 116, 28);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark(context) ? 0.14 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range_rounded, color: icon),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onPick,
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
            child: const Text("Selecionar"),
          ),
          if (has)
            IconButton(
              tooltip: "Limpar período",
              onPressed: onClear,
              icon: Icon(
                Icons.close_rounded,
                color: _isDark(context) ? Colors.white70 : Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}