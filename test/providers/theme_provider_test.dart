import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tag_valida/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('deve iniciar com tema claro', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
    });

    test('deve alternar de tema claro para escuro', () {
      final provider = ThemeProvider();

      provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);
    });

    test('deve alternar de tema escuro para claro', () {
      final provider = ThemeProvider();

      provider.toggleTheme();
      provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
    });

    test('deve definir tema escuro com setTheme', () {
      final provider = ThemeProvider();

      provider.setTheme(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);
    });
  });
}