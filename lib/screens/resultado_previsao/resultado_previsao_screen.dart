// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/resultado_previsao_pdf_service.dart';
import './widgets/acao_principal.dart';
import './widgets/hero_resultado.dart';
import './widgets/imagem_resultado.dart';
import './widgets/item_detectado_card.dart';
import './widgets/mensagem_analise.dart';
import './widgets/resumo_rapido.dart';


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
  String? _pdfStatus;
  bool _gerandoPdf = false;
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

    void _setPdfStatus(String msg) {
      if (!mounted) return;
      setState(() {
        _pdfStatus = msg;
      });
    }

    Future<Uint8List?> _baixarImagemComBoundingBoxBytes(String imageUrl) async {
      try {
        debugPrint('Tentando baixar imagem da URL: $imageUrl');

        if (imageUrl.isEmpty) {
          debugPrint('URL da imagem está vazia');
          return null;
        }

        final response = await http.get(Uri.parse(imageUrl));

        debugPrint('Status code imagem: ${response.statusCode}');
        debugPrint('Headers imagem: ${response.headers}');

        if (response.statusCode != 200) return null;

        return response.bodyBytes;
      } catch (e, st) {
        debugPrint('Erro ao baixar imagem: $e');
        debugPrintStack(stackTrace: st);
        return null;
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

    final root = Map<String, dynamic>.from(widget.resultado);

    final rawData = root['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : root;

    final success = root['success'] ?? true;
    final message = (root['message'] ?? '').toString();
    final quantidadeDetectada = (data['quantidade_detectada'] as num?)?.toInt() ?? 0;
    final itemsRaw = data['items'];
    final items = itemsRaw is List ? itemsRaw : [];

 
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
       actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              if (_gerandoPdf) return;

              setState(() {
                _gerandoPdf = true;
                _pdfStatus = 'Iniciando geração do PDF...';
              });

              try {
                _setPdfStatus('Lendo dados do resultado...');

                final root = Map<String, dynamic>.from(widget.resultado);

                final rawData = root['data'];
                final data = rawData is Map
                    ? Map<String, dynamic>.from(rawData)
                    : root;

                _setPdfStatus('Obtendo URL da imagem processada...');

                final imagemResultadoUrl =
                    (data['imagem_resultado_url'] ?? '').toString();

                _setPdfStatus(
                  imagemResultadoUrl.isEmpty
                      ? 'URL da imagem está vazia. Gerando PDF sem imagem.'
                      : 'Baixando imagem processada...',
                );

                final imagemBytes =
                    await _baixarImagemComBoundingBoxBytes(imagemResultadoUrl);

                _setPdfStatus(
                  imagemBytes == null
                      ? 'Imagem não foi baixada. Tentando gerar PDF mesmo assim...'
                      : 'Imagem baixada com ${imagemBytes.length} bytes. Gerando PDF...',
                );

                await ResultadoPrevisaoPdfService.salvarPdf(
                  imagemPath: kIsWeb ? '' : widget.imagemPath,
                  imagemBytes: imagemBytes,
                  resultado: widget.resultado,
                );

                _setPdfStatus(
                  kIsWeb
                      ? 'PDF gerado. O navegador deve iniciar o download.'
                      : 'PDF gerado com sucesso.',
                );
              } catch (e, st) {
                _setPdfStatus('ERRO: $e\n\n$st');
              } finally {
                if (mounted) {
                  setState(() {
                    _gerandoPdf = false;
                  });
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE53935),
                    Color(0xFFED7227),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(
                      _gerandoPdf ? Icons.hourglass_top_rounded : Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _gerandoPdf ? 'Gerando...' : 'Gerar PDF',
                      style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeroResultado(
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

           buildImagemResultado(
              imageUrl: imagemResultadoUrl,
              fallbackPath: widget.imagemPath,
              cardColor: card,
              borderColor: border,
            ),

            if (_pdfStatus != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status do PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _pdfStatus!,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            buildResumoRapido(
              card: card,
              border: border,
              text: text,
              muted: muted,
              quantidadeDetectada: quantidadeDetectada,
              confiancaMedia: confiancaMedia,
              estadoGeral: estadoGeral,
            ),
            const SizedBox(height: 18),

            buildMensagemAnalise(
              card: card,
              border: border,
              text: text,
              muted: muted,
              message: message,
            ),
            const SizedBox(height: 18),

            buildAcaoPrincipal(
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
              ...items.whereType<Map>().map((item) {
                final map = Map<String, dynamic>.from(item);
                final produtoRaw = (map['produto'] ?? 'Produto').toString();
                final produto = _formatarNomeProduto(produtoRaw);
                final estado = (map['estado'] ?? 'desconhecido').toString();
                final produtoConf = _toDouble(map['produto_conf']);
                final estadoConf = _toDouble(map['estado_conf']);

                return ItemDetectadoCard(
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
      .whereType<Map>()
      .map((e) => (Map<String, dynamic>.from(e)['estado'] ?? '')
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
    final maps = items.whereType<Map>().toList();
    if (maps.isEmpty) return '';
    final map = Map<String, dynamic>.from(maps.first);
    final raw = (map['produto'] ?? '').toString();
    return _formatarNomeProduto(raw);
  }

  double _confiancaMedia(List items) {
    if (items.isEmpty) return 0;

    double soma = 0;
    int count = 0;

    for (final item in items.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
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
