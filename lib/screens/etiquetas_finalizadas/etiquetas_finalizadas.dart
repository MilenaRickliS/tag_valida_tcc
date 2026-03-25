// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/menu.dart';
import './widgets/header_title.dart';
import './widgets/finalizadas_list.dart';
import './widgets/search_box.dart';

class EtiquetasFinalizadasScreen extends StatefulWidget {
  const EtiquetasFinalizadasScreen({super.key});

  @override
  State<EtiquetasFinalizadasScreen> createState() =>
      _EtiquetasFinalizadasScreenState();
}

class _EtiquetasFinalizadasScreenState
    extends State<EtiquetasFinalizadasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _searchCtrl = TextEditingController();
  String _q = "";

  bool _loadedArgs = false;
  String? _initialTab;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _border(BuildContext context) => _isDark(context)
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.08);

  Color _brand(BuildContext context) =>
      _isDark(context) ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _q = _searchCtrl.text));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _initialTab = args["tab"]?.toString();
    }

    final idx = switch (_initialTab) {
      "vendido" => 0,
      "cancelado" => 1,
      "todas" => 2,
      _ => 0,
    };
    _tabCtrl.index = idx;

    _loadedArgs = true;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: _bg(context),
        body: Center(
          child: Text(
            "Faça login novamente.",
            style: TextStyle(color: _text(context)),
          ),
        ),
      );
    }

    final isDark = _isDark(context);
    final bg = _bg(context);
    final card = _card(context);
    final border = _border(context);
    final brand = _brand(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: compact ? 120 : 92,
        title: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo6.png', height: 64),
                  const SizedBox(height: 8),
                  const TopMenu(),
                ],
              )
            : Row(
                children: [
                  Image.asset('assets/logo6.png', height: 72),
                  const Spacer(),
                  const TopMenu(),
                ],
              ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderTitle(),
                  const SizedBox(height: 12),
                  SearchBox(
                    controller: _searchCtrl,
                    onClear: () => _searchCtrl.clear(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: border),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicator: BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: isDark ? Colors.black : Colors.white,
                      unselectedLabelColor:
                          isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.75),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.w900),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "Vendidas"),
                        Tab(text: "Canceladas"),
                        Tab(text: "Todas"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        FinalizadasList(
                          uid: uid,
                          statusEstoqueFilter: "vendido",
                          query: _q,
                        ),
                        FinalizadasList(
                          uid: uid,
                          statusEstoqueFilter: "cancelado",
                          query: _q,
                        ),
                        FinalizadasList(
                          uid: uid,
                          statusEstoqueFilter: null,
                          query: _q,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
