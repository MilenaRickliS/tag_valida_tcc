// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime d) onPick;
  final String? errorText; 

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
    this.errorText,
  });

  InputDecoration _decoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);
    final fill = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.18);

    const radius = 16.0;

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return InputDecoration(
      labelText: label,
      errorText: errorText, 
      filled: true,
      fillColor: fill,
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(brand),
      errorBorder: border(Colors.red),
      focusedErrorBorder: border(Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF2B2B2B);

    final text = (value == null)
        ? "Selecionar"
        : "${value!.day.toString().padLeft(2, "0")}/"
          "${value!.month.toString().padLeft(2, "0")}/"
          "${value!.year}";

    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          locale: const Locale('pt', 'BR'),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );

        if (d != null) onPick(d);
      },
      child: InputDecorator(
        decoration: _decoration(context),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: TextStyle(color: textColor)),
            ),
            const Icon(Icons.calendar_month_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}