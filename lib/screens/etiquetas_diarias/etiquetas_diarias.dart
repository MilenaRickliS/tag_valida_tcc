// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/templates_provider.dart';
import '../../widgets/menu.dart';
import './widgets/template_card.dart';
import './widgets/templates_empty_state.dart';
import './widgets/templates_header.dart';

class EtiquetasDiariasScreen extends StatefulWidget {
  const EtiquetasDiariasScreen({super.key});

  @override
  State<EtiquetasDiariasScreen> createState() => _EtiquetasDiariasScreenState();
}

class _EtiquetasDiariasScreenState extends State<EtiquetasDiariasScreen> {
  bool _loaded = false;

  final _searchCtrl = TextEditingController();
  String _query = "";
  String? _setorSel;
  String? _categoriaSel;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      context.read<TemplatesProvider>().fetch(uid);
      _loaded = true;
    }
  }

  String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r"\s+"), " ").trim();

  bool _match(String value, String query) {
    if (query.isEmpty) return true;
    return _norm(value).contains(_norm(query));
  }

  void _clearAll() {
    setState(() {
      _searchCtrl.clear();
      _setorSel = null;
      _categoriaSel = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardAlt = isDark ? const Color(0xFF181818) : const Color(0xFFFAF7F1);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.65);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.06);
    final gold = const Color(0xFFD4AF37);

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text(
            "Faça login novamente.",
            style: TextStyle(color: text),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: compact ? 104 : 92,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset('assets/logo6.png', height: compact ? 56 : 72),
            const Spacer(),
            const TopMenu(),
          ],
        ),
      ),
      body: Consumer<TemplatesProvider>(
        builder: (_, p, __) {
          if (p.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (p.items.isEmpty) {
            return TemplatesEmptyState(
              icon: Icons.inventory_2_outlined,
              title: "Nenhum modelo salvo ainda.",
              subtitle:
                  "Crie uma etiqueta normal e ela aparece aqui como modelo diário para lançar mais rápido no estoque.",
              onRefresh: () => p.fetch(uid),
            );
          }

          final setores = <String>{
            for (final x in p.items) x.setorNome.trim()
          }.where((e) => e.isNotEmpty).toList()
            ..sort();

          final categorias = <String>{
            for (final x in p.items) x.categoriaNome.trim()
          }.where((e) => e.isNotEmpty).toList()
            ..sort();

          final filtered = p.items.where((t) {
            final okNome = _match(t.produtoNome, _query);
            final okSetor = _setorSel == null || t.setorNome == _setorSel;
            final okCat = _categoriaSel == null || t.categoriaNome == _categoriaSel;
            return okNome && okSetor && okCat;
          }).toList();

          final isPhone = w < 560;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: TemplatesHeader(
                    isDark: isDark,
                    card: card,
                    cardAlt: cardAlt,
                    text: text,
                    muted: muted,
                    border: border,
                    gold: gold,
                    searchCtrl: _searchCtrl,
                    query: _query,
                    setorSel: _setorSel,
                    categoriaSel: _categoriaSel,
                    setores: setores,
                    categorias: categorias,
                    filteredCount: filtered.length,
                    onRefresh: () => p.fetch(uid),
                    onClearAll: _clearAll,
                    onSetorChanged: (v) => setState(() => _setorSel = v),
                    onCategoriaChanged: (v) => setState(() => _categoriaSel = v),
                    onClearSearch: () {
                      _searchCtrl.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: TemplatesEmptyState(
                    icon: Icons.search_off_rounded,
                    title: "Nada por aqui…",
                    subtitle: "Tente ajustar a pesquisa ou limpe os filtros.",
                    onRefresh: () => p.fetch(uid),
                  ),
                )
              else if (isPhone)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final t = filtered[i];
                      return TemplateCard(
                        dense: true,
                        produtoNome: t.produtoNome,
                        linha2: "${t.tipoNome} • ${t.categoriaNome}",
                        linha3: t.setorNome,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/criar-etiqueta",
                            arguments: {"templateId": t.id},
                          );
                        },
                        onDelete: () async {
                          await context.read<TemplatesProvider>().delete(uid: uid, id: t.id);
                        },
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: w < 900 ? 1.35 : 1.55,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final t = filtered[i];
                        return TemplateCard(
                          dense: false,
                          produtoNome: t.produtoNome,
                          linha2: "${t.tipoNome} • ${t.categoriaNome}",
                          linha3: t.setorNome,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/criar-etiqueta",
                              arguments: {"templateId": t.id},
                            );
                          },
                          onDelete: () async {
                            await context.read<TemplatesProvider>().delete(uid: uid, id: t.id);
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
