// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/estoque_mov_model.dart';
import './tipo_chip.dart';

class TabelaView extends StatelessWidget {
  final List<EstoqueMovModel> all;

  const TabelaView({
    super.key,
    required this.all,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  String _fmtDt(DateTime d) {
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final text = _isDark(context) ? Colors.white : Colors.black87;
    final headingBg =
        _isDark(context) ? const Color(0xFF181818) : const Color(0xFFF5F5F5);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: _isDark(context)
            ? const Color(0xFFD4AF37).withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
      ),
      child: SingleChildScrollView(
        key: const ValueKey("tabela"),
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(headingBg),
            headingTextStyle: TextStyle(
              color: text,
              fontWeight: FontWeight.w900,
            ),
            dataTextStyle: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
            ),
            headingRowHeight: 44,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 56,
            columns: const [
              DataColumn(label: Text("Data")),
              DataColumn(label: Text("Tipo")),
              DataColumn(label: Text("Produto")),
              DataColumn(label: Text("Qtd")),
              DataColumn(label: Text("Motivo")),
              DataColumn(label: Text("EtiquetaId")),
            ],
            rows: all.map((m) {
              return DataRow(
                cells: [
                  DataCell(Text(_fmtDt(m.createdAt))),
                  DataCell(TipoChip(tipo: m.tipo)),
                  DataCell(Text(m.produtoNome ?? "--")),
                  DataCell(Text(_fmtNum(m.quantidade))),
                  DataCell(Text(m.motivo ?? "")),
                  DataCell(Text(m.etiquetaId)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}