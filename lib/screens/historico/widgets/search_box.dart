// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const SearchBox({super.key, required this.controller});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final border = _isDark(context)
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);
    final hint =
        _isDark(context) ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.45);
    final icon =
        _isDark(context) ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.55);
    final text = _isDark(context) ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark(context) ? 0.14 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: icon),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: text),
              decoration: InputDecoration(
                hintText: "Buscar por produto, motivo, etiqueta...",
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(color: hint),
              ),
            ),
          ),
          IconButton(
            tooltip: "Limpar",
            onPressed: () => controller.clear(),
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