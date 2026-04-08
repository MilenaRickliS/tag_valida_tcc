// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/design_etiqueta_model.dart';
import '../../providers/design_etiqueta_provider.dart';
import '../../providers/tipos_etiqueta_local_provider.dart';
import '../../providers/auth_provider.dart';
import './widgets/tipo_selector.dart';
import './widgets/empty_tipos_card.dart';
import './widgets/config_panel.dart';
import './widgets/top_header.dart';
import './widgets/preview_panel.dart';
import './widgets/loading_card.dart';


class DesignEtiquetaScreen extends StatefulWidget {
  const DesignEtiquetaScreen({super.key});

  @override
  State<DesignEtiquetaScreen> createState() => _DesignEtiquetaScreenState();
}

class _DesignEtiquetaScreenState extends State<DesignEtiquetaScreen> {
  static const _lightBg = Color(0xFFFDF7ED);
  static const _lightText = Color(0xFF2B2B2B);
  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkCard = Color(0xFF1A1A1A);
  static const _darkText = Colors.white;
  static const _gold = Color(0xFFD4AF37);

  static const double _minLarguraMm = 20;
  static const double _maxLarguraMm = 111;
  static const double _minAlturaMm = 8;
  static const double _maxAlturaMm = 2000;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  final _larguraController = TextEditingController();
  final _alturaController = TextEditingController();

