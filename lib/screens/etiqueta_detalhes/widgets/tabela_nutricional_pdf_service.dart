import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../models/tabela_nutricional_model.dart';

enum LayoutTabelaNutricionalPdf {
  vertical,
  horizontal,
  verticalQuebrado,
  horizontalQuebrado,
}

class TabelaNutricionalPdfService {
    Future<pw.MemoryImage> _carregarImagemLupa(List<String> alertas) async {
      final path = _pathImagemLupa(alertas);

      final bytes = await rootBundle.load(path);

      return pw.MemoryImage(bytes.buffer.asUint8List());
    }

    String _pathImagemLupa(List<String> alertas) {
      final temAcucar = alertas.contains('AÇÚCAR ADICIONADO');
      final temGordura = alertas.contains('GORDURA SATURADA');
      final temSodio = alertas.contains('SÓDIO');

      if (temAcucar && temGordura && temSodio) {
        return 'assets/rotulagem/3_todos.png';
      }

      if (temAcucar && temGordura) {
        return 'assets/rotulagem/2_acucar_gordura.png';
      }

      if (temAcucar && temSodio) {
        return 'assets/rotulagem/2_acucar_sodio.png';
      }

      if (temGordura && temSodio) {
        return 'assets/rotulagem/2_gordura_sodio.png';
      }

      if (temAcucar) {
        return 'assets/rotulagem/1_acucar.png';
      }

      if (temGordura) {
        return 'assets/rotulagem/1_gordura.png';
      }

      return 'assets/rotulagem/1_sodio.png';
    }

