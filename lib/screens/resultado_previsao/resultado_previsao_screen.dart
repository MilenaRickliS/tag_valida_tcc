// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';

class ResultadoPrevisaoScreen extends StatefulWidget {
  final String imagemPath;
  final Map<String, dynamic> resultado;

  const ResultadoPrevisaoScreen({
    super.key,
    required this.imagemPath,
    required this.resultado,
  });

  @override
  State<ResultadoPrevisaoScreen> createState() =>
      _ResultadoPrevisaoScreenState();
}

class _ResultadoPrevisaoScreenState extends State<ResultadoPrevisaoScreen> {
    String _formatarNomeProduto(String nome) {
      switch (nome.toLowerCase().trim()) {
        case 'pao_frances':
          return 'Pão francês';
        case 'pao_forma':
          return 'Pão de forma';
        case 'queijo_mussarela':
          return 'Queijo mussarela';
        default:
          return nome
              .replaceAll('_', ' ')
              .split(' ')
              .map((e) =>
                  e.isEmpty ? e : e[0].toUpperCase() + e.substring(1))
              .join(' ');
      }
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted =
        isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.65);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.06);

    final root = widget.resultado;
    final data = ((root['data'] is Map<String, dynamic>)
        ? root['data'] as Map<String, dynamic>
        : root);

    final success = root['success'] ?? true;
    final message = (root['message'] ?? '').toString();
    final quantidadeDetectada = (data['quantidade_detectada'] as num?)?.toInt() ?? 0;
    final items = (data['items'] as List?) ?? [];

 
    final imagemResultadoUrl =
        (data['imagem_resultado_url'] ?? '').toString();

    final estadoGeral = _estadoDominante(items);
    final corPrincipal = _estadoColor(estadoGeral);
    final confiancaMedia = _confiancaMedia(items);
    final produtoPrincipal = _produtoPrincipal(items);

    

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Resultado da análise',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroResultado(
              isDark: isDark,
              textColor: text,
              mutedColor: muted,
              estadoGeral: estadoGeral,
              corPrincipal: corPrincipal,
              produtoPrincipal: produtoPrincipal,
              confiancaMedia: confiancaMedia,
              success: success == true,
              quantidadeDetectada: quantidadeDetectada,
            ),
            const SizedBox(height: 18),

           _buildImagemResultado(
              imageUrl: imagemResultadoUrl,
              fallbackPath: widget.imagemPath,
              cardColor: card,
              borderColor: border,
            ),
            const SizedBox(height: 18),

            _buildResumoRapido(
              card: card,
              border: border,
              text: text,
              muted: muted,
              quantidadeDetectada: quantidadeDetectada,
              confiancaMedia: confiancaMedia,
              estadoGeral: estadoGeral,
            ),
            const SizedBox(height: 18),

            _buildMensagemAnalise(
              card: card,
              border: border,
              text: text,
              muted: muted,
              message: message,
            ),
            const SizedBox(height: 18),

            _buildAcaoPrincipal(
              estado: estadoGeral,
              card: card,
              border: border,
              isDark: isDark,
            ),
            const SizedBox(height: 22),

            if (items.isNotEmpty) ...[
              Text(
                'Itens detectados',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Resumo individual de cada item identificado na imagem.',
                style: TextStyle(
                  fontSize: 14,
                  color: muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              ...items.map((item) {
                final map = Map<String, dynamic>.from(item as Map);
                final produtoRaw = (map['produto'] ?? 'Produto').toString();
                final produto = _formatarNomeProduto(produtoRaw);
                final estado = (map['estado'] ?? 'desconhecido').toString();
                final produtoConf = _toDouble(map['produto_conf']);
                final estadoConf = _toDouble(map['estado_conf']);

                return _ItemDetectadoCard(
                  produto: produto,
                  estado: estado,
                  produtoConf: produtoConf,
                  estadoConf: estadoConf,
                  text: text,
                  muted: muted,
                  card: card,
                  border: border,
                  isDark: isDark,
                  color: _estadoColor(estado),
                  tituloAcao: _acaoTituloStatic(estado),
                  descricaoAcao: _acaoDescricaoStatic(estado),
                  icon: _acaoIconeStatic(estado),
                );
              }),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Nenhum item foi detectado na imagem. Tente usar uma foto mais nítida, com boa iluminação e enquadramento mais próximo do produto.',
                        style: TextStyle(
                          color: text,
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            _buildValorSistema(
              card: card,
              border: border,
              text: text,
              muted: muted,
            ),
            const SizedBox(height: 30),
            // if (kDebugMode) ...[
            //   const SizedBox(height: 20),
            //   _buildSecaoTecnica(
            //     card: card,
            //     border: border,
            //     text: text,
            //     muted: muted,
            //     imagemResultado: imagemResultado,
            //     raw: widget.resultado.toString(),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroResultado({
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required String estadoGeral,
    required Color corPrincipal,
    required String produtoPrincipal,
    required double confiancaMedia,
    required bool success,
    required int quantidadeDetectada,
  }) {
    final tituloEstado = _tituloEstadoHero(estadoGeral);
    final subtitulo = produtoPrincipal.isNotEmpty
        ? '$produtoPrincipal em análise'
        : 'Resultado geral da inspeção';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            corPrincipal.withOpacity(isDark ? 0.28 : 0.18),
            corPrincipal.withOpacity(isDark ? 0.14 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: corPrincipal.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: corPrincipal.withOpacity(isDark ? 0.10 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: corPrincipal.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _estadoIcon(estadoGeral),
                  color: corPrincipal,
                  size: 30,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDark ? 0.08 : 0.55),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: corPrincipal.withOpacity(0.20),
                  ),
                ),
                child: Text(
                  success ? 'Análise concluída' : 'Falha na análise',
                  style: TextStyle(
                    color: corPrincipal,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            tituloEstado,
            style: TextStyle(
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: corPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _acaoDescricao(estadoGeral),
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                icon: Icons.inventory_2_rounded,
                label: '$quantidadeDetectada item(ns)',
                color: corPrincipal,
              ),
              _MetricChip(
                icon: Icons.analytics_rounded,
                label: '${confiancaMedia.toStringAsFixed(0)}% de confiança média',
                color: corPrincipal,
              ),
              _MetricChip(
                icon: Icons.verified_rounded,
                label: _acaoTitulo(estadoGeral),
                color: corPrincipal,
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildImagemResultado({
  required String imageUrl,
  required String fallbackPath,
  required Color cardColor,
  required Color borderColor,
}) {
  final fallbackFile = File(fallbackPath);

  Widget buildZoomableImage(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        panEnabled: true,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(24),
        child: SizedBox.expand(
          child: child,
        ),
      ),
    );
  }

  return Container(
    width: double.infinity,
    height: 340,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.03),
            child: imageUrl.isNotEmpty
                ? buildZoomableImage(
                    Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Image.file(
                          fallbackFile,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Text('Não foi possível carregar a imagem'),
                            );
                          },
                        );
                      },
                    ),
                  )
                : buildZoomableImage(
                    Image.file(
                      fallbackFile,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Text('Não foi possível carregar a imagem'),
                        );
                      },
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Use dois dedos para dar zoom',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildResumoRapido({
    required Color card,
    required Color border,
    required Color text,
    required Color muted,
    required int quantidadeDetectada,
    required double confiancaMedia,
    required String estadoGeral,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da análise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Informações principais para tomada de decisão.',
            style: TextStyle(
              fontSize: 14,
              color: muted,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ResumoBox(
                  icon: Icons.category_rounded,
                  titulo: 'Itens detectados',
                  valor: '$quantidadeDetectada',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResumoBox(
                  icon: Icons.speed_rounded,
                  titulo: 'Confiança média',
                  valor: '${confiancaMedia.toStringAsFixed(0)}%',
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResumoBox(
                  icon: _estadoIcon(estadoGeral),
                  titulo: 'Status geral',
                  valor: estadoGeral.toUpperCase(),
                  color: _estadoColor(estadoGeral),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMensagemAnalise({
    required Color card,
    required Color border,
    required Color text,
    required Color muted,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFED7227).withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFED7227),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mensagem da análise',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message.isNotEmpty
                      ? message
                      : 'A análise foi finalizada com sucesso.',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcaoPrincipal({
    required String estado,
    required Color card,
    required Color border,
    required bool isDark,
  }) {
    final color = _estadoColor(estado);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _AcaoRecomendadaCard(
        estado: estado,
        titulo: _acaoTitulo(estado),
        descricao: _acaoDescricao(estado),
        icon: _acaoIcone(estado),
        color: color,
        isDark: isDark,
      ),
    );
  }

  Widget _buildValorSistema({
    required Color card,
    required Color border,
    required Color text,
    required Color muted,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF54A73B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF54A73B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como essa análise ajuda o negócio',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essa verificação ajuda a reduzir perdas, apoiar decisões mais rápidas e evitar a exposição de produtos em condições inadequadas para venda.',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSecaoTecnica({
  //   required Color card,
  //   required Color border,
  //   required Color text,
  //   required Color muted,
  //   required String imagemResultado,
  //   required String raw,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: card,
  //       borderRadius: BorderRadius.circular(24),
  //       border: Border.all(color: border),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Detalhes técnicos (debug)',
  //           style: TextStyle(
  //             fontSize: 17,
  //             fontWeight: FontWeight.w800,
  //             color: text,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           'Imagem processada',
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: muted,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         SelectableText(
  //           imagemResultado,
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: text,
  //           ),
  //         ),
  //         const SizedBox(height: 14),
  //         Text(
  //           'Payload bruto',
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: muted,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         SelectableText(
  //           raw,
  //           style: TextStyle(
  //             fontSize: 12.5,
  //             color: muted,
  //             height: 1.4,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _estadoDominante(List items) {
    if (items.isEmpty) return 'desconhecido';

    final estados = items
        .map((e) => (Map<String, dynamic>.from(e as Map)['estado'] ?? '')
            .toString()
            .toLowerCase()
            .trim())
        .toList();

    if (estados.contains('vencido')) return 'vencido';
    if (estados.contains('alerta')) return 'alerta';
    if (estados.contains('bom')) return 'bom';
    return 'desconhecido';
  }

  String _produtoPrincipal(List items) {
    if (items.isEmpty) return '';
    final map = Map<String, dynamic>.from(items.first as Map);
    final raw = (map['produto'] ?? '').toString();
    return _formatarNomeProduto(raw);
  }

  double _confiancaMedia(List items) {
    if (items.isEmpty) return 0;

    double soma = 0;
    int count = 0;

    for (final item in items) {
      final map = Map<String, dynamic>.from(item as Map);
      final produtoConf = _toDouble(map['produto_conf']);
      final estadoConf = _toDouble(map['estado_conf']);

      if (produtoConf > 0) {
        soma += produtoConf;
        count++;
      }
      if (estadoConf > 0) {
        soma += estadoConf;
        count++;
      }
    }

    if (count == 0) return 0;
    return soma / count;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll('%', '').trim()) ?? 0;
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return const Color(0xFF54A73B);
      case 'alerta':
        return const Color(0xFFED7227);
      case 'vencido':
        return const Color(0xFFE53935);
      default:
        return Colors.blueGrey;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return Icons.check_circle_rounded;
      case 'alerta':
        return Icons.warning_amber_rounded;
      case 'vencido':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _tituloEstadoHero(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return 'Produto em bom estado';
      case 'alerta':
        return 'Produto em estado de alerta';
      case 'vencido':
        return 'Produto fora do padrão';
      default:
        return 'Resultado inconclusivo';
    }
  }

  String _acaoTitulo(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Tire da venda';
      case 'alerta':
        return 'Priorizar venda';
      case 'bom':
        return 'Apto para venda';
      default:
        return 'Revisão necessária';
    }
  }

  String _acaoDescricao(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Este item apresenta condição incompatível com a comercialização. Recomendamos retirar da área de venda e seguir o procedimento interno de avaliação ou descarte.';
      case 'alerta':
        return 'Este item exige atenção. Recomendamos priorizar sua saída, revisar sua condição e manter acompanhamento mais próximo para evitar perdas.';
      case 'bom':
        return 'Este item apresenta condição adequada para comercialização no momento. Mantenha o monitoramento dentro da rotina padrão da operação.';
      default:
        return 'Não foi possível definir uma ação automática com segurança. Faça uma conferência manual do item.';
    }
  }

  IconData _acaoIcone(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return Icons.block_rounded;
      case 'alerta':
        return Icons.priority_high_rounded;
      case 'bom':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  static String _acaoTituloStatic(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Tire da venda';
      case 'alerta':
        return 'Priorizar venda';
      case 'bom':
        return 'Apto para venda';
      default:
        return 'Revisão necessária';
    }
  }

  static String _acaoDescricaoStatic(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Remova o item da área de venda e faça a conferência do procedimento interno.';
      case 'alerta':
        return 'Priorize a saída deste item e acompanhe sua condição com mais frequência.';
      case 'bom':
        return 'Item em condição adequada para comercialização.';
      default:
        return 'Faça conferência manual para validar a condição real do item.';
    }
  }

  static IconData _acaoIconeStatic(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return Icons.block_rounded;
      case 'alerta':
        return Icons.priority_high_rounded;
      case 'bom':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoBox extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final Color color;

  const _ResumoBox({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black.withOpacity(0.60),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDetectadoCard extends StatelessWidget {
  final String produto;
  final String estado;
  final double produtoConf;
  final double estadoConf;
  final Color text;
  final Color muted;
  final Color card;
  final Color border;
  final bool isDark;
  final Color color;
  final String tituloAcao;
  final String descricaoAcao;
  final IconData icon;

  const _ItemDetectadoCard({
    required this.produto,
    required this.estado,
    required this.produtoConf,
    required this.estadoConf,
    required this.text,
    required this.muted,
    required this.card,
    required this.border,
    required this.isDark,
    required this.color,
    required this.tituloAcao,
    required this.descricaoAcao,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final confiancaMediaItem = _mediaConfianca(produtoConf, estadoConf);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  produto,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.20)),
                ),
                child: Text(
                  estado.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _InfoLinha(
            titulo: 'Confiança geral',
            valor: '${confiancaMediaItem.toStringAsFixed(0)}%',
            textColor: text,
            mutedColor: muted,
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (confiancaMediaItem.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    produto,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: text,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withOpacity(0.20)),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }

  double _mediaConfianca(double a, double b) {
    if (a <= 0 && b <= 0) return 0;
    if (a <= 0) return b;
    if (b <= 0) return a;
    return (a + b) / 2;
  }
}

class _InfoLinha extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color textColor;
  final Color mutedColor;

  const _InfoLinha({
    required this.titulo,
    required this.valor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              color: mutedColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AcaoRecomendadaCard extends StatelessWidget {
  final String estado;
  final String titulo;
  final String descricao;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _AcaoRecomendadaCard({
    required this.estado,
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.32 : 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ação recomendada',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
