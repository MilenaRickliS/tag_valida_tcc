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
        id: 'teste_formatador_geral',
        tipoId: config.tipoEtiquetaId,
        tipoNome: config.tipoEtiquetaNome,
        produtoNome: 'Teste Campos',
        categoriaId: 'cat',
        categoriaNome: 'Testes',
        setorId: 'setor',
        setorNome: 'Produção',
        dataFabricacao: agora,
        dataValidade: agora.add(const Duration(days: 3)),
        camposCustomValores: {
          'text': {
            'tipo': 'text',
            'label': 'Text',
            'value': 'Campo texto normal',
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'text_g': {
            'tipo': 'multiline',
            'label': 'Text G',
            'value': 'Texto grande para testar quebra de linha na etiqueta',
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'int': {
            'tipo': 'integer',
            'label': 'Int',
            'value': 45,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'int_a': {
            'tipo': 'integer',
            'label': 'Int A',
            'value': 55,
            'prefixo': 'pct ',
            'sufixo': null,
            'casasDecimais': 2,
          },
          'int_d': {
            'tipo': 'integer',
            'label': 'Int D',
            'value': 5555,
            'prefixo': null,
            'sufixo': ' mg',
            'casasDecimais': 2,
          },
          'double': {
            'tipo': 'decimal',
            'label': 'Double',
            'value': 5.9,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'double_a': {
            'tipo': 'decimal',
            'label': 'Double A',
            'value': 5.6,
            'prefixo': 'cx ',
            'sufixo': null,
            'casasDecimais': 2,
          },
          'double_d': {
            'tipo': 'decimal',
            'label': 'Double D',
            'value': 55.6,
            'prefixo': null,
            'sufixo': ' un',
            'casasDecimais': 2,
          },
          'moeda': {
            'tipo': 'currency',
            'label': 'Moeda',
            'value': 85.33,
            'prefixo': 'R\$ ',
            'sufixo': null,
            'casasDecimais': 2,
          },
          'preco': {
            'tipo': 'priceMode',
            'label': 'Preço',
            'prefixo': 'R\$ ',
            'sufixo': null,
            'casasDecimais': 2,
            'value': {
              'valor': 599.66,
              'modo': 'kg',
            },
          },
          'data': {
            'tipo': 'date',
            'label': 'Data',
            'value': agora.millisecondsSinceEpoch,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          's_ou_n': {
            'tipo': 'bool',
            'label': 'S Ou N',
            'value': true,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'lote': {
            'tipo': 'text',
            'label': 'Lote',
            'value': 'PV-260526-261',
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
        },
        status: 'ativo',
        lote: 'L001',
        incluirTabelaNutricional: false,
        tabelaNutricional: null,
        quantidade: 10,
        quantidadeRestante: 10,
        unidadeMedida: 'un',
        statusEstoque: 'ativo',
        createdAt: agora,
      ),

      EtiquetaModel(
        id: 'teste_validade_alerta_kg',
        tipoId: config.tipoEtiquetaId,
        tipoNome: config.tipoEtiquetaNome,
        produtoNome: 'Produto por KG',
        categoriaId: 'cat',
        categoriaNome: 'Pesáveis',
        setorId: 'setor',
        setorNome: 'Estoque',
        dataFabricacao: agora,
        dataValidade: agora.add(const Duration(days: 1)),
        camposCustomValores: {
          'peso': {
            'tipo': 'decimal',
            'label': 'Peso',
            'value': 2.5,
            'prefixo': null,
            'sufixo': ' kg',
            'casasDecimais': 2,
          },
          'congelado': {
            'tipo': 'bool',
            'label': 'Congelado',
            'value': true,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'fracionado': {
            'tipo': 'bool',
            'label': 'Fracionado',
            'value': false,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'observacao': {
            'tipo': 'multiline',
            'label': 'Observação',
            'value': 'Produto próximo do vencimento',
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
        },
        status: 'alerta',
        lote: 'L002',
        incluirTabelaNutricional: false,
        tabelaNutricional: null,
        quantidade: 2.5,
        quantidadeRestante: 2.5,
        unidadeMedida: 'kg',
        statusEstoque: 'ativo',
        createdAt: agora,
      ),

      EtiquetaModel(
        id: 'teste_tabela_bool_unidades',
        tipoId: config.tipoEtiquetaId,
        tipoNome: config.tipoEtiquetaNome,
        produtoNome: 'Bolo de Chocolate',
        categoriaId: 'cat',
        categoriaNome: 'Bolos',
        setorId: 'setor',
        setorNome: 'Vendas',
        dataFabricacao: agora.subtract(const Duration(days: 2)),
        dataValidade: agora.subtract(const Duration(days: 1)),
        camposCustomValores: {
          'preco': {
            'tipo': 'priceMode',
            'label': 'Preço',
            'prefixo': 'R\$ ',
            'sufixo': null,
            'casasDecimais': 2,
            'value': {
              'valor': 39.90,
              'modo': 'kg',
            },
          },
          'peso': {
            'tipo': 'decimal',
            'label': 'Peso',
            'value': 850,
            'prefixo': null,
            'sufixo': ' g',
            'casasDecimais': 2,
          },
          'tem_lactose': {
            'tipo': 'bool',
            'label': 'Tem lactose',
            'value': true,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'sem_acucar': {
            'tipo': 'bool',
            'label': 'Sem açúcar',
            'value': false,
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
          'observacao': {
            'tipo': 'multiline',
            'label': 'Observação',
            'value': 'Produto com tabela nutricional',
            'prefixo': null,
            'sufixo': null,
            'casasDecimais': 2,
          },
        },
        status: 'vencida',
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
        quantidade: 2.5,
        quantidadeRestante: 2.5,
        unidadeMedida: 'kg',
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
        final qrTeste = 'https://tagvalida.web.app/e/${etiqueta.id}?uid=${userFake.uid}';
        if (config.preset == EtiquetaLayoutPreset.mm60x40) {
          await service.printEtiqueta60x40V2(
            design: config,
            etiqueta: etiqueta,
            usuario: userFake,
            qrData: qrTeste,
          );
        } else {
          if (etiqueta.incluirTabelaNutricional &&
            etiqueta.tabelaNutricional != null) {
          await service.printEtiqueta100x80ComTabelaNutricionalV2(
            design: config,
            etiqueta: etiqueta,
            usuario: userFake,
            qrData: qrTeste,
          );
        } else {
          await service.printEtiqueta100x80V2(
            design: config,
            etiqueta: etiqueta,
            usuario: userFake,
            qrData: qrTeste,
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
          uid: uid,
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
    final uid = context.watch<AuthProvider>().user?.uid;

    if (uid == null || uid.isEmpty) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text(
            'Faça login novamente.',
            style: TextStyle(color: text),
          ),
        ),
      );
    }
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
                        final provider = context.read<DesignEtiquetaV2Provider>();

                        final salvou = await provider.saveAtual(uid);
                        if (!salvou) return;

                        await provider.loadTipo(
                          tipo,
                          uid: uid,
                          preset: provider.preset,
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    TamanhoEtiquetaSelectorV2(
                      selected: designProvider.preset,
                      onChanged: (preset) async {
                          final provider = context.read<DesignEtiquetaV2Provider>();

                          final salvou = await provider.saveAtual(uid);
                          if (!salvou) return;


                          await provider.setPreset(preset, uid: uid);
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