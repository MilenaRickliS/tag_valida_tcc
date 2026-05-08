// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_model.dart';
import '../../design_etiqueta_v2/widgets/imagem_design_v2.dart';
import '../../design_etiqueta_v2/widgets/qr_design_v2.dart';
import '../../design_etiqueta_v2/widgets/tabela_nutricional_design_v2.dart';

class EtiquetaPrintPreviewDesign extends StatelessWidget {
  final DesignEtiquetaV2Model config;
  final EtiquetaModel etiqueta;
  final String qrData;
  final String empresaRazao;
  final String empresaCnpj;
  final String empresaRua;
  final String empresaNumero;
  final String empresaCep;
  final String empresaCidade;
  final String empresaEstado;

  const EtiquetaPrintPreviewDesign({
    super.key,
    required this.config,
    required this.etiqueta,
    required this.qrData,
    required this.empresaRazao,
    required this.empresaCnpj,
    required this.empresaRua,
    required this.empresaNumero,
    required this.empresaCep,
    required this.empresaCidade,
    required this.empresaEstado,
  });

  bool get _is60x40 => config.larguraMm <= 60.5 && config.alturaMm <= 40.5;

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _empresaCompleta() {
    final ruaNumero = [
      empresaRua.trim(),
      empresaNumero.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

    final cidadeEstado = [
      empresaCidade.trim(),
      empresaEstado.trim(),
    ].where((e) => e.isNotEmpty).join('-');

    final parts = [
      empresaRazao.trim(),
      if (empresaCnpj.trim().isNotEmpty) 'CNPJ: $empresaCnpj',
      if (ruaNumero.isNotEmpty) ruaNumero,
      if (empresaCep.trim().isNotEmpty) 'CEP: $empresaCep',
      if (cidadeEstado.isNotEmpty) cidadeEstado,
    ];

    return parts.where((e) => e.isNotEmpty).join('\n');
  }

  String _buildLote() {
    final custom = Map<String, dynamic>.from(etiqueta.camposCustomValores);
    final loteRaw = custom['lote'];

    if (loteRaw is Map) {
      final v = loteRaw['value']?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }

    return '-';
  }

  String _valorCampo(CampoDesignEtiquetaV2Model campo) {
    final custom = Map<String, dynamic>.from(etiqueta.camposCustomValores);

    switch (campo.id) {
      case 'empresa':
        return _empresaCompleta();
      case 'produto':
        return etiqueta.produtoNome;
      case 'fabricacao':
        return _fmtDate(etiqueta.dataFabricacao);
      case 'validade':
        return _fmtDate(etiqueta.dataValidade);
      case 'categoria':
        return etiqueta.categoriaNome;
      case 'setor':
        return etiqueta.setorNome;
      case 'quantidade':
        return _fmtNum(etiqueta.quantidadeRestante);
      case 'lote':
        return _buildLote();
      case 'tabela_nutricional':
        return 'Tabela nutricional';
      default:
        final raw = custom[campo.id];

        if (raw is Map) {
          final value = raw['value'];
          if (value == null) return '';

          if (value is int) {
            final isCampoData =
                campo.id.toLowerCase().contains('data') ||
                campo.nome.toLowerCase().contains('data');

            if (isCampoData) {
              return _fmtDate(DateTime.fromMillisecondsSinceEpoch(value));
            }
          }

          return value.toString();
        }

        if (raw == null) return '';
        return raw.toString();
    }
  }

  CampoDesignEtiquetaV2Model? _findCampo(List<CampoDesignEtiquetaV2Model> campos, String id) {
    try {
      return campos.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Alignment _toAlignment(TextAlign align) {
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

  double _scaleFont(CampoDesignEtiquetaV2Model campo) {
    if (campo.tipo == CampoDesignV2Tipo.produto || campo.id == 'produto') {
      return _is60x40 ? 18 : 22;
    }

    if (campo.tipo == CampoDesignV2Tipo.blocoEmpresa || campo.id == 'empresa') {
      return _is60x40 ? 10 : 13;
    }

    if (campo.id == 'validade') {
      return _is60x40 ? 11 : 13;
    }

    return _is60x40 ? 9 : 11;
  }

  TextAlign _safeAlign(TextAlign align) => align;

  FontWeight _safeWeight(bool bold) =>
      bold ? FontWeight.w800 : FontWeight.w500;

  Widget _buildTextoCampo(
    CampoDesignEtiquetaV2Model campo,
    String valor, {
    int? maxLines,
  }) {
    return Align(
      alignment: _toAlignment(campo.align),
      child: Text(
        valor,
        textAlign: _safeAlign(campo.align),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: _scaleFont(campo),
          fontWeight: _safeWeight(campo.isBold),
          color: Colors.black,
          height: 1.05,
        ),
      ),
    );
  }

  Widget _buildLinhaInfo(CampoDesignEtiquetaV2Model campo) {
    final valor = _valorCampo(campo).trim();
    if (valor.isEmpty) return const SizedBox.shrink();

    final prefixo = (campo.labelImpresso ?? campo.nome).trim();
    final texto = prefixo.isEmpty ? valor : '$prefixo: $valor';

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Align(
        alignment: _toAlignment(campo.align),
        child: Text(
          texto,
          textAlign: campo.align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: _scaleFont(campo),
            fontWeight: campo.isBold ? FontWeight.w800 : FontWeight.w500,
            color: Colors.black,
            height: 1.05,
          ),
        ),
      ),
    );
  }

  Widget _buildInfosReais(List<CampoDesignEtiquetaV2Model> campos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: campos.map(_buildLinhaInfo).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final camposOrdenados = [...config.campos]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final camposPreview = camposOrdenados.where((c) => c.visivel).toList();

    final empresaCampo = _findCampo(camposPreview, 'empresa');
    final produtoCampo = _findCampo(camposPreview, 'produto');
    final tabelaCampo = _findCampo(camposPreview, 'tabela_nutricional');

    final hasQr = camposPreview.any((e) => e.tipo == CampoDesignV2Tipo.qrcode);

    final imagemCampo = camposPreview.any((e) => e.tipo == CampoDesignV2Tipo.imagem)
        ? camposPreview.firstWhere((e) => e.tipo == CampoDesignV2Tipo.imagem)
        : null;

    final infoCampos = camposPreview.where((campo) {
      if (campo.tipo == CampoDesignV2Tipo.qrcode) return false;
      if (campo.tipo == CampoDesignV2Tipo.blocoEmpresa) return false;
      if (campo.tipo == CampoDesignV2Tipo.produto) return false;
      if (campo.tipo == CampoDesignV2Tipo.imagem) return false;
      if (campo.id == 'tabela_nutricional') return false;
      return true;
    }).toList();

    final previewWidth = 420.0;
    final ratio = config.larguraMm / config.alturaMm;
    final previewHeight = previewWidth / ratio.clamp(0.3, 10.0);

    final qrSize = _is60x40 ? 70.0 : 100.0;
    final outerPad = _is60x40 ? 6.0 : 10.0;
    final innerPad = _is60x40 ? 5.0 : 7.0;
    final qrGap = _is60x40 ? 6.0 : 8.0;
    final empresaBoxHeight = _is60x40 ? 28.0 : 42.0;
    final produtoBoxHeight = _is60x40 ? 30.0 : 44.0;
    final brandHeight = _is60x40 ? 14.0 : 16.0;
    final dividerGap = _is60x40 ? 3.0 : 5.0;
    final infoTopGap = _is60x40 ? 4.0 : 6.0;
    final infoBottomGap = _is60x40 ? 3.0 : 6.0;
    final brandFontSize = _is60x40 ? 9.0 : 11.0;

    return Center(
      child: Container(
        width: previewWidth,
        height: previewHeight,
        padding: EdgeInsets.fromLTRB(
          outerPad,
          8,
          outerPad,
          infoBottomGap,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final contentWidth =
                (totalWidth - (outerPad * 2)).clamp(0.0, totalWidth);

            final qrColumnWidth = hasQr ? qrSize : 0.0;

            final dividerWidth = hasQr
                ? (contentWidth - qrColumnWidth - 6).clamp(60.0, contentWidth)
                : contentWidth;

            final infoWidth = hasQr
                ? (contentWidth - qrColumnWidth - qrGap - innerPad)
                    .clamp(80.0, contentWidth)
                : (contentWidth - innerPad).clamp(0.0, contentWidth);

            return DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (empresaCampo != null)
                              SizedBox(
                                height: empresaBoxHeight,
                                child: Align(
                                  alignment: _toAlignment(empresaCampo.align),
                                  child: _buildTextoCampo(
                                    empresaCampo,
                                    _valorCampo(empresaCampo),
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 2),
                            if (produtoCampo != null)
                              SizedBox(
                                height: produtoBoxHeight,
                                child: Align(
                                  alignment: _toAlignment(produtoCampo.align),
                                  child: _buildTextoCampo(
                                    produtoCampo,
                                    _valorCampo(produtoCampo),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (hasQr) ...[
                        SizedBox(width: qrGap),
                        SizedBox(
                          width: qrColumnWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (config.mostrarMarcaTagValida)
                                SizedBox(
                                  height: brandHeight,
                                  child: Center(
                                    child: Text(
                                      'TagValida',
                                      style: TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: brandFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black.withOpacity(0.78),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: qrSize,
                                height: qrSize,
                                child: buildQrPreviewV2(config),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: dividerGap),
                  Container(
                    width: dividerWidth,
                    height: 0.9,
                    color: Colors.black.withOpacity(0.62),
                  ),
                  SizedBox(height: infoTopGap),
                  SizedBox(
                    width: infoWidth,
                    child: imagemCampo != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildInfosReais(infoCampos)),
                            const SizedBox(width: 8),
                            SizedBox(width: 110, child: buildImagemPreviewV2(imagemCampo)),
                          ],
                        )
                      : tabelaCampo != null && etiqueta.incluirTabelaNutricional
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildInfosReais(infoCampos)),
                                const SizedBox(width: 8),
                                buildTabelaNutricionalPreviewRealV2(etiqueta.tabelaNutricional),
                              ],
                            )
                          : _buildInfosReais(infoCampos),
                  ),
                  if (!hasQr && config.mostrarMarcaTagValida) ...[
                    const SizedBox(height: 4),
                    Text(
                      'TagValida',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: brandFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.78),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