  @override
  void dispose() {
    _larguraController.removeListener(_onMedidasChanged);
    _alturaController.removeListener(_onMedidasChanged);
    _larguraController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _larguraController.addListener(_onMedidasChanged);
    _alturaController.addListener(_onMedidasChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final designProvider = context.read<DesignEtiquetaProvider>();
      final tiposProvider = context.read<TiposEtiquetaLocalProvider>();
      final authProvider = context.read<AuthProvider>();

      final uid = authProvider.user?.uid;
      if (uid == null || uid.isEmpty) return;

      if (tiposProvider.items.isEmpty) {
        await tiposProvider.fetch(uid);
      }

      if (tiposProvider.items.isNotEmpty && designProvider.config == null) {
        await designProvider.loadTipo(tiposProvider.items.first);
      }

      final config = designProvider.config;
      if (config != null) {
        _syncMedidasInputs(config);
      }
    });
  }

  void _syncMedidasInputs(DesignEtiquetaModel config) {
    _larguraController.text = config.larguraMm.toStringAsFixed(0);
    _alturaController.text = config.alturaMm.toStringAsFixed(0);
  }

    double _clampLargura(double value) {
    return value.clamp(_minLarguraMm, _maxLarguraMm).toDouble();
  }

  double _clampAltura(double value) {
    return value.clamp(_minAlturaMm, _maxAlturaMm).toDouble();
  }

  double? _parseMm(String text) {
    return double.tryParse(text.replaceAll(',', '.'));
  }

  void _onMedidasChanged() {
    final largura = _parseMm(_larguraController.text);
    final altura = _parseMm(_alturaController.text);

    if (largura == null || altura == null) return;

    final larguraClamped = _clampLargura(largura);
    final alturaClamped = _clampAltura(altura);

    final provider = context.read<DesignEtiquetaProvider>();
    provider.setLarguraMm(larguraClamped);
    provider.setAlturaMm(alturaClamped);
  }

  String? validarLargura(String? value) {
    final largura = _parseMm(value ?? '');
    if (largura == null) return 'Informe uma largura válida';
    if (largura < _minLarguraMm || largura > _maxLarguraMm) {
      return 'Largura entre ${_minLarguraMm.toInt()} e ${_maxLarguraMm.toInt()} mm';
    }
    return null;
  }

  String? validarAltura(String? value) {
    final altura = _parseMm(value ?? '');
    if (altura == null) return 'Informe uma altura válida';
    if (altura < _minAlturaMm || altura > _maxAlturaMm) {
      return 'Altura entre ${_minAlturaMm.toInt()} e ${_maxAlturaMm.toInt()} mm';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final bg = isDark ? _darkBg : _lightBg;
    final card = isDark ? _darkCard : Colors.white;
    final text = isDark ? _darkText : _lightText;
    final muted = text.withOpacity(0.70);
    final border = isDark
        ? _gold.withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    final tiposProvider = context.watch<TiposEtiquetaLocalProvider>();
    final designProvider = context.watch<DesignEtiquetaProvider>();

    final tipos = tiposProvider.items;
    final config = designProvider.config;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTopHeader(
                    card: card,
                    text: text,
                    muted: muted,
                    border: border,
                  ),
                  const SizedBox(height: 18),
                   if (tipos.isNotEmpty) ...[
                    TipoEtiquetaDesignSelector(
                      tipos: tipos,
                      selectedId: designProvider.tipoSelecionado?.id,
                     onSelected: (tipo) async {
                        await context.read<DesignEtiquetaProvider>().loadTipo(tipo);

                        final config = context.read<DesignEtiquetaProvider>().config;
                        if (config != null) {
                          _syncMedidasInputs(config);
                        }
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                  ],

                  if (tipos.isEmpty)
                    buildEmptyTiposCard(
                      card: card,
                      text: text,
                      muted: muted,
                      border: border,
                    )
                  else if (designProvider.loading || config == null)
                    buildLoadingCard(
                      card: card,
                      text: text,
                      muted: muted,
                      border: border,
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildPreviewPanel(
                          isDark: isDark,
                          card: card,
                          text: text,
                          muted: muted,
                          border: border,
                          config: config,
                        ),
                        const SizedBox(height: 18),
                        buildConfigPanel(
                          context: context, 
                          isDark: isDark,
                          card: card,
                          text: text,
                          muted: muted,
                          border: border,
                          config: config,
                          designProvider: designProvider,
                          larguraController: _larguraController,
                          alturaController: _alturaController,
                          
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String exampleValue(String id, String nome) {
  switch (id) {
    case 'empresa':
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90\nRua Exemplo, 123';
    case 'produto':
      return 'Pão Francês';
    case 'fabricacao':
      return '12/02/2025';
    case 'validade':
      return '12/02/2025';
    case 'categoria':
      return 'Pães';
    case 'setor':
      return 'Produção';
    case 'quantidade':
      return '20';
    case 'lote':
      return 'A2D3FD20';
    case 'observacao':
      return 'feito por alice';
    case 'preco':
      return '20,00';
    case 'ingredientes':
      return 'farinha de trigo, amido, creme, sal';
    case 'alergenicos':
      return 'farinha de trigo, creme de leite';
    case 'contem_gluten':
      return 'Sim';
    case 'contem_lactose':
      return 'Sim';
    case 'tabela_nutricional':
      return 'Tabela nutricional';
    case 'texto':
      return 'sdsad';
    case 'numero':
      return '12';
    case 'data':
      return '12/02/2025';
    default:
      return nome;
  }
}

String getValorExemplo(CampoDesignEtiquetaModel campo) {
  switch (campo.id) {
    case 'empresa':
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90\nRua Exemplo, 123';
    case 'produto':
      return 'Pão Francês';
    case 'fabricacao':
      return '12/02/2025';
    case 'validade':
      return '12/02/2025';
    case 'categoria':
      return 'Pães';
    case 'setor':
      return 'Produção';
    case 'quantidade':
      return '20';
    case 'lote':
      return 'A2D3FD20';
    case 'observacao':
      return 'feito por alice';
    case 'preco':
      return '20,00';
    case 'ingredientes':
      return 'farinha de trigo, amido, creme, sal, fds, sdkasl, saskdjsak';
    case 'alergenicos':
      return 'farinha de trigo, amido, creme de leite';
    case 'contem_gluten':
      return 'Sim';
    case 'contem_lactose':
      return 'Sim';
    case 'texto':
      return 'sdsad';
    case 'numero':
      return '12';
    case 'data':
      return '12/02/2025';
    case 'tabela_nutricional':
      return 'Tabela nutricional';
    default:
      if (campo.tipo == CampoDesignTipo.imagem) {
        return 'Imagem do produto';
      }
      return campo.nome;
  }
}
  

double maxFontForCampo(
  CampoDesignEtiquetaModel campo,
  DesignEtiquetaModel config,
) {
  final visibleCount = config.campos.where((c) => c.visivel).length;
  final area = config.larguraMm * config.alturaMm;

  double baseMax;
  double minFont = 8;

  if (area <= 2400) {
    baseMax = visibleCount <= 4 ? 18 : 14;
  } else if (area <= 5000) {
    baseMax = visibleCount <= 6 ? 22 : 18;
  } else {
    baseMax = visibleCount <= 8 ? 26 : 22;
  }


  if (campo.id == 'produto') {
    return baseMax.clamp(12, 28).toDouble();
  }

 
  if (campo.id == 'empresa') {
    return (baseMax - 4).clamp(7, 14).toDouble();
  }

 
  if (campo.id == 'validade') {
    return (baseMax - 1).clamp(10, 20).toDouble();
  }

 
  if (campo.id == 'ingredientes' ||
      campo.id == 'alergenicos' ||
      campo.id == 'observacao') {
    return (baseMax - 4).clamp(8, 14).toDouble();
  }


  if (campo.tipo == CampoDesignTipo.qrcode) {
    return 0;
  }

  return (baseMax - 2).clamp(minFont, 18).toDouble();
}

  Alignment toAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.left:
      default:
        return Alignment.centerLeft;
    }
  }

  CrossAxisAlignment toCrossAxis(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.left:
      default:
        return CrossAxisAlignment.start;
    }
  }

}

