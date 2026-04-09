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

  static String _fmtCustomNum(num v, {int casas = 2}) {
  if (v % 1 == 0) return v.toInt().toString();
  return v.toStringAsFixed(casas).replaceAll(".", ",");
}

static bool _isCampoImagem(Map<String, dynamic> obj) {
  return (obj["tipo"] ?? "").toString() == "image";
}

static bool _isCampoDate(Map<String, dynamic> obj) {
  return (obj["tipo"] ?? "").toString() == "date";
}

static bool _isCampoBool(Map<String, dynamic> obj) {
  return (obj["tipo"] ?? "").toString() == "bool";
}

static bool _isCampoPriceMode(Map<String, dynamic> obj) {
  return (obj["tipo"] ?? "").toString() == "priceMode";
}

static bool _isCampoNumerico(Map<String, dynamic> obj) {
  final tipo = (obj["tipo"] ?? "").toString();
  return tipo == "integer" || tipo == "decimal" || tipo == "currency";
}

static String _aplicarPrefixoSufixo(
  String valor, {
  String? prefixo,
  String? sufixo,
}) {
  final pre = (prefixo ?? "").trim();
  final suf = (sufixo ?? "").trim();

  var texto = valor.trim();
  if (pre.isNotEmpty) texto = '$pre$texto';
  if (suf.isNotEmpty) texto = '$texto$suf';
  return texto;
}

