// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';


  const _lightText = Color(0xFF2B2B2B);
  const _orange = Color(0xFFED7227);
  const _darkSoft = Color(0xFF232323);
  const _gold = Color(0xFFD4AF37);

Widget campoConfigTile({
    required BuildContext context, 
    required CampoDesignEtiquetaModel campo,
    required DesignEtiquetaModel config,
    required bool isDark,
    required bool bloqueado, 
    required Widget dragHandle,
    required ValueChanged<bool?>? onToggle,
    ValueChanged<double>? onFontChanged,
    ValueChanged<bool>? onBoldChanged,
    ValueChanged<TextAlign?>? onAlignChanged,
    bool ocultarControlesTexto = false, 
  }) {
    final border = isDark
        ? _gold.withOpacity(0.12)
        : Colors.black.withOpacity(0.06);

    final tileBg = isDark ? _darkSoft : const Color(0xFFFFFBF5);
    final text = isDark ? Colors.white : _lightText;
    final muted = text.withOpacity(0.65);
    final maxFont = maxFontForCampo(campo, config);


    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              dragHandle,
              const SizedBox(width: 10),
              Checkbox(
                value: campo.visivel,
                onChanged: onToggle,
                activeColor: _orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            campo.nome,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                        ),
                        if (campo.obrigatorio)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Obrigatório',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _orange,
                              ),
                            ),
                          ),
                        if (bloqueado)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Fixo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _orange,
                              ),
                            ),
                          ), 
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campo.tipo == CampoDesignTipo.qrcode
                          ? 'Mostrar QR Code na etiqueta'
                          : getValorExemplo(campo).replaceAll('\n', ' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!ocultarControlesTexto)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                return Column(
                  children: [
                    miniConfigBox(
                      isDark: isDark,
                      title: 'Fonte',
                      child: buildFonteControl(context, campo, maxFont, text, onFontChanged),
                    ),
                    const SizedBox(height: 10),

                    miniConfigBox(
                      isDark: isDark,
                      title: 'Estilo',
                      child: buildEstiloControl(text, campo, onBoldChanged),
                    ),
                    const SizedBox(height: 10),

                    miniConfigBox(
                      isDark: isDark,
                      title: 'Alinhamento',
                      child: buildAlignControl(isDark, campo, onAlignChanged),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: miniConfigBox(
                      isDark: isDark,
                      title: 'Fonte',
                      child: buildFonteControl(context, campo, maxFont, text, onFontChanged),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: miniConfigBox(
                      isDark: isDark,
                      title: 'Estilo',
                      child: buildEstiloControl(text, campo, onBoldChanged),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: miniConfigBox(
                      isDark: isDark,
                      title: 'Alinhamento',
                      child: buildAlignControl(isDark, campo, onAlignChanged),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget miniConfigBox({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? _gold.withOpacity(0.10)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : _lightText,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }


 InputDecoration inputDecoration(bool isDark) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: isDark ? const Color(0xFF222222) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? _gold.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? _gold.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _orange,
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }


 String exampleValue(String id, String nome) {
  switch (id) {
    case 'empresa':
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90';
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
      return 'Panificadora TagValida\nCNPJ: 12.123.456/0001-90';
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

  double max = 28;

  if (area <= 2400) {
    max = visibleCount <= 4 ? 18 : 14;
  } else if (area <= 5000) {
    max = visibleCount <= 6 ? 22 : 18;
  } else {
    max = visibleCount <= 8 ? 26 : 22;
  }

  if (campo.id == 'produto') {
    return max;
  }

  return max.clamp(10, 22);
}

Widget buildFonteControl(
  BuildContext context,
  CampoDesignEtiquetaModel campo,
  double maxFont,
  Color text,
  ValueChanged<double>? onFontChanged,
) {
  return Column(
    children: [
      Slider(
        min: 6,
        max: maxFont,
        value: campo.fontSize.clamp(6, maxFont),
        onChanged: onFontChanged,
      ),
      Text(
        '${campo.fontSize.toStringAsFixed(0)} pt',
        style: TextStyle(fontWeight: FontWeight.w800, color: text),
      ),
    ],
  );
}

Widget buildEstiloControl(
  Color text,
  CampoDesignEtiquetaModel campo,
  ValueChanged<bool>? onBoldChanged,
) {
  return SwitchListTile.adaptive(
    dense: true,
    contentPadding: EdgeInsets.zero,
    value: campo.isBold,
    title: Text(
      'Negrito',
      style: TextStyle(fontWeight: FontWeight.w700, color: text),
    ),
    onChanged: onBoldChanged,
  );
}

Widget buildAlignControl(
  bool isDark,
  CampoDesignEtiquetaModel campo,
  ValueChanged<TextAlign?>? onAlignChanged,
) {
  return DropdownButtonFormField<TextAlign>(
    value: campo.align,
    decoration: inputDecoration(isDark),
    items: const [
      DropdownMenuItem(value: TextAlign.left, child: Text('Esquerda')),
      DropdownMenuItem(value: TextAlign.center, child: Text('Centro')),
      DropdownMenuItem(value: TextAlign.right, child: Text('Direita')),
    ],
    onChanged: onAlignChanged,
  );
}