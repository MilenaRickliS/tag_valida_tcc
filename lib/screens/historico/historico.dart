// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../providers/auth_provider.dart';
import '../../providers/estoque_mov_local_provider.dart';
import '../../models/estoque_mov_model.dart';
import '../../models/estoque_mov_resumo.dart';
import '../../widgets/menu.dart';
import '../../widgets/estoque_footer.dart';
import './widgets/graficos_view.dart';
import './widgets/page_header.dart';
import './widgets/pdf_button.dart';
import './widgets/periodo_button.dart';
import './widgets/search_box.dart';
import './widgets/tabela_view.dart';
import './widgets/tipo_drop.dart';
import './widgets/toggle_view_button.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final _qCtrl = TextEditingController();
  String _q = "";
  String? _tipoFiltro;

  DateTimeRange? _periodo;
  bool _showGraficos = false;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

  Color _cardAlt(BuildContext context) =>
      _isDark(context) ? const Color(0xFF181818) : Colors.white.withOpacity(0.75);

  Color _muted(BuildContext context) =>
      _isDark(context) ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.55);

  Color _border(BuildContext context) => _isDark(context)
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.08);

  @override
  void initState() {
    super.initState();
    _qCtrl.addListener(() => setState(() => _q = _qCtrl.text));
  }

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPeriodo(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, 1, 1);
    final lastDate = DateTime(now.year + 1, 12, 31);
    final isDark = _isDark(context);

    final base = Theme.of(context);
    final seed = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2E7D32);

    final themed = base.copyWith(
      dialogTheme: base.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: seed,
        onPrimary: isDark ? Colors.black : Colors.white,
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black87,
      ),
      datePickerTheme: base.datePickerTheme.copyWith(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        headerBackgroundColor: seed,
        headerForegroundColor: isDark ? Colors.black : Colors.white,
        rangeSelectionBackgroundColor: seed.withOpacity(0.18),
        rangePickerBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _periodo ??
          DateTimeRange(
            start: DateTime(now.year, now.month, now.day - 7),
            end: now,
          ),
      helpText: "Selecionar período",
      builder: (ctx, child) {
        return Theme(data: themed, child: child ?? const SizedBox.shrink());
      },
    );

    if (picked != null) {
      setState(() => _periodo = picked);
    }
  }

  Future<void> _exportPdf(
    BuildContext context, {
    required List<EstoqueMovModel> all,
    required MovStats stats,
    required DateTimeRange? periodo,
    required String? tipo,
    required String query,
  }) async {
    final doc = pw.Document();

    final filtroPeriodo = (periodo == null)
        ? "Período: Todos"
        : "Período: ${_fmtDateOnly(periodo.start)} a ${_fmtDateOnly(periodo.end)}";
    final filtroTipo = "Tipo: ${tipo ?? "Todos"}";
    final filtroBusca = "Busca: ${query.trim().isEmpty ? "—" : query.trim()}";

    final tableData = <List<String>>[
      ["Data", "Tipo", "Produto", "Qtd", "Motivo", "EtiquetaId"],
      ...all.map((m) {
        return [
          _fmtDt(m.createdAt),
          m.tipo,
          (m.produtoNome ?? "--"),
          _fmtNum(m.quantidade),
          (m.motivo ?? ""),
          m.etiquetaId,
        ];
      }),
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        build: (ctx) => [
          pw.Text(
            "Histórico - Movimentações do Estoque",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            "Relatório gerado conforme filtros aplicados na tela.",
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF5F5F5),
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(filtroPeriodo, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(filtroTipo, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(filtroBusca, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 6),
                pw.Text(
                  "Total de registros: ${all.length}",
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            "Gráficos",
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _pdfChartCard(
            title: "Volume por tipo",
            subtitle: "Soma das quantidades por categoria.",
            child: _pdfBars(
              items: stats.byTipo.entries.map((e) {
                return _PdfBarItem(
                  label: e.key,
                  value: e.value,
                  color: _TipoColorsPdf.fg(e.key),
                );
              }).toList(),
            ),
          ),
          pw.SizedBox(height: 10),
          _pdfChartCard(
            title: "Movimentações por dia",
            subtitle: "Quantidade de registros por data.",
            child: _pdfBars(
              items: stats.byDay.entries.map((e) {
                return _PdfBarItem(
                  label: e.key,
                  value: e.value.toDouble(),
                  color: PdfColors.grey700,
                );
              }).toList(),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            "Dados",
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            data: tableData,
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF2E2E2E),
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.0),
              2: const pw.FlexColumnWidth(1.8),
              3: const pw.FlexColumnWidth(0.7),
              4: const pw.FlexColumnWidth(1.6),
              5: const pw.FlexColumnWidth(1.2),
            },
          ),
        ],
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Página ${ctx.pageNumber} de ${ctx.pagesCount}",
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static String _fmtDateOnly(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Faça login novamente.")));
    }

    final movProv = context.read<EstoqueMovLocalProvider>();

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context),
        elevation: 0,
        toolbarHeight: compact ? 160 : 100,
        centerTitle: true,
        title: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo6.png', height: 78),
                  const SizedBox(height: 10),
                  const TopMenu(),
                ],
              )
            : Row(
                children: [
                  Image.asset('assets/logo6.png', height: 92),
                  const Spacer(),
                  const TopMenu(),
                ],
              ),
      ),
      body: FutureBuilder<EstoqueMovResumo>(
        future: movProv.resumo(uid: uid),
        builder: (context, resumoSnap) {
          return FutureBuilder<List<EstoqueMovModel>>(
            future: movProv.listAll(uid: uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text("Erro: ${snap.error}"));
              }

              var all = snap.data ?? [];
              all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              if (_periodo != null) {
                final start = DateTime(
                  _periodo!.start.year,
                  _periodo!.start.month,
                  _periodo!.start.day,
                  0,
                  0,
                  0,
                );
                final end = DateTime(
                  _periodo!.end.year,
                  _periodo!.end.month,
                  _periodo!.end.day,
                  23,
                  59,
                  59,
                );
                all = all.where((m) {
                  final d = m.createdAt;
                  return !d.isBefore(start) && !d.isAfter(end);
                }).toList();
              }

              if (_tipoFiltro != null) {
                all = all.where((m) => m.tipo == _tipoFiltro).toList();
              }

              final q = _q.trim().toLowerCase();
              if (q.isNotEmpty) {
                all = all.where((m) {
                  final s = [
                    m.motivo ?? "",
                    m.produtoNome ?? "",
                    m.etiquetaId,
                    m.tipo,
                  ].join(" ").toLowerCase();
                  return s.contains(q);
                }).toList();
              }

              final resumo = resumoSnap.data;
              final stats = MovStats.fromMovs(all);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final footerH = (resumo != null) ? 92.0 : 0.0;
                  final headerH = compact ? 86.0 : 78.0;
                  final filtersH = compact ? 160.0 : 86.0;

                  final cardH = (constraints.maxHeight - headerH - filtersH - footerH - 24)
                      .clamp(320.0, 700.0);

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                          child: PageHeader(compact: compact),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final isNarrow = c.maxWidth < 680;

                              final controls = <Widget>[
                                SizedBox(
                                  width: isNarrow ? c.maxWidth : 360,
                                  child: SearchBox(controller: _qCtrl),
                                ),
                                TipoDrop(
                                  value: _tipoFiltro,
                                  onChanged: (v) => setState(() => _tipoFiltro = v),
                                ),
                                PeriodoButton(
                                  range: _periodo,
                                  onPick: () => _pickPeriodo(context),
                                  onClear: () => setState(() => _periodo = null),
                                ),
                                ToggleViewButton(
                                  showGraficos: _showGraficos,
                                  onPressed: () => setState(() => _showGraficos = !_showGraficos),
                                ),
                                PdfButton(
                                  onPressed: () async {
                                    await _exportPdf(
                                      context,
                                      all: all,
                                      stats: stats,
                                      periodo: _periodo,
                                      tipo: _tipoFiltro,
                                      query: _q,
                                    );
                                  },
                                ),
                              ];

                              return isNarrow
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        controls[0],
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: controls.sublist(1),
                                        ),
                                      ],
                                    )
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: controls,
                                    );
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            height: cardH,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _cardAlt(context),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: _border(context)),
                              ),
                              child: all.isEmpty
                                  ? Center(
                                      child: Text(
                                        "Nenhuma movimentação encontrada.",
                                        style: TextStyle(color: _muted(context)),
                                      ),
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 220),
                                      child: _showGraficos
                                          ? GraficosView(stats: stats)
                                          : TabelaView(all: all),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      if (resumo != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                            child: EstoqueFooter(
                              entradas: resumo.entradas,
                              saidas: resumo.saidasVenda + resumo.saidasCancelamento,
                              total: resumo.saldo,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  static String _fmtDt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}";
  }

  static String _fmtNum(num v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(".", ",");
  }
}

