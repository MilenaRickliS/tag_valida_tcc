import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'firebase_options.dart';
import 'services/firebase/firestore_paths.dart';

import 'providers/auth_provider.dart';

import 'data/local/repos/categorias_local_repo.dart';
import 'data/local/repos/setores_local_repo.dart';
import 'data/local/repos/tipos_etiqueta_local_repo.dart';
import 'data/local/repos/etiquetas_local_repo.dart';
import 'data/local/repos/estoque_mov_local_repo.dart';
import 'data/local/repos/etiqueta_template_local_repo.dart';
import 'data/local/repos/printer_config_local_repo.dart';
import 'data/local/repos/design_etiqueta_local_repo.dart';

import 'providers/categorias_provider.dart';
import 'providers/setores_provider.dart';
import 'providers/tipos_etiqueta_provider.dart';
import 'providers/estoque_mov_provider.dart';
import 'providers/gerar_etiqueta_provider.dart';
import 'providers/templates_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/printer_config_provider.dart';
import 'providers/design_etiqueta_provider.dart';

import 'theme/app_theme.dart';
import 'data/sync/sync_service.dart';

import 'screens/welcome/welcome.dart';
import 'screens/login/login.dart';
import 'screens/cadastro/cadastro.dart';
import 'screens/home/home.dart';
import 'screens/erro/erro_page.dart';
import 'screens/perfil/perfil.dart';
import 'screens/ajuda/ajuda.dart';
import 'screens/scanner_etiqueta/scanner_etiqueta.dart';
import 'screens/tipo_etiqueta/tipo_etiqueta.dart';
import 'screens/criar_etiqueta/criar_etiqueta.dart';
import 'screens/etiquetas_ativas/etiquetas_ativas.dart';
import 'screens/etiquetas_ativas/movimentacao/scan_movimentacao.dart';
import 'screens/etiquetas_ativas/inventario/scanner_inventario_screen.dart';
import 'screens/etiquetas_diarias/etiquetas_diarias.dart';
import 'screens/etiquetas_finalizadas/etiquetas_finalizadas.dart';
import 'screens/configuracoes/configuracoes.dart';
import 'screens/categorias/categorias.dart';
import 'screens/setores/setores.dart';
import 'screens/relatorios/relatorios.dart';
import 'screens/historico/historico.dart';
import 'screens/prever/prever.dart';
import 'screens/configuracoes_impressora/configuracoes_impressora_screen.dart';
import 'screens/resultado_previsao/resultado_previsao_screen.dart';
import 'screens/catalogo_alimentos/catalogo_alimentos.dart';
import 'screens/backup/backup_screen.dart';
import 'screens/etiqueta_qr_publico/etiqueta_qr_publico_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setUrlStrategy(PathUrlStrategy());
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(
    MultiProvider(
      providers: [
        Provider<FirestorePaths>(
          create: (_) => FirestorePaths(FirebaseFirestore.instance),
        ),

        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        
        Provider<CategoriasLocalRepo>(
          create: (_) => CategoriasLocalRepo(),
        ),
        Provider<SetoresLocalRepo>(
          create: (_) => SetoresLocalRepo(),
        ),
        Provider<TiposEtiquetaLocalRepo>(
          create: (_) => TiposEtiquetaLocalRepo(),
        ),
        Provider<EstoqueMovLocalRepo>(
          create: (_) => EstoqueMovLocalRepo(),
        ),
        Provider<EtiquetasLocalRepo>(
          create: (_) => EtiquetasLocalRepo(),
        ),
        Provider<EtiquetasTemplatesLocalRepo>(
          create: (_) => EtiquetasTemplatesLocalRepo(),
        ),

       
        ChangeNotifierProvider(
          create: (ctx) => CategoriasProvider(
            firestore: FirebaseFirestore.instance,
            localRepo: kIsWeb ? null : ctx.read<CategoriasLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SetoresProvider(
            firestore: FirebaseFirestore.instance,
            localRepo: kIsWeb ? null : ctx.read<SetoresLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TiposEtiquetaProvider(
            firestore: FirebaseFirestore.instance,
            localRepo: kIsWeb ? null : ctx.read<TiposEtiquetaLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider<EstoqueMovProvider>(
          create: (ctx) => EstoqueMovProvider(
            firestore: FirebaseFirestore.instance,
            repo: kIsWeb ? null : ctx.read<EstoqueMovLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TemplatesProvider(
            firestore: FirebaseFirestore.instance,
            repo: kIsWeb ? null : ctx.read<EtiquetasTemplatesLocalRepo>(),
          ),
        ),

     
        ChangeNotifierProvider<GerarEtiquetaProvider>(
          create: (ctx) => GerarEtiquetaProvider(
            firestore: FirebaseFirestore.instance,
            repo: kIsWeb ? null : ctx.read<EtiquetasLocalRepo>(),
            mov: ctx.read<EstoqueMovProvider>(),
            templateRepo: kIsWeb ? null : ctx.read<EtiquetasTemplatesLocalRepo>(),
          ),
        ),

        if (!kIsWeb) ...[
          Provider(
            create: (_) => SyncService(FirebaseFirestore.instance),
          ),
          Provider<PrinterConfigLocalRepo>(
            create: (_) => PrinterConfigLocalRepo(),
          ),
          ChangeNotifierProvider<PrinterConfigProvider>(
            create: (context) => PrinterConfigProvider(
              context.read<PrinterConfigLocalRepo>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => DesignEtiquetaProvider(
              repo: DesignEtiquetaLocalRepo(),
            ),
          ),
        ],
      ],
      child: const MyApp(),
    ),
  );
}

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorObservers: [routeObserver],
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'TagVálida',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      // initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/ajuda': (context) => const AjudaScreen(),
        '/scanner': (_) => const ScannerEtiquetaScreen(),
        '/tipos-etiqueta': (_) => const TiposEtiquetaScreen(),
        '/etiquetas-ativas': (context) => const EtiquetasAtivasScreen(),
        '/scanner_movimentacao': (_) => const ScannerMovimentacaoScreen(),
        '/inventario': (_) => const ScannerInventarioScreen(),
        '/etiquetas-diarias': (context) => const EtiquetasDiariasScreen(),
        '/etiquetas-finalizadas': (context) => const EtiquetasFinalizadasScreen(),
        '/configuracoes': (context) => const ConfiguracoesScreen(),
        '/categorias': (context) => const CategoriasScreen(),
        '/setores': (context) => const SetoresScreen(),
        '/historico': (context) => const HistoricoScreen(),
        '/prever-validade': (context) => const PreverValidadeScreen(),
        '/catalogo-alimentos': (context) => const CatalogoAlimentosScreen(),
        '/relatorios': (_) {
          final user = fb_auth.FirebaseAuth.instance.currentUser;
          if (user == null) return const LoginScreen();
          return RelatoriosScreen(uid: user.uid);
        },
        if (!kIsWeb)
          '/configuracoes-impressora': (_) =>
              const ConfiguracoesImpressoraScreen(),
        if (!kIsWeb)
          '/backup': (context) {
            final user = fb_auth.FirebaseAuth.instance.currentUser;
            if (user == null) return const LoginScreen();

            return BackupScreen(
              uid: user.uid,
              syncService: context.read<SyncService>(),
            );
          },
      },
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          FlutterError.dumpErrorToConsole(details);

          return ErrorPage(
            title: 'Erro na interface',
            message: '${details.exception}\n\n${details.stack}',
          );
        };
        return child!;
      },
      onGenerateRoute: (settings) {

        final uri = Uri.parse(settings.name ?? '');

        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'e') {
          final etiquetaId = uri.pathSegments[1];
          final uid = uri.queryParameters['uid'];

          if (uid == null || uid.isEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ErrorPage(
                title: 'QR inválido',
                message: 'O link público da etiqueta não possui UID.',
              ),
            );
          }

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => EtiquetaPublicaScreen(
              uid: uid,
              etiquetaId: etiquetaId,
            ),
          );
        }

        if (settings.name == '/criar-etiqueta') {
          final args = (settings.arguments as Map?) ?? {};

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CriarEtiquetaScreen(
              templateId: args['templateId']?.toString(),
              editarEtiquetaId: args['editarEtiquetaId']?.toString(),
            ),
          );
        }

        if (settings.name == '/resultado-previsao') {
          final args = (settings.arguments as Map?) ?? {};

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ResultadoPrevisaoScreen(
              imagemPath: (args['imagemPath'] ?? '').toString(),
              resultado: Map<String, dynamic>.from(args['resultado'] ?? {}),
            ),
          );
        }

        if (settings.name == '/erro') {
          final args = (settings.arguments as Map?) ?? {};

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ErrorPage(
              title: args['title']?.toString(),
              message: args['message']?.toString(),
            ),
          );
        }

        return null;
      },
    );
  }
}