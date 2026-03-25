// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import '../../providers/estoque_mov_local_provider.dart';
import '../../models/estoque_mov_model.dart';
import '../../widgets/menu.dart';
import './widgets/chart_only_bar.dart';
import './widgets/chart_only_pie.dart';
import './widgets/charts_row.dart';
import './widgets/header_actions.dart';
import './widgets/insight_line.dart';
import './widgets/kpi_grid.dart';
import './widgets/mov_list.dart';
import './widgets/rankings_row.dart';
import './widgets/section_card.dart';
import './models/named_value.dart';


class RelatoriosScreen extends StatefulWidget {
  final String uid;
  const RelatoriosScreen({super.key, required this.uid});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  DateTimeRange? _range;
  bool _loading = true;

  List<EstoqueMovModel> _movs = [];
  List<EstoqueMovModel> _filtered = [];

  final _df = DateFormat('dd/MM/yyyy');

  final GlobalKey _pieKey = GlobalKey();
  final GlobalKey _barKey = GlobalKey();

  final GlobalKey _pieKeyPrint = GlobalKey();
  final GlobalKey _barKeyPrint = GlobalKey();
  bool _printing = false;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

  @override
  void initState() {
    super.initState();
    _initDefaultRangeAndLoad();
  }

  Future<void> _initDefaultRangeAndLoad() async {
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 29)),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final provider = context.read<EstoqueMovLocalProvider>();
    final list = await provider.listAll(uid: widget.uid, limit: 2000);

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _movs = list;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    final r = _range;
    if (r == null) {
      _filtered = List.of(_movs);
      return;
    }

    final start = DateTime(r.start.year, r.start.month, r.start.day, 0, 0, 0);
    final end = DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59, 999);

    _filtered = _movs.where((m) {
      final d = m.createdAt.toLocal();
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final isDark = _isDark(context);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
      helpText: 'Selecione o período do relatório',
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        final base = Theme.of(context);
        final scheme = isDark
            ? base.colorScheme.copyWith(
                primary: const Color(0xFFD4AF37),
                onPrimary: Colors.black,
                surface: const Color(0xFF1E1E1E),
                onSurface: Colors.white,
              )
            : base.colorScheme.copyWith(
                primary: const Color(0xff428e2e),
                onPrimary: Colors.white,
                surface: const Color(0xFFFDF7ED),
                onSurface: Colors.black87,
              );

        return Theme(
          data: base.copyWith(
            colorScheme: scheme,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor:
                  isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDF7ED),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor:
                  isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDF7ED),
              headerBackgroundColor:
                  isDark ? const Color(0xFFD4AF37) : const Color(0xff428e2e),
              headerForegroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                isDark
                    ? const Color(0x33D4AF37)
                    : const Color(0x1a428e2e),
              ),
              todayForegroundColor: WidgetStateProperty.all(
                isDark ? const Color(0xFFD4AF37) : const Color(0xff428e2e),
              ),
              rangeSelectionBackgroundColor: isDark
                  ? const Color(0x33D4AF37)
                  : const Color(0x26428e2e),
              rangePickerBackgroundColor:
                  isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDF7ED),
              dayForegroundColor: WidgetStateProperty.all(
                isDark ? Colors.white : Colors.black87,
              ),
              dayStyle: const TextStyle(fontWeight: FontWeight.w600),
              weekdayStyle: const TextStyle(fontWeight: FontWeight.w700),
              yearStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _range = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day),
      );
      _applyFilter();
    });
  }

  Future<void> _exportPdf() async {
    setState(() => _printing = true);

    await Future.delayed(const Duration(milliseconds: 150));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 150));

    final piePng = await _capturePng(_pieKeyPrint, pixelRatio: 3.0);
    final barPng = await _capturePng(_barKeyPrint, pixelRatio: 3.0);

    setState(() => _printing = false);

    final bytes = await _buildPdfBytes(
      range: _range,
      movs: _filtered,
      piePng: piePng,
      barPng: barPng,
    );

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<Uint8List?> _capturePng(GlobalKey key,
      {double pixelRatio = 2.0}) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await WidgetsBinding.instance.endOfFrame;

        final ctx = key.currentContext;
        if (ctx == null) {
          await Future.delayed(const Duration(milliseconds: 80));
          continue;
        }

        final ro = ctx.findRenderObject();
        if (ro is! RenderRepaintBoundary) {
          await Future.delayed(const Duration(milliseconds: 80));
          continue;
        }

        if (ro.debugNeedsPaint) {
          await Future.delayed(const Duration(milliseconds: 80));
          continue;
        }

        final image = await ro.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData?.buffer.asUint8List();
        if (bytes != null && bytes.isNotEmpty) return bytes;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;
    final isPhone = w < 600;

    final periodLabel = _range == null
        ? 'Período: Tudo'
        : 'Período: ${_df.format(_range!.start)} até ${_df.format(_range!.end)}';

    final kpis = _computeKpis(_filtered);
    final topSold = _topByType(_filtered, EstoqueMovModel.tipoVenda, topN: 5);
    final topLost = _topLosses(_filtered, topN: 5);

    return Stack(
      children: [
        Scaffold(
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
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    children: [
                      HeaderActions(
                        isPhone: isPhone,
                        title: 'Relatórios',
                        subtitle: periodLabel,
                        onPickRange: _pickRange,
                        onExportPdf: _exportPdf,
                      ),
                      const SizedBox(height: 14),
                      KpiGrid(kpis: kpis),
                      const SizedBox(height: 14),
                      SectionCard(
                        title: 'Insights rápidos',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InsightLine(
                              label: 'Produto mais vendido',
                              value: topSold.isEmpty
                                  ? '—'
                                  : '${topSold.first.name} (${_fmtNum(topSold.first.value)})',
                              chipBg:
                                  RelatorioCores.bg(EstoqueMovModel.tipoVenda),
                              chipFg:
                                  RelatorioCores.fg(EstoqueMovModel.tipoVenda),
                            ),
                            const SizedBox(height: 8),
                            InsightLine(
                              label: 'Produto com mais perda',
                              value: topLost.isEmpty
                                  ? '—'
                                  : '${topLost.first.name} (${_fmtNum(topLost.first.value)})',
                              chipBg: RelatorioCores.bg(
                                  EstoqueMovModel.tipoExclusao),
                              chipFg: RelatorioCores.fg(
                                  EstoqueMovModel.tipoExclusao),
                            ),
                            const SizedBox(height: 8),
                            InsightLine(
                              label: 'Total de movimentações no período',
                              value: '${_filtered.length}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ChartsRow(
                        pieKey: _pieKey,
                        barKey: _barKey,
                        movs: _filtered,
                      ),
                      const SizedBox(height: 14),
                      RankingsRow(
                        topSold: topSold,
                        topLost: topLost,
                      ),
                      const SizedBox(height: 14),
                      SectionCard(
                        title: 'Movimentações (últimas do período)',
                        child: MovList(movs: _filtered.take(25).toList()),
                      ),
                    ],
                  ),
                ),
        ),
        Offstage(
          offstage: !_printing,
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: 900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepaintBoundary(
                      key: _pieKeyPrint,
                      child: ChartOnlyPie(movs: _filtered),
                    ),
                    const SizedBox(height: 12),
                    RepaintBoundary(
                      key: _barKeyPrint,
                      child: ChartOnlyBar(movs: _filtered),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  Map<String, num> _computeKpis(List<EstoqueMovModel> movs) {
    num entradas = 0;
    num vendas = 0;
    num cancel = 0;
    num excl = 0;
    num ajusteEnt = 0;
    num ajusteSai = 0;

    for (final m in movs) {
      final q = m.quantidade;

      if (m.tipo == EstoqueMovModel.tipoEntrada) entradas += q;
      if (m.tipo == EstoqueMovModel.tipoVenda) vendas += q;
      if (m.tipo == EstoqueMovModel.tipoCancelamento) cancel += q;
      if (m.tipo == EstoqueMovModel.tipoExclusao) excl += q;

      if (_hasAjusteEntrada(m)) ajusteEnt += q;
      if (_hasAjusteSaida(m)) ajusteSai += q;
    }

    final perdas = cancel + excl;
    final saldo = entradas + ajusteEnt - vendas - perdas - ajusteSai;

    final map = <String, num>{
      'Entradas': entradas,
      'Vendas': vendas,
      'Cancelamentos': cancel,
      'Exclusões': excl,
      'Perdas': perdas,
      'Saldo': saldo,
    };

    if (_existsTipoAjusteEntrada()) map['Ajuste Entrada'] = ajusteEnt;
    if (_existsTipoAjusteSaida()) map['Ajuste Saída'] = ajusteSai;

    return map;
  }

  bool _existsTipoAjusteEntrada() {
    try {
      EstoqueMovModel.tipoAjusteEntrada;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _existsTipoAjusteSaida() {
    try {
      EstoqueMovModel.tipoAjusteSaida;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _hasAjusteEntrada(EstoqueMovModel m) {
    try {
      return m.tipo == EstoqueMovModel.tipoAjusteEntrada;
    } catch (_) {
      return false;
    }
  }

  bool _hasAjusteSaida(EstoqueMovModel m) {
    try {
      return m.tipo == EstoqueMovModel.tipoAjusteSaida;
    } catch (_) {
      return false;
    }
  }

  List<NamedValue> _topByType(List<EstoqueMovModel> movs, String tipo,
      {int topN = 5}) {
    final map = <String, num>{};
    for (final m in movs) {
      if (m.tipo != tipo) continue;
      final name = (m.produtoNome?.trim().isNotEmpty ?? false)
          ? m.produtoNome!.trim()
          : 'Sem nome';
      map[name] = (map[name] ?? 0) + m.quantidade;
    }
    final list = map.entries.map((e) => NamedValue(e.key, e.value)).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(topN).toList();
  }

  List<NamedValue> _topLosses(List<EstoqueMovModel> movs, {int topN = 5}) {
    final map = <String, num>{};
    for (final m in movs) {
      final isLoss = m.tipo == EstoqueMovModel.tipoCancelamento ||
          m.tipo == EstoqueMovModel.tipoExclusao;
      if (!isLoss) continue;
      final name = (m.produtoNome?.trim().isNotEmpty ?? false)
          ? m.produtoNome!.trim()
          : 'Sem nome';
      map[name] = (map[name] ?? 0) + m.quantidade;
    }
    final list = map.entries.map((e) => NamedValue(e.key, e.value)).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(topN).toList();
  }

  Future<Uint8List> _buildPdfBytes({
    required DateTimeRange? range,
    required List<EstoqueMovModel> movs,
    required Uint8List? piePng,
    required Uint8List? barPng,
  }) async {
    final kpis = _computeKpis(movs);
    final topSold = _topByType(movs, EstoqueMovModel.tipoVenda, topN: 10);
    final topLost = _topLosses(movs, topN: 10);

    final doc = pw.Document();

    final period = range == null
        ? 'Tudo'
        : '${_df.format(range.start)} até ${_df.format(range.end)}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Relatório de Estoque',
            style:
                pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Período: $period'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Gráficos',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (piePng != null) ...[
            pw.Text(
              'Distribuição por tipo',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Center(child: pw.Image(pw.MemoryImage(piePng), width: 420)),
            pw.SizedBox(height: 10),
          ],
          if (barPng != null) ...[
            pw.Text(
              'Top vendidos (barras)',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Center(child: pw.Image(pw.MemoryImage(barPng), width: 420)),
            pw.SizedBox(height: 12),
          ],
          pw.Text(
            'Resumo',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: kpis.entries.map((e) {
              return pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(e.key),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(_fmtNum(e.value)),
                ),
              ]);
            }).toList(),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Top produtos vendidos',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _pdfRankTable(topSold),
          pw.SizedBox(height: 14),
          pw.Text(
            'Top perdas (cancelamento/exclusão)',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _pdfRankTable(topLost),
          pw.SizedBox(height: 14),
          pw.Text(
            'Movimentações (amostra)',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                children: [
                  _pdfCell('Data', bold: true),
                  _pdfCell('Produto', bold: true),
                  _pdfCell('Tipo', bold: true),
                  _pdfCell('Qtd', bold: true),
                  _pdfCell('Motivo', bold: true),
                ],
              ),
              ...movs.take(35).map(
                    (m) => pw.TableRow(
                      children: [
                        _pdfCell(_df.format(m.createdAt)),
                        _pdfCell((m.produtoNome?.trim().isNotEmpty ?? false)
                            ? m.produtoNome!.trim()
                            : 'Sem nome'),
                        _pdfCell(m.tipo),
                        _pdfCell(_fmtNum(m.quantidade)),
                        _pdfCell(m.motivo ?? ''),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfRankTable(List<NamedValue> items) {
    if (items.isEmpty) return pw.Text('Sem dados no período.');
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      children: [
        pw.TableRow(children: [
          _pdfCell('Produto', bold: true),
          _pdfCell('Quantidade', bold: true)
        ]),
        ...items.map((e) => pw.TableRow(
              children: [_pdfCell(e.name), _pdfCell(_fmtNum(e.value))],
            )),
      ],
    );
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

class RelatorioCores {
  static Color bg(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return Colors.green.withOpacity(0.10);
      case EstoqueMovModel.tipoVenda:
        return Colors.orange.withOpacity(0.10);
      case EstoqueMovModel.tipoCancelamento:
        return Colors.red.withOpacity(0.10);
      case EstoqueMovModel.tipoExclusao:
        return Colors.red.withOpacity(0.08);
      default:
        try {
          if (tipo == EstoqueMovModel.tipoAjusteEntrada) {
            return Colors.blue.withOpacity(0.10);
          }
        } catch (_) {}
        try {
          if (tipo == EstoqueMovModel.tipoAjusteSaida) {
            return Colors.purple.withOpacity(0.10);
          }
        } catch (_) {}
        return Colors.black.withOpacity(0.06);
    }
  }

  static Color fg(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoEntrada:
        return const Color(0xff2e7d32);
      case EstoqueMovModel.tipoVenda:
        return const Color(0xffef6c00);
      case EstoqueMovModel.tipoCancelamento:
        return const Color(0xffc62828);
      case EstoqueMovModel.tipoExclusao:
        return const Color(0xffc62828);
      default:
        try {
          if (tipo == EstoqueMovModel.tipoAjusteEntrada) {
            return const Color(0xff1565c0);
          }
        } catch (_) {}
        try {
          if (tipo == EstoqueMovModel.tipoAjusteSaida) {
            return const Color(0xff6a1b9a);
          }
        } catch (_) {}
        return Colors.black87;
    }
  }

  static Color solid(String tipo) => fg(tipo);
}

