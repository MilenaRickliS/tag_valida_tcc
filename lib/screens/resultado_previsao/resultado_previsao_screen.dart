// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui' as ui;

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
  ui.Image? _decodedImage;

  @override
  void initState() {
    super.initState();
    _carregarDimensoesImagem();
  }

  Future<void> _carregarDimensoesImagem() async {
    try {
      final bytes = await File(widget.imagemPath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      if (!mounted) return;

      setState(() {
        _decodedImage = frame.image;
      });
    } catch (_) {}
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

    final root = widget.resultado;
    final data = ((root['data'] is Map<String, dynamic>)
            ? root['data'] as Map<String, dynamic>
            : root);

    final success = root['success'] ?? true;
    final message = (root['message'] ?? '').toString();
    final quantidadeDetectada =
        (data['quantidade_detectada'] ?? 0) as int? ?? 0;
    final items = (data['items'] as List?) ?? [];

    final imagemResultado =
        (data['imagem_resultado'] ?? widget.imagemPath).toString();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Resultado da análise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImagemComBoundingBoxes(
              context: context,
              imagePath: widget.imagemPath,
              items: items,
              cardColor: card,
            ),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.24 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusChip(
                        label: success == true ? 'Análise concluída' : 'Erro',
                        color: success == true ? Colors.green : Colors.red,
                      ),
                      _StatusChip(
                        label: '$quantidadeDetectada item(ns) detectado(s)',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mensagem',
                    style: TextStyle(
                      fontSize: 14,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.isNotEmpty ? message : 'Sem mensagem retornada.',
                    style: TextStyle(
                      fontSize: 16,
                      color: text,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Imagem processada',
                    style: TextStyle(
                      fontSize: 14,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    imagemResultado,
                    style: TextStyle(
                      fontSize: 14,
                      color: text,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nenhum item foi detectado na imagem.',
                  style: TextStyle(
                    color: text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Itens detectados',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...items.map((item) {
                    final map = Map<String, dynamic>.from(item as Map);
                    final produto = (map['produto'] ?? 'Produto').toString();
                    final estado = (map['estado'] ?? 'desconhecido').toString();
                    final produtoConf =
                        (map['produto_conf'] ?? '-').toString();
                    final estadoConf = (map['estado_conf'] ?? '-').toString();
                    final bbox = Map<String, dynamic>.from(
                      (map['bbox'] ?? {}) as Map,
                    );

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.20 : 0.04,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
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
                              Text(
                                produto,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: text,
                                ),
                              ),
                              _StatusChip(
                                label: estado,
                                color: _estadoColor(estado),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _InfoLinha(
                            titulo: 'Confiança do produto',
                            valor: '$produtoConf%',
                            textColor: text,
                            mutedColor: muted,
                          ),
                          const SizedBox(height: 10),
                          _InfoLinha(
                            titulo: 'Confiança do estado',
                            valor: '$estadoConf%',
                            textColor: text,
                            mutedColor: muted,
                          ),
                          const SizedBox(height: 10),
                          _InfoLinha(
                            titulo: 'Bounding box',
                            valor:
                                'x1: ${bbox['x1']}, y1: ${bbox['y1']}, x2: ${bbox['x2']}, y2: ${bbox['y2']}',
                            textColor: text,
                            mutedColor: muted,
                          ),
                          const SizedBox(height: 14),
                          _AcaoRecomendadaCard(
                            estado: estado,
                            titulo: _acaoTitulo(estado),
                            descricao: _acaoDescricao(estado),
                            icon: _acaoIcone(estado),
                            color: _estadoColor(estado),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SelectableText(
                widget.resultado.toString(),
                style: TextStyle(
                  color: muted,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagemComBoundingBoxes({
    required BuildContext context,
    required String imagePath,
    required List items,
    required Color cardColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double boxHeight = 320;
        final double boxWidth = constraints.maxWidth;

        final imageW = (_decodedImage?.width ?? 1).toDouble();
        final imageH = (_decodedImage?.height ?? 1).toDouble();

        final scale = (_decodedImage == null)
            ? 1.0
            : _containScale(
                srcW: imageW,
                srcH: imageH,
                dstW: boxWidth,
                dstH: boxHeight,
              );

        final renderW = imageW * scale;
        final renderH = imageH * scale;

        final offsetX = (boxWidth - renderW) / 2;
        final offsetY = (boxHeight - renderH) / 2;

        return Container(
          width: double.infinity,
          height: boxHeight,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.03),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (_decodedImage != null)
                  ...items.map((item) {
                    final map = Map<String, dynamic>.from(item as Map);
                    final bbox =
                        Map<String, dynamic>.from((map['bbox'] ?? {}) as Map);

                    final x1 = ((bbox['x1'] ?? 0) as num).toDouble();
                    final y1 = ((bbox['y1'] ?? 0) as num).toDouble();
                    final x2 = ((bbox['x2'] ?? 0) as num).toDouble();
                    final y2 = ((bbox['y2'] ?? 0) as num).toDouble();

                    final left = offsetX + (x1 * scale);
                    final top = offsetY + (y1 * scale);
                    final width = (x2 - x1) * scale;
                    final height = (y2 - y1) * scale;

                    final produto = (map['produto'] ?? '').toString();
                    final estado = (map['estado'] ?? '').toString();
                    final cor = _estadoColor(estado);

                    return Positioned(
                      left: left,
                      top: top,
                      width: width,
                      height: height,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: cor, width: 2.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                '$produto • $estado',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  double _containScale({
    required double srcW,
    required double srcH,
    required double dstW,
    required double dstH,
  }) {
    final scaleX = dstW / srcW;
    final scaleY = dstH / srcH;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return Colors.green;
      case 'alerta':
        return Colors.orange;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
  String _acaoTitulo(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Tire da venda';
      case 'alerta':
        return 'Priorizar venda';
      case 'bom':
        return 'Apto para a venda';
      default:
        return 'Revisão necessária';
    }
  }

  String _acaoDescricao(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Este item apresenta condição incompatível com comercialização. Remova da área de venda e siga o procedimento interno de descarte ou avaliação técnica.';
      case 'alerta':
        return 'Este item exige atenção. Recomendamos priorizar sua saída e acompanhar de perto sua condição para evitar perdas.';
      case 'bom':
        return 'Este item apresenta condição adequada para comercialização no momento. Mantenha o monitoramento dentro da rotina normal.';
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
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
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
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.35 : 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.24 : 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
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
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14,
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