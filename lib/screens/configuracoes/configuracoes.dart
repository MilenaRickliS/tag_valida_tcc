// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../widgets/menu.dart';
import '../configuracoes_impressora/impressora_hub/impressora_hub_screen.dart';
import '../configuracoes/widgets/config_tile.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD6D6D6)
          : Colors.black.withOpacity(0.60);

  Color _border(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD4AF37).withOpacity(0.16)
          : Colors.black.withOpacity(0.07);

 
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

    final bg = _bg(context);
    final card = _card(context);
    final text = _text(context);
    final muted = _muted(context);
    final border = _border(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isDark(context) ? 0.18 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Configurações",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Gerencie cadastros e preferências do sistema. Aqui você organiza categorias, setores, relatórios e ferramentas de backup.",
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final cols = width >= 900 ? 3 : (width >= 600 ? 2 : 1);

                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: cols == 1 ? 3.2 : 2.6,
                        children: [
                          ConfigTile(
                            icon: Icons.category_outlined,
                            title: "Categorias de produtos",
                            subtitle: "Cadastre e edite categorias",
                            onTap: () => Navigator.pushNamed(context, "/categorias"),
                          ),
                          ConfigTile(
                            icon: Icons.badge_outlined,
                            title: "Setores / Responsáveis",
                            subtitle: "Cadastre setores e responsáveis",
                            onTap: () => Navigator.pushNamed(context, "/setores"),
                          ),
                          ConfigTile(
                            icon: Icons.inventory_2_outlined,
                            title: "Etiquetas finalizadas",
                            subtitle: "Vendidas e canceladas",
                            onTap: () => Navigator.pushNamed(context, "/etiquetas-finalizadas"),
                          ),
                          ConfigTile(
                            icon: Icons.print_outlined,
                            title: "Configurações - Impressora",
                            subtitle: "Modelo, tamanho e ajustes",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ImpressoraHubScreen(),
                                ),
                              );
                            },
                          ),
                          ConfigTile(
                            icon: Icons.cloud_upload_outlined,
                            title: "Backup de dados",
                            subtitle: "Salve e restaure informações",
                            onTap: () => _soon(context),
                          ),
                          ConfigTile(
                            icon: Icons.bar_chart_outlined,
                            title: "Relatórios",
                            subtitle: "Resumo e exportações",
                            onTap: () => Navigator.pushNamed(context, "/relatorios"),
                          ),
                          ConfigTile(
                            icon: Icons.history_outlined,
                            title: "Histórico",
                            subtitle: "Ações e movimentações",
                            onTap: () => Navigator.pushNamed(context, "/historico"),
                          ),
                        ],
                      );
                    },
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

void _soon(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Em breve 👀"),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

