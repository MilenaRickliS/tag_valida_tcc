// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tipos_etiqueta_provider.dart';
import '../../models/tipo_etiqueta_model.dart';
import '../../widgets/menu.dart';

import './criar_tipo_etiqueta_screen.dart';
import './widgets/tipos_etiqueta_list.dart';
import './widgets/novo_tipo_fab.dart';

class TiposEtiquetaScreen extends StatefulWidget {
  const TiposEtiquetaScreen({super.key});

  @override
  State<TiposEtiquetaScreen> createState() => _TiposEtiquetaScreenState();
}

class _TiposEtiquetaScreenState extends State<TiposEtiquetaScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    final uid = context.read<AuthProvider>().user?.uid;

    if (uid != null) {
      _loaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TiposEtiquetaProvider>().fetch(uid);
      });
    } else {
      _loaded = true;
    }
  }

  Future<void> _abrirCriarTipo(String uid, {TipoEtiquetaModel? tipo}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CriarTipoEtiquetaScreen(
          uid: uid,
          tipo: tipo,
        ),
      ),
    );

    if (!mounted) return;
    await context.read<TiposEtiquetaProvider>().fetch(uid);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String uid,
    TipoEtiquetaModel tipo,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir tipo?"),
        content: Text("Deseja excluir “${tipo.nome}”?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<TiposEtiquetaProvider>().delete(uid, tipo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted =
        isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);

    final fabBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final fabFg = brand;
    final fabBorder = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

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

    final prov = context.watch<TiposEtiquetaProvider>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: compact ? 160 : 100,
        centerTitle: true,
        title: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
      floatingActionButton: NovoTipoFab(
        isDark: isDark,
        brand: brand,
        backgroundColor: fabBg,
        foregroundColor: fabFg,
        borderColor: fabBorder,
        onPressed: () => _abrirCriarTipo(uid),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tipos de etiqueta",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Crie modelos com campos personalizados para gerar etiquetas rapidamente.",
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 16),
                TiposEtiquetaList(
                  loading: prov.loading,
                  items: prov.items,
                  mutedColor: muted,
                  onEdit: (tipo) => _abrirCriarTipo(uid, tipo: tipo),
                  onDelete: (tipo) => _confirmDelete(context, uid, tipo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}