// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const SearchBox({super.key, 
    required this.controller,
    required this.onClear,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.16)
              : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark
                ? const Color(0xFFD4AF37)
                : Colors.black.withOpacity(0.55),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2B2B2B),
              ),
              decoration: InputDecoration(
                hintText: "Buscar por produto, setor, categoria, tipo...",
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFFD6D6D6)
                      : Colors.black.withOpacity(0.45),
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: (controller.text.trim().isNotEmpty)
                ? IconButton(
                    key: const ValueKey("clear"),
                    tooltip: "Limpar",
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? const Color(0xFFD4AF37) : null,
                    ),
                  )
                : const SizedBox(
                    key: ValueKey("noClear"),
                    width: 0,
                    height: 0,
                  ),
          ),
        ],
      ),
    );
  }
}

