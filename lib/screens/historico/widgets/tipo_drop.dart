// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/estoque_mov_model.dart';

class TipoDrop extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const TipoDrop({super.key, required this.value, required this.onChanged});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final border = _isDark(context)
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          dropdownColor: _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white,
          style: TextStyle(
            color: _isDark(context) ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
          iconEnabledColor: _isDark(context) ? const Color(0xFFD4AF37) : Colors.black87,
          hint: Text(
            "Tipo",
            style: TextStyle(
              color: _isDark(context) ? const Color(0xFFD6D6D6) : Colors.black87,
            ),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text("Todos")),
            DropdownMenuItem(value: EstoqueMovModel.tipoEntrada, child: Text("Entrada")),
            DropdownMenuItem(value: EstoqueMovModel.tipoVenda, child: Text("Venda")),
            DropdownMenuItem(value: EstoqueMovModel.tipoCancelamento, child: Text("Cancelamento")),
            DropdownMenuItem(value: EstoqueMovModel.tipoAjusteEntrada, child: Text("Ajuste +")),
            DropdownMenuItem(value: EstoqueMovModel.tipoAjusteSaida, child: Text("Ajuste -")),
            DropdownMenuItem(value: EstoqueMovModel.tipoExclusao, child: Text("Exclusão")),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
