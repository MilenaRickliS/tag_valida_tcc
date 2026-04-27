// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/auth_provider.dart';
import '../../widgets/menu.dart';
import 'widgets/home_menu_card_v2.dart';
import 'widgets/camera_fab_card.dart';
import 'widgets/produtos_status_card.dart';
import '../../data/sync/sync_service.dart';
import '../../models/etiqueta_model.dart';
import '../../providers/gerar_etiqueta_provider.dart';
import '../../services/sync_status_service.dart';
import '../../main.dart' show routeObserver;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  bool _syncedOnce = false;
  bool _syncing = false;

  bool _loadingIndicadores = false;
  int _qtdVencidas = 0;
  int _qtdAlerta = 0;

  DateTime? _lastSync;
  String _syncStatus = 'pending'; 

  @override
  void initState() {
    super.initState();
    _carregarStatusSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    if (_syncedOnce) return;
    _syncedOnce = true;

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await _carregarIndicadores(user.uid);

        if (!kIsWeb) {
          await _executarSincronizacaoAutomatica();
        }
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tts.stop();
    super.dispose();
  }

  @override
  void didPopNext() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _carregarIndicadores(user.uid);
    }

    if (!kIsWeb) {
      _executarSincronizacaoAutomatica();
    }
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> _ouvirResumoEtiquetas() async {
    await _tts.setLanguage("pt-BR");
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);

    String mensagem;

    if (_qtdVencidas > 0) {
      mensagem =
          "Atenção. Você possui $_qtdVencidas etiquetas vencidas e $_qtdAlerta em alerta.";
    } else if (_qtdAlerta > 0) {
      mensagem =
          "Nenhuma etiqueta vencida. Você possui $_qtdAlerta etiquetas em alerta.";
    } else {
      mensagem =
          "Tudo certo. Nenhuma etiqueta vencida e nenhuma etiqueta em alerta.";
    }

    await _tts.stop();
    await _tts.speak(mensagem);
  }

  Future<void> _carregarStatusSync() async {
    final data = await SyncStatusService.getStatus();

    if (!mounted) return;

    setState(() {
      _syncStatus = (data['status'] ?? 'pending').toString();

      final last = data['lastSync'];
      _lastSync = last is DateTime ? last : null;
    });
  }

  Future<void> _executarSincronizacaoAutomatica() async {
    if (kIsWeb) return;

    if (!mounted || _syncing) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _syncing = true);
    await SyncStatusService.setPending();

    try {
      // ignore: use_build_context_synchronously
      await context.read<SyncService>().syncNow(user.uid);
      await SyncStatusService.setSuccess();

      if (mounted) {
        setState(() {
          _syncStatus = 'success';
          _lastSync = DateTime.now();
        });
      }
    } catch (e) {
      await SyncStatusService.setError();

      if (mounted) {
        setState(() {
          _syncStatus = 'error';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }

    if (mounted) {
      await _carregarIndicadores(user.uid);
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
    final gerar = context.read<GerarEtiquetaProvider>();

    final List<EtiquetaModel> itens = await gerar.listByPeriodo(
      uid: uid,
      inicio: DateTime(2000, 1, 1),
      fim: DateTime(2100, 1, 1),
      status: "ativa",
      statusEstoque: "ativo",
      tipoId: null,
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
  } catch (e, st) {
    debugPrint('ERRO ao carregar indicadores HOME: $e');
    debugPrintStack(stackTrace: st);

    if (!mounted) return;
    setState(() {
      _qtdVencidas = 0;
      _qtdAlerta = 0;
    });
  } finally {
    if (mounted) {
      setState(() => _loadingIndicadores = false);
    }
  }
}

  int _gridColumns(double w) {
    if (w < 600) return 1;
    if (w < 1024) return 2;
    return 4;
  }

  double _gridAspect(double w) {
    if (w < 600) return 1.9;
    if (w < 1024) return 1.25;
    return 1.05;
  }

  double _contentMaxWidth(double w) {
    if (w < 600) return 520;
    if (w < 1024) return 860;
    return 1180;
  }

  String _formatarUltimaSync(DateTime? data) {
    if (data == null) return 'Aguardando sincronização...';

    final now = DateTime.now();
    final diff = now.difference(data);

    if (diff.inSeconds < 60) {
      return 'Última sincronização: agora';
    }
    if (diff.inMinutes < 60) {
      return 'Última sincronização: ${diff.inMinutes} min atrás';
    }
    if (diff.inHours < 24) {
      return 'Última sincronização: ${diff.inHours} h atrás';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return 'Última sincronização: $dia/$mes às $hora:$minuto';
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor;
    IconData iconData;
    String subtitle;

    switch (_syncStatus) {
      case 'success':
        iconColor = Colors.green;
        iconData = Icons.cloud_done_rounded;
        subtitle = _formatarUltimaSync(_lastSync);
        break;
      case 'error':
        iconColor = Colors.red;
        iconData = Icons.cloud_off_rounded;
        subtitle = _lastSync == null
            ? 'Falha na sincronização'
            : '${_formatarUltimaSync(_lastSync)} • última tentativa com erro';
        break;
      default:
        iconColor = Colors.grey;
        iconData = _syncing ? Icons.cloud_sync_rounded : Icons.cloud_queue_rounded;
        subtitle = _syncing
            ? 'Sincronizando dados...'
            : _formatarUltimaSync(_lastSync);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.85),
        border: Border.all(
          color: iconColor.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status da nuvem',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          if (!_syncing)
            IconButton(
              tooltip: 'Sincronizar agora',
              onPressed: _executarSincronizacaoAutomatica,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
    );
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
            final titleSize = isMobile ? 22.0 : (w < 1024 ? 24.0 : 26.0);
            final subtitleSize = isMobile ? 12.0 : 13.0;

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
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.35
                            : 0.25,
                      ),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        ProdutosStatusCard(
                          qtdVencidas: _qtdVencidas,
                          qtdAlerta: _qtdAlerta,
                          loading: _loadingIndicadores,
                          titleSize: titleSize,
                          subtitleSize: subtitleSize,
                          onOuvirResumo: _ouvirResumoEtiquetas,
                        ),
                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.center,
                          child: CameraFabCard(
                            width: isMobile ? double.infinity : 420,
                            height: 98,
                            onTap: () =>
                                Navigator.pushNamed(context, '/prever-validade'),
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
                              onTap: () =>
                                  Navigator.pushNamed(context, '/criar-etiqueta'),
                            ),
                            HomeMenuCardV2(
                              icon: Icons.check_circle_outline,
                              title: "Etiquetas ativas",
                              subtitle: "Veja as etiquetas ativas no estoque",
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/etiquetas-ativas',
                              ),
                            ),
                            HomeMenuCardV2(
                              icon: Icons.event_note_outlined,
                              title: "Etiquetas diárias",
                              subtitle: "Produtos feitos diariamente",
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/etiquetas-diarias',
                              ),
                            ),
                            HomeMenuCardV2(
                              icon: Icons.settings_outlined,
                              title: "Configurações",
                              subtitle: "Ajustes do aplicativo",
                              onTap: () =>
                                  Navigator.pushNamed(context, '/configuracoes'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!kIsWeb) ...[
                            if (_syncing) ...[
                              const LinearProgressIndicator(minHeight: 3),
                              const SizedBox(height: 12),
                            ],
                            _buildSyncStatusCard(context),
                          ],
                        
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