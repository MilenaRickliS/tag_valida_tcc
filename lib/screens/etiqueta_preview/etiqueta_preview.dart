// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/local/repos/etiquetas_local_repo.dart';
import '../../models/etiqueta_model.dart';
import '../../providers/estoque_mov_local_provider.dart';
import '../../providers/printer_config_provider.dart';
import '../criar_etiqueta/criar_etiqueta.dart';
import '../../utils/etiqueta_qr.dart';
import '../../utils/formatar_lote.dart';
import '../../services/printer_app_service.dart';
import './widgets/etiqueta_print_preview.dart';
import './widgets/etiqueta_details_card.dart';
import 'widgets/etiqueta_qr_card.dart';
import './widgets/etiqueta_actions_row.dart';


class EtiquetaPreviewScreen extends StatelessWidget {
  final String uid;
  final String etiquetaId;

  const EtiquetaPreviewScreen({
    super.key,
    required this.uid,
    required this.etiquetaId,
  });

  static const _lightCard = Colors.white;
  static const _lightText = Color(0xFF2B2B2B);
  static const _lightMuted = Color(0xFF6B6B6B);
  static const _darkCard = Color(0xFF1E1E1E);
  static const _darkText = Colors.white;
  static const _darkMuted = Color(0xFFD6D6D6);
  static const _gold = Color(0xFFD4AF37);

    bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) => _isDark(context) ? _darkCard : _lightCard;
  Color _text(BuildContext context) => _isDark(context) ? _darkText : _lightText;
  Color _muted(BuildContext context) => _isDark(context) ? _darkMuted : _lightMuted;
  Color _border(BuildContext context) => _isDark(context)
      ? _gold.withOpacity(0.16)
      : Colors.black.withOpacity(0.06);

    void _openQrFullscreen(BuildContext context, String qrData) {
    final isDark = _isDark(context);
    final cardColor = _card(context);
    final textColor = _text(context);
    final mutedColor = _muted(context);
    final borderColor = _border(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "QR",
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      margin: const EdgeInsets.all(18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "QR Code",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final side = (constraints.maxWidth < constraints.maxHeight)
                                  ? constraints.maxWidth
                                  : constraints.maxHeight;

                              final qrSize = (side * 0.90).clamp(180.0, 900.0);

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: SizedBox(
                                  width: qrSize,
                                  height: qrSize,
                                  child: QrImageView(
                                    data: qrData,
                                    size: qrSize,
                                    padding: const EdgeInsets.all(6),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Aponte a câmera para abrir",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: mutedColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? _gold : Colors.white,
                      size: 28,
                    ),
                    tooltip: "Fechar",
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _daysToExpire(DateTime validade) {
    final today = _dateOnly(DateTime.now());
    final exp = _dateOnly(validade);
    return exp.difference(today).inDays; 
  }

  String _validadeLabel(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Vencida";
    if (days <= 2) return "Em alerta";
    return "Boa";
  }

  Color _validadeColor(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return Colors.red;
    if (days <= 2) return Colors.orange;
    return Colors.green;
  }

  String _validadeHint(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Venceu há ${days.abs()} dia(s)";
    if (days == 0) return "Vence hoje";
    return "Faltam $days dia(s)";
  }

  String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(".", ",");
  }

  String _fmtDate(DateTime d) => DateFormat("dd/MM/yyyy").format(d);

  Color _statusColor(String s) {
    switch (s) {
      case "cancelado":
        return Colors.red;
      case "vendido":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case "cancelado":
        return "Cancelado";
      case "vendido":
        return "Vendido";
      default:
        return "Ativo";
    }
  }


    Future<bool> _confirmDelete(BuildContext context, String nome) async {
    final textColor = _text(context);
    final mutedColor = _muted(context);
    final cardColor = _card(context);
    final cancelColor = _isDark(context) ? _gold : _lightText;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: cardColor,
          surfaceTintColor: Colors.transparent,
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withOpacity(0.18)),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Excluir etiqueta?",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Tem certeza que deseja excluir “$nome”?\nEssa ação não pode ser desfeita.",
            style: TextStyle(color: mutedColor, height: 1.25),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: cancelColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Excluir", style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    return ok ?? false;
  }

  void _openEdit(BuildContext context, EtiquetaModel e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CriarEtiquetaScreen(editarEtiquetaId: e.id),
      ),
    );
  }

 Future<Uint8List> _buildPdf({
  required EtiquetaModel e,
  required String qrData,
  required String status,
  required String categoriaNome,
  required String setorNome,
  required String tipoNome,
  required String produtoNome,
  required DateTime fabricacao,
  required DateTime validade,
  required num qtd,
  required num saidas,
  required num restanteView,
  required String? loteLabel,
  required String? loteFormatado,
  required String? lotePrefixo,
  required Map<String, dynamic> customSemLote,
}) async {
  final pdf = pw.Document();

  final logo = await imageFromAssetBundle('assets/logo6.png'); 

  final primary = PdfColor.fromHex('#ED7227'); 
  final secondary = PdfColor.fromHex('#3A8D2F'); 
  final lightBg = PdfColor.fromHex('#FDF7ED');

  PdfColor validadeColor;
  final days = _daysToExpire(validade);

  if (days < 0) {
    validadeColor = PdfColors.red;
  } else if (days <= 2) {
    validadeColor = PdfColors.orange;
  } else {
    validadeColor = secondary;
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
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
                      pw.Container(
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
                produtoNome,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                tipoNome,
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
                  _badge(_validadeLabel(validade), validadeColor),
                ],
              ),

              pw.SizedBox(height: 16),

            
              _pdfLinha("Categoria", categoriaNome),
              _pdfLinha("Setor", setorNome),
              _pdfLinha("Fabricação", _fmtDate(fabricacao)),
              _pdfLinha("Validade", _fmtDate(validade), color: validadeColor),

              if (loteFormatado != null)
                _pdfLinha("Lote", loteFormatado),

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

              pw.Spacer(),

        
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

  pw.Widget _badge(String text, PdfColor color) {
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

  pw.Widget _metricCard(String label, String value) {
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
  pw.Widget _pdfLinha(String label, String value, {PdfColor? color}) {
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

  Future<void> _salvarPdf(
    BuildContext context, {
    required EtiquetaModel e,
    required String qrData,
    required String status,
    required String categoriaNome,
    required String setorNome,
    required String tipoNome,
    required String produtoNome,
    required DateTime fabricacao,
    required DateTime validade,
    required num qtd,
    required num saidas,
    required num restanteView,
    required String? loteLabel,
    required String? loteFormatado,
    required String? lotePrefixo,
    required Map<String, dynamic> customSemLote,
  }) async {
    try {
      final bytes = await _buildPdf(
        e: e,
        qrData: qrData,
        status: status,
        categoriaNome: categoriaNome,
        setorNome: setorNome,
        tipoNome: tipoNome,
        produtoNome: produtoNome,
        fabricacao: fabricacao,
        validade: validade,
        qtd: qtd,
        saidas: saidas,
        restanteView: restanteView,
        loteLabel: loteLabel,
        loteFormatado: loteFormatado,
        lotePrefixo: lotePrefixo,
        customSemLote: customSemLote,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'etiqueta_${e.produtoNome}_${_fmtDate(validade).replaceAll("/", "-")}.pdf',
      );
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar PDF: $err')),
      );
    }
  }

 Future<void> _imprimirComConfigSalva(
  BuildContext context, {
  required String uid,
  required String produtoNome,
  required DateTime validade,
  required String qrData,
  required String lote,
  required String quantidade,
}) async {
  try {
    final copias = await _abrirModalQuantidadeEtiquetas(context);
    if (copias == null) return;

    final printerProvider = context.read<PrinterConfigProvider>();

    if (printerProvider.defaultPrinter == null) {
      await printerProvider.load(uid);
    }

    final printer = printerProvider.defaultPrinter;
    if (printer == null) {
      throw Exception('Nenhuma impressora padrão configurada.');
    }
    if (!printer.ativo) {
      throw Exception('A impressora padrão está inativa.');
    }
    if (!printer.isValida) {
      throw Exception('A configuração da impressora está incompleta.');
    }
    if (!printer.isNetwork) {
      throw Exception('A impressão disponível no momento é apenas via rede.');
    }

    final appService = PrinterAppService();

    await appService.imprimirEtiquetaCompacta(
      printer: printer,
      produto: produtoNome,
      validade: DateFormat('dd/MM/yyyy').format(validade),
      lote: lote,
      quantidade: quantidade,
      qrData: qrData,
      copias: copias,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copias == 1
                ? '1 etiqueta enviada para impressão com sucesso.'
                : '$copias etiquetas enviadas para impressão com sucesso.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao imprimir: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }
}

  void _abrirPreviewImpressao(
  BuildContext context, {
  required String produto,
  required DateTime validade,
  required String lote,
  required String quantidade,
  required String qrData,
}) {
  showDialog(
    context: context,
    builder: (_) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pré-visualização da etiqueta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : _lightText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualização ampliada da etiqueta 60x40 mm',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.58),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              EtiquetaPrintPreview(
                produto: produto,
                validade: DateFormat('dd/MM/yyyy').format(validade),
                lote: lote,
                quantidade: quantidade,
                qrData: qrData,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: const Text('Fechar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4D58D),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }
  );
}

Future<int?> _abrirModalQuantidadeEtiquetas(BuildContext context) async {
  final ctrl = TextEditingController(text: '1');
  final formKey = GlobalKey<FormState>();
  final isDark = _isDark(context);

  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF4D58D).withOpacity(0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.print_outlined, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Quantidade de etiquetas',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : _lightText,
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Informe quantas cópias deseja imprimir.',
                style: TextStyle(
                  color: isDark ? const Color(0xFFD6D6D6) : _lightMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  hintText: 'Ex.: 3',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF8F5EF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? _gold.withOpacity(0.18)
                          : Colors.black.withOpacity(0.08),
                    ),
                  ),
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Digite um número válido';
                  if (n <= 0) return 'A quantidade deve ser maior que zero';
                  if (n > 500) return 'Quantidade muito alta';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? _gold : _lightText,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final n = int.parse(ctrl.text.trim());
              Navigator.pop(context, n);
            },
            icon: const Icon(Icons.check, color: Colors.black),
            label: const Text('Imprimir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4D58D),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      );
    },
  );
}

 @override
Widget build(BuildContext context) {
  final repo = context.read<EtiquetasLocalRepo>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final borderColor = isDark
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.07);
  final textColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
  final bgColor =
      isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

  return Scaffold(
    backgroundColor: bgColor,
    appBar: AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      iconTheme: IconThemeData(color: isDark ? _gold : Colors.black87),
      title: Text(
        "Pré-visualização",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    body: FutureBuilder<EtiquetaModel?>(
      future: repo.getById(uid: uid, id: etiquetaId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? _gold : const Color(0xFFED7227),
            ),
          );
        }

        final e = snap.data;

        if (e == null) {
          return Center(
            child: Text(
              "Etiqueta não encontrada.",
              style: TextStyle(color: textColor),
            ),
          );
        }

        final qrData = buildEtiquetaQrPayload(uid: uid, etiquetaId: e.id);

        final produtoNome = e.produtoNome;
        final categoriaNome = e.categoriaNome;
        final setorNome = e.setorNome;
        final tipoNome = e.tipoNome;
        final fabricacao = e.dataFabricacao;
        final validade = e.dataValidade;
        final qtd = e.quantidade;
        final rest = e.quantidadeRestante;
        final status = (e.statusEstoque.trim().isEmpty)
            ? "ativo"
            : e.statusEstoque.trim();

        final num saidas =
            status == "cancelado" ? qtd : ((qtd - rest) < 0 ? 0 : (qtd - rest));
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

        final hasLote = loteValue != null && loteValue.trim().isNotEmpty;

        final loteFormatado = hasLote
            ? formatarLote(loteValue.trim(), formato: LoteFormato.dataHora)
            : null;

        final lotePrefixo = hasLote
            ? formatarLote(loteValue.trim(), formato: LoteFormato.prefixoL)
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      tooltip: "Opções",
                      color: isDark ? _darkCard : Colors.white,
                      surfaceTintColor: Colors.transparent,
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: isDark ? _gold : textColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      onSelected: (v) async {
                        if (v == "edit") {
                          _openEdit(context, e);
                        } else if (v == "delete") {
                          final ok = await _confirmDelete(context, e.produtoNome);
                          if (!ok) return;

                          final mov = context.read<EstoqueMovLocalProvider>();
                          final before = await repo.getById(uid: uid, id: e.id);
                          if (before == null) return;

                          final st = (before.statusEstoque.trim().isEmpty)
                              ? "ativo"
                              : before.statusEstoque.trim().toLowerCase();

                          final rest = before.quantidadeRestante;

                          if (st == "ativo" && rest > 0) {
                            await mov.registrarCancelamento(
                              uid: uid,
                              etiquetaId: before.id,
                              quantidade: rest,
                              produtoNome: before.produtoNome,
                              motivo: "Exclusão da etiqueta (removeu do estoque)",
                            );
                          }

                          await mov.registrarExclusao(
                            uid: uid,
                            etiquetaId: before.id,
                            produtoNome: before.produtoNome,
                            motivo: "Exclusão suave",
                          );

                          await repo.deleteSoft(uid, before.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Etiqueta excluída."),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: isDark ? _gold : textColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Editar",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                "Excluir",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  EtiquetaDetailsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    mutedColor: _muted(context),
                    tipoNome: tipoNome,
                    produtoNome: produtoNome,
                    statusLabel: _statusLabel(status),
                    statusColor: _statusColor(status),
                    validadeLabel: _validadeLabel(validade),
                    validadeHint: _validadeHint(validade),
                    validadeColor: _validadeColor(validade),
                    categoriaNome: categoriaNome,
                    setorNome: setorNome,
                    fabricacaoFormatada: _fmtDate(fabricacao),
                    validadeFormatada: _fmtDate(validade),
                    hasLote: hasLote,
                    loteLabel: loteLabel,
                    loteFormatado: loteFormatado,
                    lotePrefixo: lotePrefixo,
                    quantidade: _fmtNum(qtd),
                    saidas: _fmtNum(saidas),
                    restante: _fmtNum(restanteView),
                    customSemLote: customSemLote,
                    formatCustomDate: (ms) =>
                        _fmtDate(DateTime.fromMillisecondsSinceEpoch(ms)),
                  ),

                  const SizedBox(height: 14),

                  EtiquetaQrCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    qrData: qrData,
                    onTapQr: () => _openQrFullscreen(context, qrData),
                  ),

                  const SizedBox(height: 14),

                  EtiquetaActionsRow(
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    gold: _gold,
                    darkCard: _darkCard,
                    onSalvarPdf: () => _salvarPdf(
                      context,
                      e: e,
                      qrData: qrData,
                      status: status,
                      categoriaNome: categoriaNome,
                      setorNome: setorNome,
                      tipoNome: tipoNome,
                      produtoNome: produtoNome,
                      fabricacao: fabricacao,
                      validade: validade,
                      qtd: qtd,
                      saidas: saidas,
                      restanteView: restanteView,
                      loteLabel: hasLote ? loteLabel : null,
                      loteFormatado: loteFormatado,
                      lotePrefixo: lotePrefixo,
                      customSemLote: customSemLote,
                    ),
                    onPreview: () => _abrirPreviewImpressao(
                      context,
                      produto: produtoNome,
                      validade: validade,
                      lote: lotePrefixo ?? loteFormatado ?? '-',
                      quantidade: _fmtNum(restanteView),
                      qrData: qrData,
                    ),
                    onImprimir: () => _imprimirComConfigSalva(
                      context,
                      uid: uid,
                      produtoNome: produtoNome,
                      validade: validade,
                      qrData: qrData,
                      lote: lotePrefixo ?? loteFormatado ?? '-',
                      quantidade: _fmtNum(restanteView),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? _gold : textColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Voltar",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}