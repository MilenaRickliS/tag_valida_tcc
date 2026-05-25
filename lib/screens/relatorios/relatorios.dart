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
import '../../providers/estoque_mov_provider.dart';
import '../../models/estoque_mov_model.dart';
import '../../widgets/menu.dart';
import './widgets/chart_only_pie.dart';
import './widgets/charts_row.dart';
import './widgets/header_actions.dart';
import './widgets/insight_line.dart';
import './widgets/kpi_grid.dart';
import './widgets/mov_list.dart';
import './widgets/rankings_row.dart';
import './widgets/section_card.dart';
import './widgets/top_sold_bar_chart.dart';
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
  final GlobalKey _pieKeyKgPrint = GlobalKey();
  final GlobalKey _barKeyKgPrint = GlobalKey();
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

    final provider = context.read<EstoqueMovProvider>();
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
            dialogTheme: DialogThemeData(
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
    try {
      setState(() => _printing = true);

      await Future.delayed(const Duration(milliseconds: 150));
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 150));

      final piePng = await _capturePng(_pieKeyPrint, pixelRatio: 3.0);
      final pieKgPng = await _capturePng(_pieKeyKgPrint, pixelRatio: 3.0);

      final barPng = await _capturePng(_barKeyPrint, pixelRatio: 3.0);
      final barKgPng = await _capturePng(_barKeyKgPrint, pixelRatio: 3.0);

      final bytes = await _buildPdfBytes(
        range: _range,
        movs: _filtered,
        piePng: piePng,
        pieKgPng: pieKgPng,
        barPng: barPng,
        barKgPng: barKgPng,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao gerar relatório em PDF: ${e.toString().replaceAll("Exception: ", "")}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _printing = false);
      }
    }
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

  List<NamedValue> _topByTypeAndUnit(
    List<EstoqueMovModel> movs,
    String tipo,
    String unidade, {
    int topN = 5,
  }) {
    final map = <String, num>{};

    for (final m in movs) {
      if (m.tipo != tipo) continue;
      if (m.unidadeMedida != unidade) continue;

      final name = (m.produtoNome?.trim().isNotEmpty ?? false)
          ? m.produtoNome!.trim()
          : 'Sem nome';

      map[name] = (map[name] ?? 0) + m.quantidade;
    }

    final list = map.entries.map((e) => NamedValue(name: e.key, value: e.value, unidadeMedida: unidade,)).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return list.take(topN).toList();
  }

  List<NamedValue> _topLossesByUnit(
    List<EstoqueMovModel> movs,
    String unidade, {
    int topN = 5,
  }) {
    final map = <String, num>{};

    for (final m in movs) {
      final isLoss = m.tipo == EstoqueMovModel.tipoCancelamento ||
          m.tipo == EstoqueMovModel.tipoExclusao ||
          m.tipo == EstoqueMovModel.tipoDescarte;

      if (!isLoss) continue;
      if (m.unidadeMedida != unidade) continue;

      final name = (m.produtoNome?.trim().isNotEmpty ?? false)
          ? m.produtoNome!.trim()
          : 'Sem nome';

      map[name] = (map[name] ?? 0) + m.quantidade;
    }

    final list = map.entries.map((e) => NamedValue(name: e.key, value: e.value, unidadeMedida: unidade)).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return list.take(topN).toList();
  }

  static String _fmtQtd(num v, String un) {
    final txt = v % 1 == 0
        ? v.toInt().toString()
        : v.toStringAsFixed(3).replaceAll('.', ',');

    return '$txt $un';
  }

  static String _fmtMapQtd(Map<String, num> map) {
    if (map.isEmpty) return '0 un';

    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((e) => _fmtQtd(e.value, e.key)).join(' --- ');
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
    final topSoldUn = _topByTypeAndUnit(
      _filtered,
      EstoqueMovModel.tipoVenda,
      'un',
    );

    final topSoldKg = _topByTypeAndUnit(
      _filtered,
      EstoqueMovModel.tipoVenda,
      'kg',
    );

    final topLostUn = _topLossesByUnit(_filtered, 'un');
    final topLostKg = _topLossesByUnit(_filtered, 'kg');

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
                                label: 'Mais vendido (un)',
                                value: topSoldUn.isEmpty
                                    ? '—'
                                    : '${topSoldUn.first.name} (${_fmtQtd(topSoldUn.first.value, 'un')})',
                              ),
                              InsightLine(
                                label: 'Mais vendido (kg)',
                                value: topSoldKg.isEmpty
                                    ? '—'
                                    : '${topSoldKg.first.name} (${_fmtQtd(topSoldKg.first.value, 'kg')})',
                              ),
                              InsightLine(
                                label: 'Maior perda (un)',
                                value: topLostUn.isEmpty
                                    ? '—'
                                    : '${topLostUn.first.name} (${_fmtQtd(topLostUn.first.value, 'un')})',
                              ),
                              InsightLine(
                                label: 'Maior perda (kg)',
                                value: topLostKg.isEmpty
                                    ? '—'
                                    : '${topLostKg.first.name} (${_fmtQtd(topLostKg.first.value, 'kg')})',
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
                        topSoldUn: topSoldUn,
                        topSoldKg: topSoldKg,
                        topLostUn: topLostUn,
                        topLostKg: topLostKg,
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
              height: 1200,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RepaintBoundary(
                        key: _pieKeyPrint,
                        child: ChartOnlyPie(
                          movs: _filtered,
                          unidade: 'un',
                        ),
                      ),

                      const SizedBox(height: 12),

                      RepaintBoundary(
                        key: _pieKeyKgPrint,
                        child: ChartOnlyPie(
                          movs: _filtered,
                          unidade: 'kg',
                        ),
                      ),

                      const SizedBox(height: 12),

                      RepaintBoundary(
                        key: _barKeyPrint,
                        child: SizedBox(
                          height: 260,
                          child: TopSoldBarChart(
                            movs: _filtered,
                            unidade: 'un',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      RepaintBoundary(
                        key: _barKeyKgPrint,
                        child: SizedBox(
                          height: 260,
                          child: TopSoldBarChart(
                            movs: _filtered,
                            unidade: 'kg',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _computeKpis(List<EstoqueMovModel> movs) {
    final entradas = <String, num>{};
    final vendas = <String, num>{};
    final cancel = <String, num>{};
    final excl = <String, num>{};
    final ajusteEnt = <String, num>{};
    final ajusteSai = <String, num>{};

    void add(Map<String, num> map, EstoqueMovModel m) {
      final un = m.unidadeMedida.trim().isEmpty ? 'un' : m.unidadeMedida;
      map[un] = (map[un] ?? 0) + m.quantidade;
    }

    for (final m in movs) {
      if (m.tipo == EstoqueMovModel.tipoEntrada) add(entradas, m);
      if (m.tipo == EstoqueMovModel.tipoVenda) add(vendas, m);
      if (m.tipo == EstoqueMovModel.tipoCancelamento) add(cancel, m);
      if (m.tipo == EstoqueMovModel.tipoExclusao) add(excl, m);

      if (_hasAjusteEntrada(m)) add(ajusteEnt, m);
      if (_hasAjusteSaida(m)) add(ajusteSai, m);
    }

    Map<String, num> sumMaps(Map<String, num> a, Map<String, num> b) {
      final r = <String, num>{...a};
      for (final e in b.entries) {
        r[e.key] = (r[e.key] ?? 0) + e.value;
      }
      return r;
    }

    Map<String, num> subMaps(Map<String, num> a, Map<String, num> b) {
      final r = <String, num>{...a};
      for (final e in b.entries) {
        r[e.key] = (r[e.key] ?? 0) - e.value;
      }
      return r;
    }

    final perdas = sumMaps(cancel, excl);

    var saldo = sumMaps(entradas, ajusteEnt);
    saldo = subMaps(saldo, vendas);
    saldo = subMaps(saldo, perdas);
    saldo = subMaps(saldo, ajusteSai);

    final map = <String, String>{
      'Entradas': _fmtMapQtd(entradas),
      'Vendas': _fmtMapQtd(vendas),
      'Cancelamentos': _fmtMapQtd(cancel),
      'Exclusões': _fmtMapQtd(excl),
      'Perdas': _fmtMapQtd(perdas),
      'Saldo': _fmtMapQtd(saldo),
    };

    if (_existsTipoAjusteEntrada()) {
      map['Ajuste Entrada'] = _fmtMapQtd(ajusteEnt);
    }

    if (_existsTipoAjusteSaida()) {
      map['Ajuste Saída'] = _fmtMapQtd(ajusteSai);
    }

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

  
  Future<Uint8List> _buildPdfBytes({
    required DateTimeRange? range,
    required List<EstoqueMovModel> movs,
    required Uint8List? piePng,
    required Uint8List? pieKgPng,
    required Uint8List? barPng,
    required Uint8List? barKgPng,
  }) async {
    final kpis = _computeKpis(movs);

    final topSoldUn = _topByTypeAndUnit(
      movs,
      EstoqueMovModel.tipoVenda,
      'un',
      topN: 10,
    );

    final topSoldKg = _topByTypeAndUnit(
      movs,
      EstoqueMovModel.tipoVenda,
      'kg',
      topN: 10,
    );

    final topLostUn = _topLossesByUnit(
      movs,
      'un',
      topN: 10,
    );

    final topLostKg = _topLossesByUnit(
      movs,
      'kg',
      topN: 10,
    );

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
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),
          pw.Text('Período: $period'),

          pw.SizedBox(height: 12),

          pw.Text(
            'Gráficos',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

         if (piePng != null) ...[
            pw.Text(
              'Distribuição por tipo (un)',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(piePng),
                width: 300,
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          if (pieKgPng != null) ...[
            pw.Text(
              'Distribuição por tipo (kg)',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(pieKgPng),
                width: 300,
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          if (barPng != null) ...[
            pw.Text(
              'Top vendidos (un)',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(barPng),
                width: 300,
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          if (barKgPng != null) ...[
            pw.Text(
              'Top vendidos (kg)',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(barKgPng),
                width: 300,
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          pw.Text(
            'Resumo',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: kpis.entries.map((e) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(e.key),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text((e.value)),
                  ),
                ],
              );
            }).toList(),
          ),

          pw.SizedBox(height: 14),

          pw.Text(
            'Top produtos vendidos (un)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),
          _pdfRankTable(topSoldUn),

          pw.SizedBox(height: 14),

          pw.Text(
            'Top produtos vendidos (kg)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),
          _pdfRankTable(topSoldKg),

          pw.SizedBox(height: 14),

          pw.Text(
            'Top perdas (un)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),
          _pdfRankTable(topLostUn),

          pw.SizedBox(height: 14),

          pw.Text(
            'Top perdas (kg)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),
          _pdfRankTable(topLostKg),

          pw.SizedBox(height: 14),

          pw.Text(
            'Movimentações (amostra)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
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

                    _pdfCell(
                      (m.produtoNome?.trim().isNotEmpty ?? false)
                          ? m.produtoNome!.trim()
                          : 'Sem nome',
                    ),

                    _pdfCell(m.tipo),

                    _pdfCell(
                      _fmtQtd(
                        m.quantidade,
                        m.unidadeMedida,
                      ),
                    ),

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
              children: [_pdfCell(e.name), _pdfCell(
                _fmtQtd(
                  e.value,
                  e.unidadeMedida,
                ),
              )],
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