static String _formatarCampoCustomPdf(Map<String, dynamic> obj) {
  final val = obj["value"];
  final prefixo = obj["prefixo"]?.toString();
  final sufixo = obj["sufixo"]?.toString();
  final casas = (obj["casasDecimais"] as num?)?.toInt() ?? 2;

  if (val == null) return "-";

  if (_isCampoBool(obj)) {
    return val == true ? "Sim" : "Não";
  }

  if (_isCampoDate(obj)) {
    if (_looksLikeDateMs(val)) {
      return _df.format(
        DateTime.fromMillisecondsSinceEpoch((val as num).toInt()),
      );
    }
    return val.toString();
  }

  if (_isCampoPriceMode(obj)) {
    if (val is Map) {
      final map = Map<String, dynamic>.from(val);
      final valorRaw = map["valor"];
      final modo = (map["modo"] ?? "").toString().trim();

      String valorFmt = "";
      if (valorRaw is num) {
        valorFmt = _fmtCustomNum(valorRaw, casas: casas);
      } else if (valorRaw != null) {
        final n = num.tryParse(
          valorRaw.toString().trim().replaceAll(",", "."),
        );
        valorFmt = n != null
            ? _fmtCustomNum(n, casas: casas)
            : valorRaw.toString();
      }

      valorFmt = _aplicarPrefixoSufixo(
        valorFmt,
        prefixo: prefixo,
        sufixo: sufixo,
      );

      if (modo.isNotEmpty) {
        return "$valorFmt/$modo";
      }
      return valorFmt;
    }

    return val.toString();
  }

  if (_isCampoNumerico(obj)) {
    if (val is num) {
      return _aplicarPrefixoSufixo(
        _fmtCustomNum(val, casas: casas),
        prefixo: prefixo,
        sufixo: sufixo,
      );
    }

    final n = num.tryParse(val.toString().trim().replaceAll(",", "."));
    if (n != null) {
      return _aplicarPrefixoSufixo(
        _fmtCustomNum(n, casas: casas),
        prefixo: prefixo,
        sufixo: sufixo,
      );
    }

    return _aplicarPrefixoSufixo(
      val.toString(),
      prefixo: prefixo,
      sufixo: sufixo,
    );
  }

  return _aplicarPrefixoSufixo(
    val.toString(),
    prefixo: prefixo,
    sufixo: sufixo,
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

      if (_isCampoImagem(obj)) {
        final imageUrl = (val ?? "").toString().trim();

        if (imageUrl.isEmpty) {
          widgets.add(_pdfLinha(label, "-"));
          continue;
        }

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
          final image = await networkImage(imageUrl);

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

      final texto = _formatarCampoCustomPdf(obj);
      widgets.add(_pdfLinha(label, texto));
    }

    return widgets;
  }

 static pw.Widget _buildTabelaNutricionalPdf(EtiquetaModel e) {
    final t = e.tabelaNutricional!;
    final porcaoLabel = '${t.porcao} g';
    final medidaCaseiraCompleta =
        '${t.quantidadeMedida} ${t.medidaCaseira}'.trim();

    double porcaoEmGramas() {
      final raw = t.porcao.trim().replaceAll(',', '.');
      return double.tryParse(raw) ?? 0;
    }

    double calc100g(double valorNaPorcao) {
      final porcao = porcaoEmGramas();
      if (porcao <= 0) return 0;
      return (valorNaPorcao / porcao) * 100;
    }

    double calcVD(double valorNaPorcao, double vdReferencia) {
      if (vdReferencia <= 0) return 0;
      return (valorNaPorcao / vdReferencia) * 100;
    }

    String fmtNum(num v, {int casas = 1}) {
      if (v % 1 == 0) return v.toInt().toString();
      return v.toStringAsFixed(casas).replaceAll('.', ',');
    }

    String fmtVd(double v) {
      if (v <= 0) return '0%';
      return '${v.round()}%';
    }

    pw.TextStyle titleStyle() => pw.TextStyle(
          color: PdfColors.black,
          fontSize: 16.8,
          fontWeight: pw.FontWeight.bold,
        );

    pw.TextStyle infoStyle() => pw.TextStyle(
          color: PdfColors.black,
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        );

    pw.TextStyle headerStyle() => pw.TextStyle(
          color: PdfColors.black,
          fontSize: 9.6,
          fontWeight: pw.FontWeight.bold,
        );

    pw.TextStyle cellStyle({bool bold = false}) => pw.TextStyle(
          color: PdfColors.black,
          fontSize: 9.6,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        );

    pw.Widget headerCell(String text, {pw.TextAlign align = pw.TextAlign.center}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2.5),
        child: pw.Text(
          text,
          textAlign: align,
          style: headerStyle(),
        ),
      );
    }

    pw.TableRow dataRow({
      required String label,
      required double valorPorcao,
      required double vdReferencia,
      bool indentado = false,
    }) {
      final valor100 = calc100g(valorPorcao);
      final vd = calcVD(valorPorcao, vdReferencia);

      pw.Widget cell(
        String text, {
        pw.TextAlign align = pw.TextAlign.left,
        pw.EdgeInsets? padding,
        bool bold = false,
      }) {
        return pw.Padding(
          padding: padding ??
              const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
          child: pw.Text(
            text,
            textAlign: align,
            style: cellStyle(bold: bold),
          ),
        );
      }

      return pw.TableRow(
        children: [
          cell(
            label,
            padding: pw.EdgeInsets.fromLTRB(
              indentado ? 12 : 4,
              4,
              4,
              4,
            ),
          ),
          cell(
            fmtNum(valor100),
            align: pw.TextAlign.center,
          ),
          cell(
            fmtNum(valorPorcao),
            align: pw.TextAlign.center,
          ),
          cell(
            fmtVd(vd),
            align: pw.TextAlign.center,
          ),
        ],
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.black, width: 1.3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.4),
              ),
            ),
            child: pw.Text(
              'INFORMAÇÃO NUTRICIONAL',
              textAlign: pw.TextAlign.center,
              style: titleStyle(),
            ),
          ),

          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Porções por embalagem: ${t.porcoesPorEmbalagem}',
                  style: infoStyle(),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Porção: $porcaoLabel ($medidaCaseiraCompleta)',
                  style: infoStyle(),
                ),
              ],
            ),
          ),

          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 2.4),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.4),
              ),
            ),
            child: pw.Table(
              border: const pw.TableBorder(
                verticalInside: pw.BorderSide(
                  color: PdfColors.black,
                  width: 0.4,
                ),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(4),
                1: pw.FlexColumnWidth(0.9),
                2: pw.FlexColumnWidth(0.9),
                3: pw.FlexColumnWidth(0.7),
              },
              children: [
                pw.TableRow(
                  children: [
                    headerCell('', align: pw.TextAlign.left),
                    headerCell('100 g'),
                    headerCell(porcaoLabel),
                    headerCell('%VD*'),
                  ],
                ),
              ],
            ),
          ),

          pw.Table(
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.black,
                width: 0.4,
              ),
              verticalInside: pw.BorderSide(
                color: PdfColors.black,
                width: 0.4,
              ),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(4),
              1: pw.FlexColumnWidth(0.9),
              2: pw.FlexColumnWidth(0.9),
              3: pw.FlexColumnWidth(0.7),
            },
            children: [
              dataRow(
                label: 'Valor energético (kcal)',
                valorPorcao: t.valorEnergetico,
                vdReferencia: 2000,
              ),
              dataRow(
                label: 'Carboidratos totais (g)',
                valorPorcao: t.carboidratos,
                vdReferencia: 300,
              ),
              dataRow(
                label: 'Açúcares totais (g)',
                valorPorcao: t.acucaresTotais,
                vdReferencia: 50,
                indentado: true,
              ),
              dataRow(
                label: 'Açúcares adicionados (g)',
                valorPorcao: t.acucaresAdicionados,
                vdReferencia: 50,
                indentado: true,
              ),
              dataRow(
                label: 'Proteínas (g)',
                valorPorcao: t.proteinas,
                vdReferencia: 50,
              ),
              dataRow(
                label: 'Gorduras totais (g)',
                valorPorcao: t.gordurasTotais,
                vdReferencia: 55,
              ),
              dataRow(
                label: 'Gorduras saturadas (g)',
                valorPorcao: t.gordurasSaturadas,
                vdReferencia: 22,
                indentado: true,
              ),
              dataRow(
                label: 'Gorduras trans (g)',
                valorPorcao: t.gordurasTrans,
                vdReferencia: 2,
                indentado: true,
              ),
              dataRow(
                label: 'Fibras alimentares (g)',
                valorPorcao: t.fibraAlimentar,
                vdReferencia: 25,
              ),
              dataRow(
                label: 'Sódio (mg)',
                valorPorcao: t.sodio,
                vdReferencia: 2000,
              ),
            ],
          ),

          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 1.3),
              ),
            ),
            padding: const pw.EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: pw.Text(
              '* Percentual de valores diários fornecidos pela porção.',
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 9.8,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
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
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => [
          pw.Container(
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
                _pdfLinha(
                  "Validade",
                  _df.format(e.dataValidade),
                  color: validadeColor,
                ),
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
                if (e.incluirTabelaNutricional && e.tabelaNutricional != null) ...[
                  _buildTabelaNutricionalPdf(e),
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
          ),
        ],
      ),
    );
    return pdf.save();
  }
}