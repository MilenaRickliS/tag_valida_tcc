// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/menu.dart';
import 'widgets/home_menu_card_v2.dart';
import 'widgets/camera_fab_card.dart';
import 'widgets/produtos_status_card.dart';
import '../../data/sync/sync_service.dart';
import '../../data/local/repos/etiquetas_local_repo.dart';
import '../../models/etiqueta_model.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware  {
  
  bool _syncedOnce = false;
  bool _syncing = false;

  bool _loadingIndicadores = false;
  int _qtdVencidas = 0;
  int _qtdAlerta = 0;

  @override
  void initState() {
    super.initState();
    
  }

   @override
    Future<void> didChangeDependencies() async {
      super.didChangeDependencies();

     
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        routeObserver.subscribe(this, route);
      }

      
      if (_syncedOnce) return;

      final user = context.read<AuthProvider>().user;
      if (user == null) return;
     
      // if (user != null) {
      //   await context.read<EtiquetasLocalRepo>().debugPrintEtiquetas(user.uid);
      // }

      _syncedOnce = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        setState(() => _syncing = true);

        try {
          await context.read<SyncService>().syncNow(user.uid);
        } catch (_) {
         
        } finally {
          if (mounted) setState(() => _syncing = false);
        }

        if (mounted) {
          await _carregarIndicadores(user.uid);
        }
      });
    }

    @override
    void dispose() {
      routeObserver.unsubscribe(this);
      super.dispose();
    }

  
    @override
    void didPopNext() {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _carregarIndicadores(user.uid);
      }
    }

  DateTime _hojeStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isVencida(DateTime val) {
    final hoje = _hojeStart();
    return val.isBefore(hoje);
  }

  bool _isAlerta(DateTime val) {
    final hoje = _hojeStart();
    return !val.isBefore(hoje) && val.difference(hoje).inDays <= 3;
  }

  Future<void> _carregarIndicadores(String uid) async {
    setState(() => _loadingIndicadores = true);

    try {
      final repo = context.read<EtiquetasLocalRepo>();

      final List<EtiquetaModel> itens = await repo.listByPeriodo(
        uid: uid,
        inicio: DateTime(2000, 1, 1),
        fim: DateTime(2100, 1, 1),
        status: "ativa",
        statusEstoque: "ativo",
      );

      int vencidas = 0;
      int alerta = 0;

      for (final e in itens) {
        if (e.quantidadeRestante <= 0) continue;

        final val = e.dataValidade;
        if (_isVencida(val)) {
          vencidas++;
        } else if (_isAlerta(val)) {
          alerta++;
        }
      }

      if (!mounted) return;
      setState(() {
        _qtdVencidas = vencidas;
        _qtdAlerta = alerta;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingIndicadores = false);
    }
  }

  int _gridColumns(double w) {
    if (w < 600) return 1;
    if (w < 1024) return 2;
    return 4;
  }

  double _gridAspect(double w) {
    if (w < 600) return 2.25;
    if (w < 1024) return 1.15;
    return 0.95;
  }

  double _contentMaxWidth(double w) {
    if (w < 600) return 520;
    if (w < 1024) return 860;
    return 1180;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      Future.microtask(() {
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      });
      return const SizedBox();
    }

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;
    

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = _gridColumns(w);
            final maxW = _contentMaxWidth(w);

            final isMobile = w < 600;
            final titleSize = isMobile ? 26.0 : (w < 1024 ? 30.0 : 34.0);
            final subtitleSize = isMobile ? 13.0 : 14.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 16 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                   
                      color: Theme.of(context).cardColor.withOpacity(
                        Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.25,
                      ),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        if (_syncing) ...[
                          const LinearProgressIndicator(minHeight: 3),
                          const SizedBox(height: 12),
                        ],

                        ProdutosStatusCard(
                          qtdVencidas: _qtdVencidas,
                          qtdAlerta: _qtdAlerta,
                          loading: _loadingIndicadores,
                          titleSize: titleSize,
                          subtitleSize: subtitleSize,
                        ),
                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.center,
                          child: CameraFabCard(
                            width: isMobile ? double.infinity : 420,
                            height: 98,
                            onTap: () => Navigator.pushNamed(context, '/prever-validade'),
                          ),
                        ),

                        const SizedBox(height: 22),

                        GridView.count(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: _gridAspect(w),
                          children: [
                            HomeMenuCardV2(
                              icon: Icons.add_circle_outline,
                              title: "Criar etiqueta",
                              subtitle: "Crie uma nova etiqueta para seus produtos",
                              onTap: () => Navigator.pushNamed(context, '/criar-etiqueta'),
                            ),
                            HomeMenuCardV2(
                              icon: Icons.check_circle_outline,
                              title: "Etiquetas ativas",
                              subtitle: "Veja as etiquetas ativas no estoque",
                              onTap: () => Navigator.pushNamed(context, '/etiquetas-ativas'),
                            ),
                            HomeMenuCardV2(
                              icon: Icons.event_note_outlined,
                              title: "Etiquetas diárias",
                              subtitle: "Produtos feitos diariamente",
                              onTap: () => Navigator.pushNamed(context, '/etiquetas-diarias'),
                            ),
                            HomeMenuCardV2(
                              icon: Icons.settings_outlined,
                              title: "Configurações",
                              subtitle: "Ajustes do aplicativo",
                              onTap: () => Navigator.pushNamed(context, '/configuracoes'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