class _PdfBarItem {
  final String label;
  final double value;
  final PdfColor color;
  _PdfBarItem({required this.label, required this.value, required this.color});
}

pw.Widget _pdfChartCard({
  required String title,
  required String subtitle,
  required pw.Widget child,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Text(subtitle, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 8),
        child,
      ],
    ),
  );
}

pw.Widget _pdfBars({required List<_PdfBarItem> items}) {
  if (items.isEmpty) {
    return pw.Text(
      "Sem dados para o período/filtros.",
      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    );
  }

  final maxV = items.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b);
  final safeMax = maxV <= 0 ? 1.0 : maxV;

  return pw.Column(
    children: items.map((e) {
      final w = (e.value / safeMax).clamp(0.0, 1.0);

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 95,
              child: pw.Text(
                e.label,
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.LayoutBuilder(
                builder: (context, constraints) {
                  final fullW = constraints!.maxWidth;
                  final barW = fullW * w;

                  return pw.Stack(
                    children: [
                      pw.Container(
                        height: 10,
                        width: fullW,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(999),
                        ),
                      ),
                      pw.Container(
                        height: 10,
                        width: barW,
                        decoration: pw.BoxDecoration(
                          color: e.color,
                          borderRadius: pw.BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            pw.SizedBox(width: 8),
            pw.SizedBox(
              width: 48,
              child: pw.Text(
                _pdfFmtNum(e.value),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

String _pdfFmtNum(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll(".", ",");
}

class _TipoColorsPdf {
  static PdfColor fg(String tipo) {
    if (tipo == EstoqueMovModel.tipoEntrada) return PdfColor.fromInt(0xFF2E7D32);
    if (tipo == EstoqueMovModel.tipoVenda) return PdfColor.fromInt(0xFFF57C00);
    if (tipo == EstoqueMovModel.tipoCancelamento) return PdfColor.fromInt(0xFFC62828);
    if (tipo == EstoqueMovModel.tipoAjusteEntrada) return PdfColor.fromInt(0xFF1565C0);
    if (tipo == EstoqueMovModel.tipoAjusteSaida) return PdfColor.fromInt(0xFF6A1B9A);
    if (tipo == EstoqueMovModel.tipoExclusao) return PdfColor.fromInt(0xFFB71C1C);
    return PdfColors.grey800;
  }
}