  Future<File> gerarPdf({
    required TabelaNutricionalModel tabela,
    required LayoutTabelaNutricionalPdf layout,
    required String produtoNome,
  }) async {
    try {
      final pdf = pw.Document();

      final alertas = calcularAlertasFrontais(tabela);

      pw.MemoryImage? lupaImagem;

      try {
        if (alertas.isNotEmpty) {
          lupaImagem = await _carregarImagemLupa(alertas);
        }
      } catch (e) {
        
        // ignore: avoid_print
        print('Erro ao carregar imagem da lupa: $e');
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (lupaImagem != null) ...[
                  pw.Image(
                    lupaImagem,
                    width: 150,
                    fit: pw.BoxFit.contain,
                  ),
                  pw.SizedBox(height: 16),
                ],

                _buildTabelaPorLayout(tabela, layout),
              ],
            );
            },
          ),
        );

        final dir = await getApplicationDocumentsDirectory();

        final nomeSeguro = produtoNome
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();

        final file = File('${dir.path}/tabela_nutricional_$nomeSeguro.pdf');

        await file.writeAsBytes(await pdf.save());

        return file;
      } catch (e) {
        throw Exception('Erro ao gerar PDF: $e');
      }
    }

  List<String> calcularAlertasFrontais(TabelaNutricionalModel tabela) {
    final alertas = <String>[];

    final porcao = double.tryParse(
          tabela.porcao.trim().replaceAll(',', '.'),
        ) ??
        0;

    if (porcao <= 0) return alertas;

    double calc100g(double valorPorcao) {
      return (valorPorcao / porcao) * 100;
    }

    final acucarAdicionado100g = calc100g(tabela.acucaresAdicionados);
    final gorduraSaturada100g = calc100g(tabela.gordurasSaturadas);
    final sodio100g = calc100g(tabela.sodio);

    if (acucarAdicionado100g >= 15) {
      alertas.add('AÇÚCAR ADICIONADO');
    }

    if (gorduraSaturada100g >= 6) {
      alertas.add('GORDURA SATURADA');
    }

    if (sodio100g >= 600) {
      alertas.add('SÓDIO');
    }

    return alertas;
  }

  pw.Widget _buildTabelaPorLayout(
    TabelaNutricionalModel tabela,
    LayoutTabelaNutricionalPdf layout,
  ) {
    switch (layout) {
      case LayoutTabelaNutricionalPdf.vertical:
        return _tabelaVertical(tabela);
      case LayoutTabelaNutricionalPdf.horizontal:
        return _tabelaHorizontal(tabela);
      case LayoutTabelaNutricionalPdf.verticalQuebrado:
        return _tabelaVerticalQuebrada(tabela);
      case LayoutTabelaNutricionalPdf.horizontalQuebrado:
        return _tabelaHorizontalQuebrada(tabela);
    }
  }


  pw.Widget _tabelaVertical(TabelaNutricionalModel tabela) {
    return pw.Container(
      width: 280,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _titulo(),
          _infoPorcao(tabela),
          _cabecalhoTabela(tabela),
          _linhasTabela(tabela),
          _rodape(),
        ],
      ),
    );
  }

  pw.Widget _tabelaHorizontal(TabelaNutricionalModel tabela) {
    return pw.Container(
      width: 520,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 130,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INFORMAÇÃO\nNUTRICIONAL',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                _infoPorcaoSimples(tabela),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              children: [
                _cabecalhoTabela(tabela),
                _linhasTabela(tabela),
                _rodape(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _tabelaVerticalQuebrada(TabelaNutricionalModel tabela) {
    final linhas = _dadosTabela(tabela);
    final metade = (linhas.length / 2).ceil();

    return pw.Container(
      width: 520,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Column(
        children: [
          _titulo(),
          _infoPorcao(tabela),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _miniTabela(tabela, linhas.take(metade).toList())),
              pw.Expanded(child: _miniTabela(tabela, linhas.skip(metade).toList())),
            ],
          ),
          _rodape(),
        ],
      ),
    );
  }

  pw.Widget _tabelaHorizontalQuebrada(TabelaNutricionalModel tabela) {
    final linhas = _dadosTabela(tabela);
    final metade = (linhas.length / 2).ceil();

    return pw.Container(
      width: 540,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INFORMAÇÃO\nNUTRICIONAL',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                _infoPorcaoSimples(tabela),
              ],
            ),
          ),
          pw.Expanded(child: _miniTabela(tabela, linhas.take(metade).toList())),
          pw.Expanded(child: _miniTabela(tabela, linhas.skip(metade).toList())),
        ],
      ),
    );
  }

  pw.Widget _titulo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
        ),
      ),
      child: pw.Text(
        'INFORMAÇÃO NUTRICIONAL',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _infoPorcao(TabelaNutricionalModel tabela) {
    final porcaoLabel = '${tabela.porcao} g';
    final medida = '${tabela.quantidadeMedida} ${tabela.medidaCaseira}'.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Porção: $porcaoLabel ($medida)',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Porções por embalagem: ${tabela.porcoesPorEmbalagem}',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoPorcaoSimples(TabelaNutricionalModel tabela) {
    final porcaoLabel = '${tabela.porcao} g';
    final medida = '${tabela.quantidadeMedida} ${tabela.medidaCaseira}'.trim();

    return pw.Text(
      'Porção: $porcaoLabel\n($medida)\nPorções por emb.: ${tabela.porcoesPorEmbalagem}',
      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _cabecalhoTabela(TabelaNutricionalModel tabela) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(0.8),
      },
      children: [
        pw.TableRow(
          children: [
            _cell('', bold: true),
            _cell('100 g', bold: true, center: true),
            _cell('${tabela.porcao} g', bold: true, center: true),
            _cell('%VD*', bold: true, center: true),
          ],
        ),
      ],
    );
  }

  pw.Widget _linhasTabela(TabelaNutricionalModel tabela) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.4),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(0.8),
      },
      children: _dadosTabela(tabela).map(_row).toList(),
    );
  }

  pw.Widget _miniTabela(TabelaNutricionalModel tabela, List<_LinhaNutri> linhas) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.4),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.4),
        1: pw.FlexColumnWidth(0.8),
        2: pw.FlexColumnWidth(0.8),
        3: pw.FlexColumnWidth(0.7),
      },
      children: [
        pw.TableRow(
          children: [
            _cell('', bold: true),
            _cell('100 g', bold: true, center: true),
            _cell('${tabela.porcao} g', bold: true, center: true),
            _cell('%VD*', bold: true, center: true),
          ],
        ),
        ...linhas.map(_row),
      ],
    );
  }

  pw.TableRow _row(_LinhaNutri linha) {
    return pw.TableRow(
      children: [
        _cell(linha.nome),
        _cell(linha.valor100g, center: true),
        _cell(linha.valorPorcao, center: true),
        _cell(linha.vd, center: true),
      ],
    );
  }

  pw.Widget _cell(
    String text, {
    bool bold = false,
    bool center = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2.5),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _rodape() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.black, width: 0.8),
        ),
      ),
      child: pw.Text(
        '* Percentual de valores diários fornecidos por porção, com base em uma dieta de 2000 kcal. Seus valores podem ser diferentes dependendo de suas necessidades energéticas.',
        style: const pw.TextStyle(fontSize: 6.5),
      ),
    );
  }

  List<_LinhaNutri> _dadosTabela(TabelaNutricionalModel tabela) {
    return [
      _linha('Valor energético', tabela.valorEnergetico, 2000, 'kcal', tabela),
      _linha('Carboidratos totais', tabela.carboidratos, 300, 'g', tabela),
      _linha('Açúcares totais', tabela.acucaresTotais, 50, 'g', tabela, tracoSeZero: true),
      _linha('Açúcares adicionados', tabela.acucaresAdicionados, 50, 'g', tabela),
      _linha('Proteínas', tabela.proteinas, 50, 'g', tabela),
      _linha('Gorduras totais', tabela.gordurasTotais, 55, 'g', tabela),
      _linha('Gorduras saturadas', tabela.gordurasSaturadas, 22, 'g', tabela),
      _linha('Gorduras trans', tabela.gordurasTrans, 2, 'g', tabela, tracoSeZero: true),
      _linha('Fibras alimentares', tabela.fibraAlimentar, 25, 'g', tabela),
      _linha('Sódio', tabela.sodio, 2000, 'mg', tabela),
    ];
  }

  _LinhaNutri _linha(
    String nome,
    double valorPorcao,
    double vdReferencia,
    String unidade,
    TabelaNutricionalModel tabela, {
    bool tracoSeZero = false,
  }) {
    final porcao = double.tryParse(tabela.porcao.trim().replaceAll(',', '.')) ?? 0;
    final valor100g = porcao <= 0 ? 0 : (valorPorcao / porcao) * 100;
    final vd = vdReferencia <= 0 ? 0 : (valorPorcao / vdReferencia) * 100;

    return _LinhaNutri(
      nome: nome,
      valor100g: _fmtValor(valor100g, unidade),
      valorPorcao: _fmtValor(valorPorcao, unidade),
      vd: valorPorcao <= 0 && tracoSeZero ? '-' : '${vd.round()}%',
    );
  }

  String _fmtValor(num v, String unidade) {
    final numero = v % 1 == 0
        ? v.toInt().toString()
        : v.toStringAsFixed(1).replaceAll('.', ',');

    return '$numero $unidade';
  }
}

class _LinhaNutri {
  final String nome;
  final String valor100g;
  final String valorPorcao;
  final String vd;

  _LinhaNutri({
    required this.nome,
    required this.valor100g,
    required this.valorPorcao,
    required this.vd,
  });
}