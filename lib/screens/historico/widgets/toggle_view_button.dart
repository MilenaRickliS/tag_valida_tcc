// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ToggleViewButton extends StatelessWidget {
  final bool showGraficos;
  final VoidCallback onPressed;

  const ToggleViewButton({super.key, 
    required this.showGraficos,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFED7227),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(
        showGraficos ? Icons.table_rows_rounded : Icons.bar_chart_rounded, color: Colors.black,
      ),
      label: Text(
        showGraficos ? "Ver tabela" : "Ver gráficos",
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
