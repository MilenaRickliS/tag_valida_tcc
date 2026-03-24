// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/local/repos/etiquetas_local_repo.dart';
import '../../../models/tipo_etiqueta_model.dart';
import '../../../models/etiqueta_model.dart';
import './active_chips_row.dart';
import './filters_bar_pretty.dart';
import '../../../widgets/estoque_footer.dart';
import './filter_button_animated.dart';
import './icon_square_button.dart';
import './setor_section.dart';
import './empty_box.dart';

class EtiquetasPorTipoList extends StatefulWidget {
  final String uid;
  final String tipoId;
  final TipoEtiquetaModel? tipo;
  final String? initialStatusFiltro; 
  final bool showTop;
  final bool showFooter;
  final ValueChanged<bool> onShowTopChanged;
  final ValueChanged<bool> onShowFooterChanged;

  const EtiquetasPorTipoList({super.key, 
    required this.uid,
    required this.tipoId,
    required this.tipo,
    this.initialStatusFiltro, 
    required this.showTop, 
    required this.showFooter, 
    required this.onShowTopChanged, 
    required this.onShowFooterChanged,
  });

  @override
  State<EtiquetasPorTipoList> createState() => _EtiquetasPorTipoListState();
}

class _EtiquetasPorTipoListState extends State<EtiquetasPorTipoList> {
  final _searchCtrl = TextEditingController();
  String _q = "";

  bool _fBom = true;
  bool _fAlerta = true;
  bool _fVencido = true;

  String? _setorFiltro;
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();

  
    if (widget.initialStatusFiltro == "vencido") {
      _fBom = false;
      _fAlerta = false;
      _fVencido = true;
    } else if (widget.initialStatusFiltro == "alerta") {
      _fBom = false;
      _fAlerta = true;
      _fVencido = false;
    }

