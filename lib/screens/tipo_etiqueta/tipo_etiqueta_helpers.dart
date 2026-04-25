// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tipo_etiqueta_model.dart';

class TipoEtiquetaLimits {
  static const nomeMin = 3;
  static const nomeMax = 40;
  static const descMax = 120;
}

class CampoCustomLimits {
  static const labelMin = 2;
  static const labelMax = 40;
  static const keyMin = 2;
  static const keyMax = 40;
}

final nomeDenyFormatter = FilteringTextInputFormatter.deny(
  RegExp(r"[^0-9A-Za-zÀ-ÖØ-öø-ÿÇç ]"),
);

final keyDenyFormatter = FilteringTextInputFormatter.deny(
  RegExp(r"[^a-zA-Z0-9_]"),
);

class TitleCaseEachWordFormatter extends TextInputFormatter {
  const TitleCaseEachWordFormatter();

  bool _isLetter(String ch) => RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿÇç]").hasMatch(ch);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;

    final chars = t.toLowerCase().split('');
    bool capNext = true;

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];

      if (ch == ' ') {
        capNext = true;
        continue;
      }

      if (capNext && _isLetter(ch)) {
        chars[i] = ch.toUpperCase();
      }

      capNext = false;
    }

    final formatted = chars.join();
    final sel = newValue.selection;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection(
        baseOffset: sel.baseOffset.clamp(0, formatted.length),
        extentOffset: sel.extentOffset.clamp(0, formatted.length),
      ),
    );
  }
}

String removeDiacritics(String s) {
  const from = 'áàãâäéèêëíìîïóòõôöúùûüçñÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑ';
  const to = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';

  for (int i = 0; i < from.length; i++) {
    s = s.replaceAll(from[i], to[i]);
  }

  return s;
}

String makeKeyFromLabel(String label) {
  var s = label.trim().toLowerCase();
  s = removeDiacritics(s);
  s = s.replaceAll(RegExp(r'[^a-z0-9_\s]'), '');
  s = s.replaceAll(RegExp(r'\s+'), '_');
  s = s.replaceAll(RegExp(r'_+'), '_');
  s = s.replaceAll(RegExp(r'^_+|_+$'), '');
  return s;
}

String campoTipoLabel(CampoTipo t) {
  switch (t) {
    case CampoTipo.text:
      return "Texto";
    case CampoTipo.integer:
      return "Número inteiro";
    case CampoTipo.decimal:
      return "Número decimal";
    case CampoTipo.currency:
      return "Moeda";
    case CampoTipo.priceMode:
      return "Preço por modo";
    case CampoTipo.multiline:
      return "Texto grande";
    case CampoTipo.date:
      return "Data";
    case CampoTipo.boolType:
      return "Sim/Não";
    case CampoTipo.image:
      return "Imagem";
  }
}

String campoTipoHint(CampoTipo t) {
  switch (t) {
    case CampoTipo.text:
      return "Campo simples, como lote ou marca.";
    case CampoTipo.integer:
      return "Somente números inteiros.";
    case CampoTipo.decimal:
      return "Números com casas decimais.";
    case CampoTipo.currency:
      return "Valor em dinheiro.";
    case CampoTipo.priceMode:
      return "Preço por kg, un, caixa ou pacote.";
    case CampoTipo.multiline:
      return "Texto com mais linhas.";
    case CampoTipo.date:
      return "Selecionador de data.";
    case CampoTipo.boolType:
      return "Campo Sim/Não.";
    case CampoTipo.image:
      return "Permite enviar uma imagem.";
  }
}

InputDecoration appTipoInputDecoration({
  required BuildContext context,
  required String label,
  String? hint,
  String? helper,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
  final fill = isDark ? const Color(0xFF141414) : const Color(0xFFFAF7F1);
  final border = isDark
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.08);
  final labelColor =
      isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.6);

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: fill,
    labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: labelColor),
    helperStyle: TextStyle(color: labelColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: brand, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}