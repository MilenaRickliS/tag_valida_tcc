// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class Dropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final String emptyHint;

  const Dropdown({super.key, 
    required this.label,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    required this.emptyHint,
  });

  InputDecoration appInputDecorationGlobal(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);
    final fill = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.18);
    final labelColor = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.6);

    const radius = 16.0;

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fill,
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(brand),
      errorBorder: border(Colors.red.withOpacity(0.75)),
      focusedErrorBorder: border(Colors.red),
      labelStyle: TextStyle(
        color: labelColor,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: brand,
        fontWeight: FontWeight.w800,
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final softCard = isDark ? const Color(0xFF181818) : const Color(0xFFFDF7ED);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.10);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: softCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          emptyHint,
          style: TextStyle(color: muted),
        ),
      );
    }

    final safeValue = (value != null && items.contains(value)) ? value : null;

    return DropdownButtonFormField<T>(
      value: safeValue,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: text),
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                getLabel(e),
                style: TextStyle(color: text),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: appInputDecorationGlobal(context, label),
    );
  }
}