    _searchCtrl.addListener(() {
      setState(() => _q = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isVencida(DateTime val) {
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    return val.isBefore(hoje);
  }

  bool _isAlerta(DateTime val) {
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    return !val.isBefore(hoje) && val.difference(hoje).inDays <= 3;
  }

  bool _isBom(DateTime val) => !_isVencida(val) && !_isAlerta(val);

 
  List<ActiveChip> _buildActiveChips({
    required List<String> setores,
    required List<String> categorias,
  }) {
    final chips = <ActiveChip>[];

   
    final allStatus = _fBom && _fAlerta && _fVencido;
    if (!allStatus) {
      if (_fBom) chips.add(ActiveChip(text: "Bom"));
      if (_fAlerta) chips.add(ActiveChip(text: "Em alerta"));
      if (_fVencido) chips.add(ActiveChip(text: "Vencido"));
    }

    if (_setorFiltro != null) {
      chips.add(ActiveChip(
        text: "Setor: $_setorFiltro",
        onRemove: () => setState(() => _setorFiltro = null),
      ));
    }
    if (_categoriaFiltro != null) {
      chips.add(ActiveChip(
        text: "Categoria: $_categoriaFiltro",
        onRemove: () => setState(() => _categoriaFiltro = null),
      ));
    }

    if (_q.trim().isNotEmpty) {
      chips.add(ActiveChip(
        text: "Busca: ${_q.trim()}",
        onRemove: () => setState(() => _searchCtrl.clear()),
      ));
    }

   
    return chips;
  }

  void _clearAll() {
    setState(() {
      _fBom = true;
      _fAlerta = true;
      _fVencido = true;
      _setorFiltro = null;
      _categoriaFiltro = null;
      _searchCtrl.clear();
    });
  }


 void _openFiltersModal({
  required List<String> setores,
  required List<String> categorias,
  required Map<String, int> countBySetor,
  required Map<String, int> countByCategoria,
  required int countBom,
  required int countAlerta,
  required int countVencido,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final sheetBg = isDark ? const Color(0xFF111111) : const Color(0xFFFDF7ED);
  final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final border = isDark
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.08);
  final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
  final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.65);
  final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
  final onBrand = isDark ? Colors.black : Colors.white;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollCtrl) {
          return Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 26,
                  spreadRadius: 2,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.18)
                        : Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Filtros",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: text,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: "Fechar",
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? brand : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FiltersBarPretty(
                          fBom: _fBom,
                          fAlerta: _fAlerta,
                          fVencido: _fVencido,
                          onToggleBom: () => setState(() => _fBom = !_fBom),
                          onToggleAlerta: () => setState(() => _fAlerta = !_fAlerta),
                          onToggleVencido: () => setState(() => _fVencido = !_fVencido),
                          setores: setores,
                          categorias: categorias,
                          setorSelecionado: _setorFiltro,
                          categoriaSelecionada: _categoriaFiltro,
                          onSetorChanged: (v) => setState(() => _setorFiltro = v),
                          onCategoriaChanged: (v) => setState(() => _categoriaFiltro = v),
                          onClearAll: _clearAll,
                          countBySetor: countBySetor,
                          countByCategoria: countByCategoria,
                          countBom: countBom,
                          countAlerta: countAlerta,
                          countVencido: countVencido,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Text(
                            "Você pode combinar status + setor + categoria + busca.",
                            style: TextStyle(
                              color: muted,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: sheetBg,
                    border: Border(
                      top: BorderSide(color: border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            _clearAll();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(
                            Icons.restart_alt_rounded,
                            size: 18,
                            color: isDark ? const Color(0xFFD4AF37) : Colors.black,
                          ),
                          label: Text(
                            "Limpar",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFFD4AF37) : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand,
                            foregroundColor: onBrand,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: onBrand,
                          ),
                          label: const Text(
                            "Aplicar",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  Widget _topBar({
    required int activeCount,
    required VoidCallback onOpenFilters,
    required VoidCallback onClearFilters,
  }) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 600;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final border = isDark
            ? const Color(0xFFD4AF37).withOpacity(0.16)
            : Colors.black.withOpacity(0.08);
        final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.55);
        final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
        final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);

        final searchBox = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.20 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: isDark ? brand : muted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    hintText: "Pesquisar por nome do produto...",
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(color: muted),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: (_q.trim().isNotEmpty)
                    ? IconButton(
                        key: const ValueKey("clearSearch"),
                        tooltip: "Limpar busca",
                        onPressed: () => _searchCtrl.clear(),
                        icon: Icon(Icons.close_rounded, color: isDark ? brand : null),
                      )
                    : const SizedBox(
                        key: ValueKey("noClear"),
                        width: 0,
                        height: 0,
                      ),
              ),
            ],
          ),
        );

        final filtersBtn = FilterButtonAnimated(
          activeCount: activeCount,
          onPressed: onOpenFilters,
        );

        final clearBtn = IconSquareButton(
          tooltip: "Limpar tudo",
          icon: Icons.restart_alt_rounded,
          onPressed: onClearFilters,
        );

        if (!isNarrow) {
          return Row(
            children: [
              Expanded(child: searchBox),
              const SizedBox(width: 10),
              filtersBtn,
              const SizedBox(width: 8),
              clearBtn,
            ],
          );
        }

        
        return Column(
          children: [
            searchBox,
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: filtersBtn),
                const SizedBox(width: 10),
                clearBtn,
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<EtiquetasLocalRepo>();

    return FutureBuilder<List<EtiquetaModel>>(
      future: repo.listByPeriodo(
        uid: widget.uid,
        inicio: DateTime(2000, 1, 1),
        fim: DateTime(2100, 1, 1),
        status: "ativa",
        tipoId: widget.tipoId,
      ),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyBox(
            icon: Icons.error_outline,
            title: "Erro ao carregar",
            subtitle: snap.error.toString(),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var all = snap.data!;

        num entradasTotal = 0;
        num saidasTotal = 0;
        num geralTotal = 0;

        
        for (final e in all) {
          final qtd = e.quantidade;
          final rest = e.quantidadeRestante;
          final status = (e.statusEstoque.trim().isEmpty) ? "ativo" : e.statusEstoque.trim();

          entradasTotal += qtd;
          geralTotal += (status == "cancelado") ? 0 : rest;
          final saiu = (status == "cancelado") ? qtd : (qtd - rest);
          if (saiu > 0) saidasTotal += saiu;
        }

        if (all.isEmpty) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 14),
            children: [
              _topBar(activeCount: 0, onOpenFilters: () {}, onClearFilters: _clearAll),
              const SizedBox(height: 12),
              EmptyBox(
                icon: Icons.inbox_outlined,
                title: "Nenhuma etiqueta ativa",
                subtitle: (widget.tipo == null)
                    ? "Não há etiquetas ativas para este tipo."
                    : "Não há etiquetas ativas para “${widget.tipo!.nome}”.",
              ),
            ],
          );
        }

       
        all.sort((a, b) => a.dataValidade.compareTo(b.dataValidade));

        String setorKey(EtiquetaModel e) =>
            (e.setorNome.trim().isEmpty) ? "Sem setor" : e.setorNome.trim();

        String categoriaKey(EtiquetaModel e) => (e.categoriaNome.trim().isEmpty)
            ? "Sem categoria"
            : e.categoriaNome.trim();

        final setores = all.map(setorKey).toSet().toList()..sort();
        final categorias = all.map(categoriaKey).toSet().toList()..sort();

        if (_setorFiltro != null && !setores.contains(_setorFiltro)) {
          _setorFiltro = null;
        }
        if (_categoriaFiltro != null && !categorias.contains(_categoriaFiltro)) {
          _categoriaFiltro = null;
        }

        
        int countBom = 0, countAlerta = 0, countVencido = 0;
        final countBySetor = <String, int>{};
        final countByCategoria = <String, int>{};

        for (final e in all) {
          final val = e.dataValidade;
          if (_isVencida(val)) {
            countVencido++;
          } else if (_isAlerta(val)) {
            countAlerta++;
          } else {
            countBom++;
          }

          final s = setorKey(e);
          final c = categoriaKey(e);
          countBySetor[s] = (countBySetor[s] ?? 0) + 1;
          countByCategoria[c] = (countByCategoria[c] ?? 0) + 1;
        }

 
        int activeCount = 0;
        if (!(_fBom && _fAlerta && _fVencido)) {
          if (_fBom) activeCount++;
          if (_fAlerta) activeCount++;
          if (_fVencido) activeCount++;
        }
        if (_setorFiltro != null) activeCount++;
        if (_categoriaFiltro != null) activeCount++;
        if (_q.trim().isNotEmpty) activeCount++;

       
        final q = _q.trim().toLowerCase();
          var items = all.where((e) {
                  final st = (e.statusEstoque.trim().isEmpty)
              ? "ativo"
              : e.statusEstoque.trim().toLowerCase();

        
          if (st != "ativo") return false;
          final val = e.dataValidade;

          final okStatus = (_fVencido && _isVencida(val)) ||
              (_fAlerta && _isAlerta(val)) ||
              (_fBom && _isBom(val));
          if (!okStatus) return false;

          if (_setorFiltro != null && setorKey(e) != _setorFiltro) return false;
          if (_categoriaFiltro != null && categoriaKey(e) != _categoriaFiltro) {
            return false;
          }

          if (q.isNotEmpty) {
            final nome = (e.produtoNome).trim().toLowerCase();
            if (!nome.contains(q)) return false;
          }

          return true;
        }).toList();

        
        final activeChips = _buildActiveChips(setores: setores, categorias: categorias);

        if (items.isEmpty) {
          return Column(
            children: [
              _topBar(
                activeCount: activeCount,
                onOpenFilters: () => _openFiltersModal(
                  setores: setores,
                  categorias: categorias,
                  countBySetor: countBySetor,
                  countByCategoria: countByCategoria,
                  countBom: countBom,
                  countAlerta: countAlerta,
                  countVencido: countVencido,
                ),
                onClearFilters: _clearAll,
              ),
              if (activeChips.isNotEmpty) ...[
                const SizedBox(height: 10),
                ActiveChipsRow(
                  chips: activeChips,
                  onClearAll: _clearAll,
                ),
              ],
              const SizedBox(height: 12),
              const Expanded(
                child: EmptyBox(
                  icon: Icons.search_off_rounded,
                  title: "Nada encontrado",
                  subtitle: "Ajuste os filtros ou a busca.",
                ),
              ),
            ],
          );
        }

      
        final Map<String, Map<String, List<EtiquetaModel>>> grouped = {};
        for (final e in items) {
          final s = setorKey(e);
          final c = categoriaKey(e);
          grouped.putIfAbsent(s, () => {});
          grouped[s]!.putIfAbsent(c, () => []);
          grouped[s]![c]!.add(e);
        }

        DateTime minValidadeOf(List<EtiquetaModel> list) =>
            list.map((x) => x.dataValidade).reduce((a, b) => a.isBefore(b) ? a : b);

        final setoresOrdenados = grouped.entries.toList()
          ..sort((a, b) {
            final minA = minValidadeOf(a.value.values.expand((v) => v).toList());
            final minB = minValidadeOf(b.value.values.expand((v) => v).toList());
            return minA.compareTo(minB);
          });

        return ListView(
          padding: const EdgeInsets.only(bottom: 14),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
           
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: widget.showTop
                  ? Column(
                      children: [
                        _topBar(
                          activeCount: activeCount,
                          onOpenFilters: () => _openFiltersModal(
                            setores: setores,
                            categorias: categorias,
                            countBySetor: countBySetor,
                            countByCategoria: countByCategoria,
                            countBom: countBom,
                            countAlerta: countAlerta,
                            countVencido: countVencido,
                          ),
                          onClearFilters: _clearAll,
                        ),
                        if (activeChips.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ActiveChipsRow(
                            chips: activeChips,
                            onClearAll: _clearAll,
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

          
            for (final setorEntry in setoresOrdenados) ...[
              SetorSection(
                setorNome: setorEntry.key,
                categoriasMap: setorEntry.value,
                minValidadeOf: minValidadeOf,
                uid: widget.uid,
              ),
              const SizedBox(height: 12),
            ],

          
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: widget.showFooter
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: EstoqueFooter(
                        entradas: entradasTotal,
                        saidas: saidasTotal,
                        total: geralTotal,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
