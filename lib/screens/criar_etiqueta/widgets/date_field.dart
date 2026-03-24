// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime d) onPick;

  const DateField({super.key, 
    required this.label,
    required this.value,
    required this.onPick,
  });

  InputDecoration _decoration(BuildContext context, String label) {
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
    final textColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final iconColor = isDark ? const Color(0xFFD4AF37) : null;

    final text = (value == null)
        ? "Selecionar"
        : "${value!.day.toString().padLeft(2, "0")}/"
          "${value!.month.toString().padLeft(2, "0")}/"
          "${value!.year}";

    return InkWell(
      onTap: () async {
        final rootContext = Navigator.of(context, rootNavigator: true).context;
        final isDarkPicker = Theme.of(context).brightness == Brightness.dark;

        final d = await showDatePicker(
          context: rootContext,
          locale: const Locale('pt', 'BR'),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
          builder: (context, child) {
            final base = Theme.of(context);

            final primary = isDarkPicker
                ? const Color(0xFFD4AF37)
                : const Color(0xFFED7227);

            final onPrimary = isDarkPicker ? Colors.black : Colors.white;
            final surface = isDarkPicker ? const Color(0xFF1E1E1E) : Colors.white;
            final onSurface = isDarkPicker ? Colors.white : const Color(0xFF1E1E1E);

            final dialogShape = RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            );

            return Theme(
              data: base.copyWith(
                useMaterial3: true,
                colorScheme: base.colorScheme.copyWith(
                  primary: primary,
                  onPrimary: onPrimary,
                  surface: surface,
                  onSurface: onSurface,
                ),
                dialogTheme: DialogTheme(shape: dialogShape),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                datePickerTheme: DatePickerThemeData(
                  shape: dialogShape,
                  backgroundColor: surface,
                  headerBackgroundColor: primary,
                  headerForegroundColor: onPrimary,
                  headerHeadlineStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return onPrimary;
                    return onSurface;
                  }),
                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return primary;
                    return Colors.transparent;
                  }),
                  todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return onPrimary;
                    return onSurface;
                  }),
                  todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return primary;
                    return primary.withOpacity(0.14);
                  }),
                  todayBorder: BorderSide(
                    color: primary.withOpacity(0.45),
                    width: 1.6,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (d != null) onPick(d);
      },
      child: InputDecorator(
        decoration: _decoration(context, label),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: textColor),
              ),
            ),
            Icon(Icons.calendar_month_outlined, size: 18, color: iconColor),
          ],
        ),
      ),
    );
  }
}

