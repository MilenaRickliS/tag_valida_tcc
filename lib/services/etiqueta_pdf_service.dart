import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/etiqueta_model.dart';

class EtiquetaPdfService {
  static final _df = DateFormat("dd/MM/yyyy");

  static String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(".", ",");
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _daysToExpire(DateTime validade) {
    final today = _dateOnly(DateTime.now());
    final exp = _dateOnly(validade);
    return exp.difference(today).inDays;
  }

  static String _validadeLabel(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Vencida";
    if (days <= 2) return "Em alerta";
    return "Boa";
  }

  static PdfColor _validadePdfColor(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return PdfColors.red;
    if (days <= 2) return PdfColors.orange;
    return PdfColor.fromHex('#3A8D2F');
  }

  static bool _isImageValue(dynamic value) {
    if (value == null) return false;

    final s = value.toString().trim().toLowerCase();
    if (s.isEmpty) return false;

    final isHttp = s.startsWith('http://') || s.startsWith('https://');
    final looksLikeImage = s.contains('.jpg') ||
        s.contains('.jpeg') ||
        s.contains('.png') ||
        s.contains('.webp') ||
        s.contains('firebasestorage') ||
        s.contains('storage.googleapis.com') ||
        s.contains('alt=media');

    return isHttp && looksLikeImage;
  }

  static bool _looksLikeDateMs(dynamic value) {
    if (value is! num) return false;
    final v = value.toInt();
    return v >= 946684800000 && v <= 4102444800000;
  }

  static pw.Widget _badge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color.shade(0.15),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: color),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: color,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  static pw.Widget _metricCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FAF7F1'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfLinha(String label, String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11.5,
                fontWeight: pw.FontWeight.bold,
                color: color ?? PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<List<pw.Widget>> _buildCustomFieldsPdf(
    Map<String, dynamic> customSemLote,
  ) async {
    final widgets = <pw.Widget>[];

    for (final entry in customSemLote.entries) {
      if (entry.value is! Map) continue;

      final obj = Map<String, dynamic>.from(entry.value as Map);
      final label = (obj["label"] ?? entry.key).toString();
      final val = obj["value"];

      if (val == null || val.toString().trim().isEmpty) {
        widgets.add(_pdfLinha(label, "-"));
        continue;
      }

      if (_isImageValue(val)) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
        );

        try {
          final image = await networkImage(val.toString());

          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#E8E2D9')),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Center(
                child: pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(
                    image,
                    height: 140,
                    width: 220,
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        } catch (_) {
          widgets.add(_pdfLinha(label, "Imagem não pôde ser carregada"));
        }

        continue;
      }

      String texto;
      if (_looksLikeDateMs(val)) {
        texto = _df.format(DateTime.fromMillisecondsSinceEpoch((val as num).toInt()));
      } else if (val is bool) {
        texto = val ? "Sim" : "Não";
      } else {
        texto = val.toString();
      }

      widgets.add(_pdfLinha(label, texto));
    }

    return widgets;
  }

  static Future<Uint8List> generateBytes(
    EtiquetaModel e, {
    required String qrData,
  }) async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('assets/logo6.png');

    final primary = PdfColor.fromHex('#ED7227');
    final secondary = PdfColor.fromHex('#3A8D2F');
    final lightBg = PdfColor.fromHex('#FDF7ED');

    final status = e.statusEstoque.trim().isEmpty ? "ativo" : e.statusEstoque.trim();
    final qtd = e.quantidade;
    final rest = e.quantidadeRestante;

    final num saidas = status == "cancelado"
        ? qtd
        : ((qtd - rest) < 0 ? 0 : (qtd - rest));

    final num restanteView = status == "cancelado" ? 0 : rest;

    final custom = Map<String, dynamic>.from(e.camposCustomValores);

    String? loteValue;
    String loteLabel = "Lote";

    final loteRaw = custom["lote"];
    if (loteRaw is Map) {
      final m = Map<String, dynamic>.from(loteRaw);
      loteLabel = (m["label"] ?? "Lote").toString();
      final v = m["value"];
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty) loteValue = s;
    }

    final customSemLote = Map<String, dynamic>.from(custom);
    customSemLote.remove("lote");

    final customWidgets = await _buildCustomFieldsPdf(customSemLote);

    final validadeColor = _validadePdfColor(e.dataValidade);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(16),
              border: pw.Border.all(color: PdfColor.fromHex('#E8E2D9')),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 40,
                          height: 40,
                          child: pw.Image(logo),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          'TagValida',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Etiqueta',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: primary),
                pw.SizedBox(height: 10),
                pw.Text(
                  e.produtoNome,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  e.tipoNome,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    _badge(status.toUpperCase(), secondary),
                    pw.SizedBox(width: 8),
                    _badge(_validadeLabel(e.dataValidade), validadeColor),
                  ],
                ),
                pw.SizedBox(height: 16),
                _pdfLinha("Categoria", e.categoriaNome),
                _pdfLinha("Setor", e.setorNome),
                _pdfLinha("Fabricação", _df.format(e.dataFabricacao)),
                _pdfLinha("Validade", _df.format(e.dataValidade), color: validadeColor),
                if (loteValue != null) _pdfLinha(loteLabel, loteValue),
                pw.SizedBox(height: 14),
                pw.Row(
                  children: [
                    pw.Expanded(child: _metricCard("Qtd", _fmtNum(qtd))),
                    pw.SizedBox(width: 8),
                    pw.Expanded(child: _metricCard("Saídas", _fmtNum(saidas))),
                    pw.SizedBox(width: 8),
                    pw.Expanded(child: _metricCard("Restante", _fmtNum(restanteView))),
                  ],
                ),
                if (customWidgets.isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  pw.Text(
                    'Campos adicionais',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...customWidgets,
                ],
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: lightBg,
                          borderRadius: pw.BorderRadius.circular(14),
                          border: pw.Border.all(color: primary),
                        ),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 140,
                          height: 140,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        "Escaneie para acessar",
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}