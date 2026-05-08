// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/tipos_etiqueta_provider.dart';
import '../../models/etiqueta_layout_preset.dart';
import '../../models/etiqueta_model.dart';
import '../../models/user_model.dart';
import '../../models/tabela_nutricional_model.dart';
import '../../services/printer/elgin_l42_network_service_v2.dart';
import '../../providers/design_etiqueta_v2_provider.dart';
import 'widgets/tipo_selector_v2.dart';
import 'widgets/empty_tipos_card_v2.dart';
import 'widgets/loading_card_v2.dart';
import 'widgets/top_header_v2.dart';
import 'widgets/preview_panel_v2.dart';
import 'widgets/config_panel_v2.dart';
import 'widgets/tamanho_etiqueta_selector_v2.dart';

class DesignEtiquetaV2Screen extends StatefulWidget {
  const DesignEtiquetaV2Screen({super.key});

  @override
  State<DesignEtiquetaV2Screen> createState() => _DesignEtiquetaV2ScreenState();
}

class _DesignEtiquetaV2ScreenState extends State<DesignEtiquetaV2Screen> {
  static const _lightBg = Color(0xFFFDF7ED);
  static const _lightText = Color(0xFF2B2B2B);
  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkCard = Color(0xFF1A1A1A);
  static const _darkText = Colors.white;
  static const _gold = Color(0xFFD4AF37);

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> _imprimirTesteV2(BuildContext context) async {
    final designProvider = context.read<DesignEtiquetaV2Provider>();
    final config = designProvider.config;

    if (config == null) return;

    try {
      final service = ElginL42NetworkServiceV2(
        ip: '10.0.0.108',
        port: 9100,
      );

      final conectado = await service.testConnection();
      if (!conectado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar na impressora')),
        );
        return;
      }

      final agora = DateTime.now();

      final etiquetasTeste = [
     
        EtiquetaModel(
          id: 'teste_bom',
          tipoId: config.tipoEtiquetaId,
          tipoNome: config.tipoEtiquetaNome,
          produtoNome: 'Pão Francês',
          categoriaId: 'cat',
          categoriaNome: 'Pães',
          setorId: 'setor',
          setorNome: 'Produção',
          dataFabricacao: agora,
          dataValidade: agora.add(const Duration(days: 3)),
          camposCustomValores: const {
            'observacao': 'Produto fresco do dia',
          },
          status: 'ativo',
          lote: 'L001',
          incluirTabelaNutricional: false,
          tabelaNutricional: null,
          quantidade: 10,
          quantidadeRestante: 10,
          statusEstoque: 'ativo',
          createdAt: agora,
        ),

       
        EtiquetaModel(
          id: 'teste_alerta',
          tipoId: config.tipoEtiquetaId,
          tipoNome: config.tipoEtiquetaNome,
          produtoNome: 'Croissant',
          categoriaId: 'cat',
          categoriaNome: 'Folhados',
          setorId: 'setor',
          setorNome: 'Produção',
          dataFabricacao: agora.subtract(const Duration(days: 1)),
          dataValidade: agora.add(const Duration(days: 1)),
          camposCustomValores: const {
            'observacao': 'Consumir rápido',
          },
          status: 'ativo',
          lote: 'L002',
          incluirTabelaNutricional: false,
          tabelaNutricional: null,
          quantidade: 5,
          quantidadeRestante: 5,
          statusEstoque: 'ativo',
          createdAt: agora,
        ),

        
        EtiquetaModel(
          id: 'teste_tabela',
          tipoId: config.tipoEtiquetaId,
          tipoNome: config.tipoEtiquetaNome,
          produtoNome: 'Bolo de Chocolate',
          categoriaId: 'cat',
          categoriaNome: 'Bolos',
          setorId: 'setor',
          setorNome: 'Vendas',
          dataFabricacao: agora.subtract(const Duration(days: 2)),
          dataValidade: agora.subtract(const Duration(days: 1)),
          camposCustomValores: const {
            'observacao': 'Produto com tabela nutricional',
          },
          status: 'ativo',
          lote: 'L003',
          incluirTabelaNutricional: true,
          tabelaNutricional: TabelaNutricionalModel(
            porcoesPorEmbalagem: 10,
            porcao: '60',
            quantidadeMedida: '1',
            medidaCaseira: 'fatia',
            valorEnergetico: 180,
            carboidratos: 28,
            acucaresTotais: 12,
            acucaresAdicionados: 8,
            proteinas: 4,
            gordurasTotais: 6,
            gordurasSaturadas: 2,
            gordurasTrans: 0,
            fibraAlimentar: 1.5,
            sodio: 120,
          ),
          quantidade: 2,
          quantidadeRestante: 2,
          statusEstoque: 'ativo',
          createdAt: agora,
        ),
      ];

      final userFake = UserModel(
        uid: '1',
        nome: 'Padaria Teste',
        razao: 'PADARIA TESTE LTDA',
        email: 'teste@tagvalida.com',
        cnpj: '12.123.456/0001-90',
        cep: '85000-000',
        rua: 'Rua Exemplo',
        numero: '123',
        bairro: 'Centro',
        complemento: '',
        cidade: 'Guarapuava',
        estado: 'PR',
        telefone: '',
        responsavel: 'Responsável Teste',
        logo: '',
      );

      for (final etiqueta in etiquetasTeste) {
        if (config.preset == EtiquetaLayoutPreset.mm60x40) {
          await service.printEtiqueta60x40V2(
            design: config,
            etiqueta: etiqueta,
            usuario: userFake,
            qrData: etiqueta.id,
          );
        } else {
          if (etiqueta.incluirTabelaNutricional &&
            etiqueta.tabelaNutricional != null) {
          await service.printEtiqueta100x80ComTabelaNutricionalV2(
            design: config,
            etiqueta: etiqueta,
            usuario: userFake,
            qrData: etiqueta.id,
          );
        } else {
          await service.printEtiqueta100x80V2(
            design: config,
            etiqueta: etiqueta,
            usuario: userFake,
            qrData: etiqueta.id,
          );
        }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impressão enviada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final designProvider = context.read<DesignEtiquetaV2Provider>();
      final tiposProvider = context.read<TiposEtiquetaProvider>();
      final authProvider = context.read<AuthProvider>();

      final uid = authProvider.user?.uid;
      if (uid == null || uid.isEmpty) return;

      if (tiposProvider.items.isEmpty) {
        await tiposProvider.fetch(uid);
      }

      if (tiposProvider.items.isNotEmpty && designProvider.config == null) {
        await designProvider.loadTipo(
          tiposProvider.items.first,
          preset: EtiquetaLayoutPreset.mm60x40,
        );
      }
    });
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

    final tiposProvider = context.watch<TiposEtiquetaProvider>();
    final designProvider = context.watch<DesignEtiquetaV2Provider>();

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
                  buildTopHeaderV2(
                    card: card,
                    text: text,
                    muted: muted,
                    border: border,
                  ),
                  const SizedBox(height: 18),

                  if (tipos.isNotEmpty) ...[
                    TipoEtiquetaDesignSelectorV2(
                      tipos: tipos,
                      selectedId: designProvider.tipoSelecionado?.id,
                      onSelected: (tipo) async {
                        await context
                            .read<DesignEtiquetaV2Provider>()
                            .loadTipo(
                              tipo,
                              preset: context
                                  .read<DesignEtiquetaV2Provider>()
                                  .preset,
                            );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    TamanhoEtiquetaSelectorV2(
                      selected: designProvider.preset,
                      onChanged: (preset) async {
                        await context
                            .read<DesignEtiquetaV2Provider>()
                            .setPreset(preset);
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                  ],

                  if (tipos.isEmpty)
                    buildEmptyTiposCardV2(
                      card: card,
                      text: text,
                      muted: muted,
                      border: border,
                    )
                  else if (designProvider.loading || config == null)
                    buildLoadingCardV2(
                      card: card,
                      text: text,
                      muted: muted,
                      border: border,
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PreviewPanelV2(
                          isDark: isDark,
                          card: card,
                          text: text,
                          muted: muted,
                          border: border,
                          config: config,
                          actions: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFED7227),
                                side: const BorderSide(
                                  color: Color(0xFFED7227),
                                  width: 1.4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.print_rounded),
                              label: const Text(
                                'Imprimir teste',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              onPressed: () async {
                                await _imprimirTesteV2(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        buildConfigPanelV2(
                          context: context,
                          isDark: isDark,
                          card: card,
                          text: text,
                          muted: muted,
                          border: border,
                          config: config,
                          designProvider: designProvider,
                        ),
                        const SizedBox(height: 18),

                        
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
}