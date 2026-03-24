// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tag_valida/screens/configuracoes_impressora/impressora_hub/widgets/animated_top_tab_bar.dart';

import '../../../widgets/menu.dart';
import '../configuracoes_impressora_screen.dart';
import '../../design_etiqueta/design_etiqueta_screen.dart';

class ImpressoraHubScreen extends StatefulWidget {
  const ImpressoraHubScreen({super.key});

  @override
  State<ImpressoraHubScreen> createState() => _ImpressoraHubScreenState();
}

class _ImpressoraHubScreenState extends State<ImpressoraHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _lightBg = Color(0xFFFDF7ED);
  static const _lightText = Color(0xFF2B2B2B);
  static const _lightAccent = Color(0xFFED7227);
  static const _lightAccent2 = Color(0xFF88BE8E);

  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkCard = Color(0xFF1E1E1E);
  static const _darkText = Colors.white;
  static const _gold = Color(0xFFD4AF37);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) => _isDark(context) ? _darkBg : _lightBg;
  Color _text(BuildContext context) =>
      _isDark(context) ? _darkText : _lightText;
  Color _card(BuildContext context) =>
      _isDark(context) ? _darkCard : Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final compact = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context),
        elevation: 0,
        automaticallyImplyLeading: true,
        toolbarHeight: compact ? 220 : 150,
        titleSpacing: 12,
        iconTheme: IconThemeData(color: isDark ? _gold : _lightText),
        title: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo6.png',
                        height: 64,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const TopMenu(),
                  const SizedBox(height: 14),
                  AnimatedTopTabBar(
                    controller: _tabController,
                    isDark: isDark,
                    cardColor: _card(context),
                    textColor: _text(context),
                    accent: _lightAccent,
                    accent2: _lightAccent2,
                    gold: _gold,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo6.png',
                        height: 76,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const Spacer(),
                      const TopMenu(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 520,
                    child: AnimatedTopTabBar(
                      controller: _tabController,
                      isDark: isDark,
                      cardColor: _card(context),
                      textColor: _text(context),
                      accent: _lightAccent,
                      accent2: _lightAccent2,
                      gold: _gold,
                    ),
                  ),
                ],
              ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          ConfiguracoesImpressoraScreen(),
          DesignEtiquetaScreen(),
        ],
      ),
    );
  }
}

