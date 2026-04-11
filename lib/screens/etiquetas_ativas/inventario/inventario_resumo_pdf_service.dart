import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'scanner_inventario_screen.dart';

class InventarioResumoPdfService {
  static Future<void> abrirOuCompartilharPdf(
    BuildContext context, {
    required InventarioResumo resumo,
  }) async {
    final pdf = pw.Document();

    final setoresOrdenados = resumo.totalPorSetor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoriasOrdenadas = resumo.totalPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          _header(),
          pw.SizedBox(height: 16),
          _resumoGeral(resumo),
          pw.SizedBox(height: 14),
          _blocoLista(
            titulo: "Total por setor",
            itens: setoresOrdenados,
          ),
          pw.SizedBox(height: 14),
          _blocoLista(
            titulo: "Total por categoria",
            itens: categoriasOrdenadas,
          ),
          pw.SizedBox(height: 14),
          _itensLidos(resumo),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File(
      "${dir.path}/inventario_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }

  static pw.Widget _header() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F5EF'),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E8E2D9')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Resumo do inventário",
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2B2B2B'),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            "Inventário finalizado com sucesso",
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#6B6B6B'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            "Gerado em ${_fmtDateTime(DateTime.now())}",
            style: pw.TextStyle(
              fontSize: 10.5,
              color: PdfColor.fromHex('#6B6B6B'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _resumoGeral(InventarioResumo resumo) {
    return _card(
      titulo: "Resumo geral",
      child: pw.Row(
        children: [
          pw.Expanded(
            child: _miniResumo(
              titulo: "Etiquetas lidas",
              valor: resumo.etiquetasLidas.toString(),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: _miniResumo(
              titulo: "Total de itens",
              valor: resumo.totalItens.toString(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _miniResumo({
    required String titulo,
    required String valor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F5EF'),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex('#E8E2D9')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            valor,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2B2B2B'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 10.5,
              color: PdfColor.fromHex('#6B6B6B'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _blocoLista({
  required String titulo,
  required List<MapEntry<String, num>> itens,
}) {
  return _card(
    titulo: titulo,
    child: pw.Column(
      children: itens.map((e) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  e.key,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromHex('#2B2B2B'),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                e.value.toString(),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#2B2B2B'),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

  static pw.Widget _itensLidos(InventarioResumo resumo) {
    return _card(
      titulo: "Etiquetas lidas",
      child: pw.Column(
        children: resumo.itens.map((item) {
          return pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8F5EF'),
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColor.fromHex('#E8E2D9')),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.produtoNome,
                  style: pw.TextStyle(
                    fontSize: 12.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2B2B2B'),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "Setor: ${item.setorNome}",
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    color: PdfColor.fromHex('#6B6B6B'),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "Categoria: ${item.categoriaNome}",
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    color: PdfColor.fromHex('#6B6B6B'),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  "Quantidade: ${item.quantidade}",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2B2B2B'),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _card({
    required String titulo,
    required pw.Widget child,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E8E2D9')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2B2B2B'),
            ),
          ),
          pw.SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  static String _fmtDateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}";
  }
}