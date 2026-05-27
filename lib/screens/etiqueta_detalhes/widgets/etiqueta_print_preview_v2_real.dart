// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import '../../../models/etiqueta_model.dart';
import '../../../models/user_model.dart';
import '../../../models/etiqueta_layout_preset.dart';

import '../../design_etiqueta_v2/widgets/qr_design_v2.dart';
import '../../design_etiqueta_v2/widgets/tabela_nutricional_design_v2.dart';

class EtiquetaPrintPreviewV2Real extends StatelessWidget {
  final DesignEtiquetaV2Model config;
  final EtiquetaModel etiqueta;
  final UserModel usuario;
  final String qrData;

  const EtiquetaPrintPreviewV2Real({
    super.key,
    required this.config,
    required this.etiqueta,
    required this.usuario,
    required this.qrData,
  });

  double get _fontFactor {
    switch (config.tamanhoFonte) {
      case TamanhoFonteEtiqueta.pequena:
        return 0.90;

      case TamanhoFonteEtiqueta.media:
        return 1.0;

      case TamanhoFonteEtiqueta.grande:
        return _is60x40 ? 1.10 : 1.22;
    }
  }

  bool get _is60x40 => config.preset == EtiquetaLayoutPreset.mm60x40;

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _empresaCompleta() {
    final ruaNumeroBairro = [
      usuario.rua.trim(),
      usuario.numero.trim(),
      usuario.bairro.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

   

    return [
      usuario.razao.trim().isNotEmpty ? usuario.razao.trim() : usuario.nome.trim(),
      if (usuario.cnpj.trim().isNotEmpty) 'CNPJ: ${usuario.cnpj}',
      if (ruaNumeroBairro.isNotEmpty) ruaNumeroBairro,
    ].where((e) => e.isNotEmpty).join('\n');
  }

  String _lote() {
    final custom = Map<String, dynamic>.from(etiqueta.camposCustomValores);
    final loteRaw = custom['lote'];

    if (loteRaw is Map) {
      final v = loteRaw['value']?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }

    if (etiqueta.lote != null && etiqueta.lote!.trim().isNotEmpty) {
      return etiqueta.lote!.trim();
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
        return '${_fmtNum(etiqueta.quantidadeRestante)} ${etiqueta.unidadeMedida}';
      case 'lote':
        return _lote();
      case 'observacao':
        return custom['observacao']?.toString() ?? '';
     default:
      dynamic raw = custom[campo.id];

      if (raw == null && campo.id.startsWith('custom_')) {
        final semPrefixo = campo.id.replaceFirst('custom_', '');
        raw = custom[semPrefixo];
      }

      if (raw is Map) {
        final value = raw['value'];
        if (value == null) return '';

        if (value is int) {
          final isData = campo.id.toLowerCase().contains('data') ||
              campo.nome.toLowerCase().contains('data');

          if (isData) {
            return _fmtDate(DateTime.fromMillisecondsSinceEpoch(value));
          }
        }

        return value.toString();
      }

      return raw?.toString() ?? '';
    }
  }

  CampoDesignEtiquetaV2Model? _findCampo(
    List<CampoDesignEtiquetaV2Model> campos,
    String id,
  ) {
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
    double base;

    if (campo.tipo == CampoDesignV2Tipo.produto ||
        campo.id == 'produto') {
      base = _is60x40 ? 18 : 22;
    } else if (campo.tipo == CampoDesignV2Tipo.blocoEmpresa ||
        campo.id == 'empresa') {
      base = _is60x40 ? 10 : 13;
    } else if (campo.id == 'ingredientes' ||
        campo.id == 'alergenicos' ||
        campo.id == 'observacao') {
      base = _is60x40 ? 9 : 11;
    } else {
      base = _is60x40 ? 10 : 12;
    }

    return base * _fontFactor;
  }

  Widget _textoCampo(
    CampoDesignEtiquetaV2Model campo,
    String valor, {
    int? maxLines,
  }) {
    return Align(
      alignment: _toAlignment(campo.align),
      child: Text(
        valor,
        textAlign: campo.align,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: _scaleFont(campo),
          fontWeight: campo.isBold ? FontWeight.w800 : FontWeight.w500,
          color: Colors.black,
          height: 1.05,
        ),
      ),
    );
  }

  Widget _linhaInfo(CampoDesignEtiquetaV2Model campo) {
    final valor = _valorCampo(campo).trim();
    if (valor.isEmpty) return const SizedBox.shrink();

    final label = (campo.labelImpresso ?? campo.nome).trim();
    final texto = label.isEmpty ? valor : '$label: $valor';

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
            height: config.tamanhoFonte ==
                  TamanhoFonteEtiqueta.grande
              ? 1.12
              : 1.02,
          ),
        ),
      ),
    );
  }

  Widget _infos(List<CampoDesignEtiquetaV2Model> campos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: campos.map(_linhaInfo).toList(),
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

    final hasQr = camposPreview.any((c) => c.tipo == CampoDesignV2Tipo.qrcode);

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

    final qrSize = config.tamanhoFonte == TamanhoFonteEtiqueta.grande
      ? (_is60x40 ? 50.0 : 78.0)
      : (_is60x40 ? 56.0 : 84.0);
    final outerPad = _is60x40 ? 6.0 : 10.0;
    final qrGap = _is60x40 ? 6.0 : 8.0;
    final empresaBoxHeight = (_is60x40 ? 40.0 : 60.0) * _fontFactor;
    final produtoBoxHeight = (_is60x40 ? 30.0 : 44.0) * _fontFactor;
    final brandHeight = (_is60x40 ? 10.0 : 14.0) * _fontFactor;
    final brandFontSize = (_is60x40 ? 8.0 : 9.0) * _fontFactor;

    return Center(
      child: Container(
        width: previewWidth,
        height: previewHeight,
        padding: EdgeInsets.fromLTRB(outerPad, 8, outerPad, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
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
                ? (contentWidth - qrColumnWidth - qrGap).clamp(80.0, contentWidth)
                : contentWidth;

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
                                child: _textoCampo(
                                  empresaCampo,
                                  _valorCampo(empresaCampo),
                                  maxLines: config.tamanhoFonte ==
                                      TamanhoFonteEtiqueta.grande
                                  ? 7
                                  : 6,
                                ),
                              ),
                            const SizedBox(height: 2),
                            if (produtoCampo != null)
                              SizedBox(
                                height: produtoBoxHeight,
                                child: _textoCampo(
                                  produtoCampo,
                                  _valorCampo(produtoCampo),
                                  maxLines: config.tamanhoFonte ==
                                      TamanhoFonteEtiqueta.grande
                                  ? 3
                                  : 2,
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
                              SizedBox(
                                height: brandHeight,
                                child: Text(
                                  'TagValida',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontSize: brandFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.78),
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

                  const SizedBox(height: 4),

                  Container(
                    width: dividerWidth,
                    height: 0.9,
                    color: Colors.black.withOpacity(0.62),
                  ),

                 const SizedBox(height: 6),

                  Expanded(
                    child: ClipRect(
                      child: config.preset == EtiquetaLayoutPreset.mm100x80 &&
                              tabelaCampo != null &&
                              etiqueta.incluirTabelaNutricional &&
                              etiqueta.tabelaNutricional != null
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 42,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 6, right: 10),
                                    child: _infos(infoCampos),
                                  ),
                                ),
                                Expanded(
                                  flex: 58,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: buildTabelaNutricionalPreviewV2(width: 200),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: infoWidth,
                              child: _infos(infoCampos),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}