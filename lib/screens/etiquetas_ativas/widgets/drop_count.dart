// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DropCount extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Map<String, int> counts;

  const DropCount({super.key, 
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final bg = isDark ? const Color(0xFF181818) : Colors.white;
    final fillSelected = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.10)
        : const Color(0xFFE8F5E9);
    final borderIdle = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.10);
    final text = isDark ? Colors.white : Colors.black.withOpacity(0.85);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);

    final hasValue = value != null;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasValue ? primary.withOpacity(0.35) : borderIdle,
            width: hasValue ? 1.4 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withOpacity(0.70), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: hasValue ? fillSelected : bg,
        labelStyle: TextStyle(color: muted),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: hasValue ? primary : muted,
          ),
          selectedItemBuilder: (context) {
            return [
              Text(
                "Todos",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: muted,
                ),
              ),
              ...items.map((s) {
                final c = counts[s] ?? 0;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        s,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "$c",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ];
          },
          hint: Text(
            "Todos",
            style: TextStyle(color: muted),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text("Todos", style: TextStyle(color: text)),
            ),
            ...items.map((s) {
              final c = counts[s] ?? 0;
              final isSel = s == value;

              return DropdownMenuItem<String?>(
                value: s,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? fillSelected : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                            color: isSel ? primary : text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSel ? primary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "$c",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isSel
                                ? (isDark ? Colors.black : Colors.white)
                                : muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
