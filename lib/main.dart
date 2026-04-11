import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'firebase_options.dart';
import 'services/firestore_paths.dart';

import 'providers/auth_provider.dart';

import 'data/local/repos/categorias_local_repo.dart';
import 'data/local/repos/setores_local_repo.dart';
import 'data/local/repos/tipos_etiqueta_local_repo.dart';
import 'data/local/repos/etiquetas_local_repo.dart';
import 'data/local/repos/estoque_mov_local_repo.dart';
import 'data/local/repos/etiqueta_template_local_repo.dart';
import 'data/local/repos/printer_config_local_repo.dart';
import 'data/local/repos/design_etiqueta_local_repo.dart';

import 'providers/categorias_local_provider.dart';
import 'providers/setores_local_provider.dart';
import 'providers/tipos_etiqueta_local_provider.dart';
import 'providers/estoque_mov_local_provider.dart';
import 'providers/gerar_etiqueta_local_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

        Provider<CategoriasLocalRepo>(create: (_) => CategoriasLocalRepo()),
        Provider<SetoresLocalRepo>(create: (_) => SetoresLocalRepo()),
        Provider<TiposEtiquetaLocalRepo>(create: (_) => TiposEtiquetaLocalRepo()),
        Provider<EtiquetasLocalRepo>(create: (_) => EtiquetasLocalRepo()),
        Provider<EstoqueMovLocalRepo>(create: (_) => EstoqueMovLocalRepo()),
        Provider<EtiquetasTemplatesLocalRepo>(
          create: (_) => EtiquetasTemplatesLocalRepo(),
        ),

        ChangeNotifierProvider(
          create: (ctx) => CategoriasLocalProvider(
            repo: ctx.read<CategoriasLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SetoresLocalProvider(
            repo: ctx.read<SetoresLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TiposEtiquetaLocalProvider(
            repo: ctx.read<TiposEtiquetaLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider<EstoqueMovLocalProvider>(
          create: (ctx) => EstoqueMovLocalProvider(
            repo: ctx.read<EstoqueMovLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TemplatesProvider(
            repo: ctx.read<EtiquetasTemplatesLocalRepo>(),
          ),
        ),
        ChangeNotifierProvider<GerarEtiquetaLocalProvider>(
          create: (ctx) => GerarEtiquetaLocalProvider(
            repo: ctx.read<EtiquetasLocalRepo>(),
            mov: ctx.read<EstoqueMovLocalProvider>(),
            templateRepo: ctx.read<EtiquetasTemplatesLocalRepo>(),
          ),
        ),

        Provider(
          create: (_) => SyncService(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/home': (context) => const HomeScreen(),
        '/erro': (context) => const ErrorPage(),
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
        '/configuracoes-impressora': (_) => const ConfiguracoesImpressoraScreen(),
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
          return ErrorPage(
            title: 'Erro na interface',
            message: details.exception.toString(),
          );
        };
        return child!;
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/criar-etiqueta') {
          final args = (settings.arguments as Map?) ?? {};

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CriarEtiquetaScreen(
              templateId: args['templateId'] as String?,
              editarEtiquetaId: args['editarEtiquetaId'] as String?,
            ),
          );
        }

        if (settings.name == '/resultado-previsao') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ResultadoPrevisaoScreen(
              imagemPath: args['imagemPath'] as String,
              resultado: args['resultado'] as Map<String, dynamic>,
            ),
          );
        }

        return null;
      },
    );
  }
}