// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tipos_etiqueta_local_provider.dart';
import '../../models/tipo_etiqueta_model.dart';
import '../../widgets/menu.dart';
import './widgets/empty_box.dart';
import 'widgets/etiquetas_por_tipo_list.dart';
import 'widgets/tipos_chips.dart';
import './widgets/view_toggles.dart';

class EtiquetasAtivasScreen extends StatefulWidget {
  const EtiquetasAtivasScreen({super.key});

  @override
  State<EtiquetasAtivasScreen> createState() => _EtiquetasAtivasScreenState();
}

class _EtiquetasAtivasScreenState extends State<EtiquetasAtivasScreen> {
  bool _loaded = false;
  String? _tipoSelecionadoId;

   String? _statusFiltro;

  bool _showTop = true;
  bool _showFooter = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      context.read<TiposEtiquetaLocalProvider>().fetch(uid);
      _loaded = true;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _statusFiltro = args["statusFiltro"]?.toString();
    }

    _loaded = true;
  
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);

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

    final tiposProv = context.watch<TiposEtiquetaLocalProvider>();
    final tipos = tiposProv.items;

    if (_tipoSelecionadoId == null && tipos.isNotEmpty) {
      _tipoSelecionadoId = tipos.first.id;
    }

    final TipoEtiquetaModel? tipoAtual = (_tipoSelecionadoId == null)
        ? null
        : tipos.any((t) => t.id == _tipoSelecionadoId)
            ? tipos.firstWhere((t) => t.id == _tipoSelecionadoId)
            : null;

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
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final isNarrow = c.maxWidth < 600;

                    final titleWidget = Text(
                      _statusFiltro == "vencido"
                          ? "Produtos vencidos"
                          : _statusFiltro == "alerta"
                              ? "Produtos em alerta"
                              : "Etiquetas ativas",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    );

                    final refreshBtn = IconButton(
                      tooltip: "Atualizar tipos",
                      onPressed: tiposProv.loading
                          ? null
                          : () => context.read<TiposEtiquetaLocalProvider>().fetch(uid),
                      icon: tiposProv.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.refresh,
                              color: isDark ? const Color(0xFFD4AF37) : null,
                            ),
                    );

                    if (!isNarrow) {
                      return Row(
                        children: [
                          Expanded(child: titleWidget),
                          ViewToggles(
                            showTop: _showTop,
                            showFooter: _showFooter,
                            onToggleTop: () => setState(() => _showTop = !_showTop),
                            onToggleFooter: () => setState(() => _showFooter = !_showFooter),
                          ),
                          const SizedBox(width: 10),
                          refreshBtn,
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: titleWidget),
                            refreshBtn,
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child:  ViewToggles(
                            showTop: _showTop,
                            showFooter: _showFooter,
                            onToggleTop: () => setState(() => _showTop = !_showTop),
                            onToggleFooter: () => setState(() => _showFooter = !_showFooter),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  "Clique em um tipo para ver as etiquetas ativas dele.",
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 14),
                TiposChips(
                  loading: tiposProv.loading,
                  tipos: tipos,
                  selectedId: _tipoSelecionadoId,
                  onSelected: (id) => setState(() => _tipoSelecionadoId = id),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: (_tipoSelecionadoId == null)
                      ? const EmptyBox(
                          icon: Icons.label_outline,
                          title: "Nenhum tipo cadastrado",
                          subtitle: "Cadastre um tipo de etiqueta para começar.",
                        )
                      : EtiquetasPorTipoList(
                          uid: uid,
                          tipoId: _tipoSelecionadoId!,
                          tipo: tipoAtual,
                          initialStatusFiltro: _statusFiltro,
                          showTop: _showTop,
                          showFooter: _showFooter,
                          onShowTopChanged: (v) => setState(() => _showTop = v),
                          onShowFooterChanged: (v) => setState(() => _showFooter = v),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
