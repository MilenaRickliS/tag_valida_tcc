import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/pdf_download_stub.dart'
    if (dart.library.html) '../utils/pdf_download_web.dart';
import '../utils/pdf_open_stub.dart'
    if (dart.library.io) '../utils/pdf_open_io.dart';
import '../utils/pdf_temp_file_stub.dart'
    if (dart.library.io) '../utils/pdf_temp_file_io.dart';

class ResultadoPrevisaoPdfService {
  static Future<void> salvarPdf({
    required String imagemPath,
    Uint8List? imagemBytes,
    required Map<String, dynamic> resultado,
  }) async {
    debugPrint('--- SALVAR PDF SERVICE ---');
    debugPrint('kIsWeb: $kIsWeb');
    debugPrint('imagemPath: $imagemPath');
    debugPrint(
      'imagemBytes: ${imagemBytes == null ? 'null' : '${imagemBytes.length} bytes'}',
    );
    debugPrint('resultado keys: ${resultado.keys.toList()}');

    final bytes = await gerarPdfBytes(
      imagemPath: imagemPath,
      imagemBytes: imagemBytes,
      resultado: resultado,
    );

    debugPrint('PDF bytes gerados: ${bytes.length}');

    final nomeArquivo =
        'resultado_previsao_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

    if (kIsWeb) {
      debugPrint('Iniciando download web: $nomeArquivo');
      downloadPdfWeb(bytes, nomeArquivo);
      debugPrint('Download web disparado');
      return;
    }

    final file = await savePdfTempFile(bytes, nomeArquivo);
    debugPrint('Arquivo salvo em: ${file.path}');
    await openPdfFile(file.path);
    debugPrint('Arquivo aberto');
  }

  static Future<Uint8List> gerarPdfBytes({
    required String imagemPath,
    Uint8List? imagemBytes,
    required Map<String, dynamic> resultado,
  }) async {
    final pdf = pw.Document();

    final root = Map<String, dynamic>.from(resultado);
    final rawData = root['data'];

    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : root;

    final success = root['success'] ?? true;
    final message = (root['message'] ?? '').toString();
    final quantidadeDetectada =
        (data['quantidade_detectada'] as num?)?.toInt() ?? 0;

    final itemsRaw = data['items'];
    final items = itemsRaw is List ? itemsRaw : [];

    final estadoGeral = _estadoDominante(items);
    final confiancaMedia = _confiancaMedia(items);
    final produtoPrincipal = _produtoPrincipal(items);

    pw.MemoryImage? imagemMemoria;

    if (imagemBytes != null && imagemBytes.isNotEmpty) {
      imagemMemoria = pw.MemoryImage(imagemBytes);
    } else if (!kIsWeb && imagemPath.isNotEmpty) {
      final localBytes = await readLocalFileBytes(imagemPath);
      if (localBytes != null && localBytes.isNotEmpty) {
        imagemMemoria = pw.MemoryImage(localBytes);
      }
    }

    final corPrincipal = _estadoPdfColor(estadoGeral);
    final tituloEstado = _tituloEstadoHero(estadoGeral);
    final acaoTitulo = _acaoTitulo(estadoGeral);
    final acaoDescricao = _acaoDescricao(estadoGeral);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 24),
        build: (context) => [
          _buildHeader(
            titulo: 'Resultado da análise',
            subtitulo:
                'Relatório gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          ),
          pw.SizedBox(height: 16),

          _buildHeroResultadoPdf(
            success: success == true,
            tituloEstado: tituloEstado,
            produtoPrincipal: produtoPrincipal,
            descricao: acaoDescricao,
            quantidadeDetectada: quantidadeDetectada,
            confiancaMedia: confiancaMedia,
            acaoTitulo: acaoTitulo,
            corPrincipal: corPrincipal,
          ),

          pw.SizedBox(height: 18),

          if (imagemMemoria != null) ...[
            _buildSectionTitle('Imagem analisada'),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: _cardDecoration(),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Container(
                      constraints: const pw.BoxConstraints(
                        maxHeight: 280,
                        minHeight: 180,
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 16,
                        verticalRadius: 16,
                        child: pw.Image(
                          imagemMemoria,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Imagem processada pela IA com marcações de detecção.',
                    style: _textStyle(
                      fontSize: 10.5,
                      color: PdfColor.fromHex('#6B7280'),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
          ],

          _buildSectionTitle('Resumo da análise'),
          pw.SizedBox(height: 10),
          _buildResumoAnalisePdf(
            quantidadeDetectada: quantidadeDetectada,
            confiancaMedia: confiancaMedia,
            estadoGeral: estadoGeral,
            corPrincipal: corPrincipal,
            message: message,
          ),

          pw.SizedBox(height: 18),

          _buildSectionTitle('Ação recomendada'),
          pw.SizedBox(height: 10),
          _buildAcaoRecomendadaPdf(
            estado: estadoGeral,
            titulo: acaoTitulo,
            descricao: acaoDescricao,
            corPrincipal: corPrincipal,
          ),

          pw.SizedBox(height: 18),

          _buildSectionTitle('Itens detectados'),
          pw.SizedBox(height: 8),

          if (items.isNotEmpty)
            ...items.map((item) {
              if (item is! Map) return pw.SizedBox();

              final map = Map<String, dynamic>.from(item);
              final produto = _formatarNomeProduto(
                (map['produto'] ?? 'Produto').toString(),
              );
              final estado = (map['estado'] ?? 'desconhecido').toString();
              final produtoConf = _toDouble(map['produto_conf']);
              final estadoConf = _toDouble(map['estado_conf']);

              return _buildItemDetectadoCompactoPdf(
                produto: produto,
                estado: estado,
                produtoConf: produtoConf,
                estadoConf: estadoConf,
              );
            })
          else
            pw.Text(
              'Nenhum item foi detectado.',
              style: _textStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#374151'),
              ),
            ),

          pw.SizedBox(height: 18),

          _buildSectionTitle('Como essa análise ajuda no negócio'),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _bulletText(
                  'Reduz perdas ao identificar com mais rapidez produtos em condição crítica.',
                ),
                pw.SizedBox(height: 6),
                _bulletText(
                  'Apoia decisões operacionais, como priorizar venda, revisar exposição ou retirar itens.',
                ),
                pw.SizedBox(height: 6),
                _bulletText(
                  'Melhora o controle de qualidade e reforça a padronização da conferência.',
                ),
                pw.SizedBox(height: 6),
                _bulletText(
                  'Ajuda a evitar exposição de produtos inadequados para comercialização.',
                ),
                pw.SizedBox(height: 6),
                _bulletText(
                  'Gera evidência visual e documental para acompanhamento interno do processo.',
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildItemDetectadoCompactoPdf({
    required String produto,
    required String estado,
    required double produtoConf,
    required double estadoConf,
  }) {
    final corItem = _estadoPdfColor(estado);
    final confianca = _mediaConfianca(produtoConf, estadoConf);

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromHex('#EAEAEA'),
            width: 0.8,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              produto,
              style: _textStyle(
                fontSize: 11.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1F2937'),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            estado.toUpperCase(),
            style: _textStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: corItem,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            '${confianca.toStringAsFixed(0)}%',
            style: _textStyle(
              fontSize: 9.5,
              color: PdfColor.fromHex('#6B7280'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader({
    required String titulo,
    required String subtitulo,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [
            PdfColor.fromInt(0xFFED7227),
            PdfColor.fromInt(0xFFE53935),
          ],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: _textStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            subtitulo,
            style: _textStyle(
              fontSize: 10.5,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeroResultadoPdf({
    required bool success,
    required String tituloEstado,
    required String produtoPrincipal,
    required String descricao,
    required int quantidadeDetectada,
    required double confiancaMedia,
    required String acaoTitulo,
    required PdfColor corPrincipal,
  }) {
    final subtitulo = produtoPrincipal.isNotEmpty
        ? '$produtoPrincipal em análise'
        : 'Resultado geral da inspeção';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _lighten(corPrincipal, 0.93),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: _lighten(corPrincipal, 0.70),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            success ? 'Análise concluída' : 'Falha na análise',
            style: _textStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: corPrincipal,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            tituloEstado,
            style: _textStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1F2937'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitulo,
            style: _textStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#4B5563'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            descricao,
            style: _textStyle(
              fontSize: 10.5,
              lineSpacing: 2.5,
              color: PdfColor.fromHex('#374151'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Itens detectados: $quantidadeDetectada   -  Confiança média: ${confiancaMedia.toStringAsFixed(0)}%   -   Ação: $acaoTitulo',
            style: _textStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: corPrincipal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildResumoAnalisePdf({
    required int quantidadeDetectada,
    required double confiancaMedia,
    required String estadoGeral,
    required PdfColor corPrincipal,
    required String message,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: _resumoMiniBox(
                  'Itens detectados',
                  '$quantidadeDetectada',
                  PdfColor.fromHex('#2563EB'),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _resumoMiniBox(
                  'Confiança média',
                  '${confiancaMedia.toStringAsFixed(0)}%',
                  PdfColor.fromHex('#7C3AED'),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _resumoMiniBox(
                  'Status geral',
                  estadoGeral.toUpperCase(),
                  corPrincipal,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FFF7ED'),
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(
                color: PdfColor.fromHex('#FED7AA'),
              ),
            ),
            child: pw.Text(
              message.isNotEmpty
                  ? message
                  : 'A análise foi finalizada com sucesso.',
              style: _textStyle(
                fontSize: 11.2,
                lineSpacing: 3,
                color: PdfColor.fromHex('#374151'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAcaoRecomendadaPdf({
    required String estado,
    required String titulo,
    required String descricao,
    required PdfColor corPrincipal,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _lighten(corPrincipal, 0.90),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(
          color: _lighten(corPrincipal, 0.68),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ação recomendada',
            style: _textStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: corPrincipal,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            titulo,
            style: _textStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1F2937'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            descricao,
            style: _textStyle(
              fontSize: 11.3,
              lineSpacing: 3,
              color: PdfColor.fromHex('#374151'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: _textStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#111827'),
      ),
    );
  }

  static pw.Widget _resumoMiniBox(
    String titulo,
    String valor,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _lighten(color, 0.90),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: _lighten(color, 0.72),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: _textStyle(
              fontSize: 9.8,
              color: PdfColor.fromHex('#6B7280'),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            valor,
            style: _textStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bulletText(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(
            '-',
            style: _textStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#ED7227'),
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            text,
            style: _textStyle(
              fontSize: 11.2,
              lineSpacing: 3,
              color: PdfColor.fromHex('#374151'),
            ),
          ),
        ),
      ],
    );
  }

  static pw.BoxDecoration _cardDecoration() {
    return pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(16),
      border: pw.Border.all(
        color: PdfColor.fromHex('#E5E7EB'),
      ),
    );
  }

  static pw.TextStyle _textStyle({
    double fontSize = 12,
    PdfColor? color,
    pw.FontWeight? fontWeight,
    double? lineSpacing,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      color: color ?? PdfColor.fromHex('#111827'),
      fontWeight: fontWeight,
      lineSpacing: lineSpacing,
    );
  }

  static PdfColor _lighten(PdfColor color, double amount) {
    final a = amount.clamp(0.0, 1.0);
    final r = color.red + (1 - color.red) * a;
    final g = color.green + (1 - color.green) * a;
    final b = color.blue + (1 - color.blue) * a;
    return PdfColor(r, g, b);
  }

  static String _formatarNomeProduto(String nome) {
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
            .map((e) => e.isEmpty ? e : e[0].toUpperCase() + e.substring(1))
            .join(' ');
    }
  }

  static String _estadoDominante(List items) {
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

  static String _produtoPrincipal(List items) {
    if (items.isEmpty) return '';
    final map = Map<String, dynamic>.from(items.first as Map);
    final raw = (map['produto'] ?? '').toString();
    return _formatarNomeProduto(raw);
  }

  static double _confiancaMedia(List items) {
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

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll('%', '').trim()) ?? 0;
  }

  static double _mediaConfianca(double a, double b) {
    if (a <= 0 && b <= 0) return 0;
    if (a <= 0) return b;
    if (b <= 0) return a;
    return (a + b) / 2;
  }

  static PdfColor _estadoPdfColor(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return PdfColor.fromHex('#54A73B');
      case 'alerta':
        return PdfColor.fromHex('#ED7227');
      case 'vencido':
        return PdfColor.fromHex('#E53935');
      default:
        return PdfColor.fromHex('#607D8B');
    }
  }

  static String _tituloEstadoHero(String estado) {
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

  static String _acaoTitulo(String estado) {
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

  static String _acaoDescricao(String estado) {
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
  
}