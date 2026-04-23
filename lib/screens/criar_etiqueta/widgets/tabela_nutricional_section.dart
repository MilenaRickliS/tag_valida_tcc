// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../providers/gerar_etiqueta_provider.dart';
import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 2});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(',', '.');

    if (text.isEmpty) return newValue;

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 2) return oldValue;
      if (parts[1].length > decimalRange) return oldValue;
    }

    return newValue.copyWith(text: text);
  }
}

class TabelaNutricionalSection extends StatelessWidget {
  final bool isDark;
  final Color brand;
  final Color onBrand;
  final Color text;
  final Color muted;
  final Color border;
  final Color softCard;
  final GerarEtiquetaProvider gerar;
  final InputDecoration Function(String label) inputDecoration;

  const TabelaNutricionalSection({
    super.key,
    required this.isDark,
    required this.brand,
    required this.onBrand,
    required this.text,
    required this.muted,
    required this.border,
    required this.softCard,
    required this.gerar,
    required this.inputDecoration,
  });


  Widget _quantidadeMedidaField() {
    const sugestoes = <String>[
      '1',
      '1/2',
      '1/3',
      '1/4',
      '2',
      '3',
      '4',
      '5',
      '6',
      '12',
      'Outro...',
    ];

    final atual = gerar.quantidadeMedidaCtrl.text.trim();
    final safeValue = sugestoes.contains(atual) ? atual : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: text),
      decoration: inputDecoration("Qtd. medida"),
      items: sugestoes
          .map(
            (q) => DropdownMenuItem<String>(
              value: q,
              child: Text(q, style: TextStyle(color: text)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;

        if (value == 'Outro...') {
          gerar.setQuantidadeMedida('');
        } else {
          gerar.setQuantidadeMedida(value);
        }
      },
      validator: (_) {
        if (!gerar.incluirTabelaNutricional) return null;
        if (gerar.quantidadeMedidaCtrl.text.trim().isEmpty) {
          return "Campo obrigatório.";
        }
        return null;
      },
    );
  }

  bool get _mostrarQtdMedidaManual {
    const sugestoesFixas = <String>[
      '1',
      '1/2',
      '1/3',
      '1/4',
      '2',
      '3',
      '4',
      '6',
      '12',
    ];

    final atual = gerar.quantidadeMedidaCtrl.text.trim();
    return atual.isEmpty || !sugestoesFixas.contains(atual);
  }


  Widget _numericField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    bool integerOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integerOnly),
      inputFormatters: integerOnly
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ]
          : [
              DecimalTextInputFormatter(decimalRange: 2),
              LengthLimitingTextInputFormatter(10),
            ],
      style: TextStyle(color: text),
      decoration: inputDecoration(label).copyWith(
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: muted,
          fontWeight: FontWeight.w700,
        ),
      ),
      validator: (v) {
        if (!gerar.incluirTabelaNutricional) return null;

        final s = (v ?? '').trim();
        if (s.isEmpty) return "Campo obrigatório.";

        final normalized = s.replaceAll(',', '.');
        final ok = integerOnly
            ? int.tryParse(normalized) != null
            : double.tryParse(normalized) != null;

        if (!ok) return "Valor inválido.";
        return null;
      },
    );
  }
  Widget _medidaCaseiraField() {
    const medidas = <String>[
      'Unidade',
      'Fatia',
      'Colher de sopa',
      'Colher de chá',
      'Xícara',
      'Copo',
      'Pacote',
      'Porção',
    ];

    final atual = gerar.medidaCaseiraCtrl.text.trim();
    final safeValue = medidas.contains(atual) ? atual : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: text),
      decoration: inputDecoration("Medida caseira"),
      items: medidas
          .map(
            (m) => DropdownMenuItem<String>(
              value: m,
              child: Text(
                m,
                style: TextStyle(color: text),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        gerar.medidaCaseiraCtrl.text = value ?? '';
      },
      validator: (v) {
        if (!gerar.incluirTabelaNutricional) return null;
        if ((v ?? '').trim().isEmpty) return "Campo obrigatório.";
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gerar.incluirTabelaNutricional
              ? brand.withOpacity(0.28)
              : border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: brand.withOpacity(0.10),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: brand.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brand.withOpacity(0.20)),
                  ),
                  child: Icon(Icons.table_chart_outlined, color: brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tabela nutricional",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Adicione os dados nutricionais para exibir no preview e na impressão.",
                        style: TextStyle(
                          color: muted,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: SwitchListTile(
              value: gerar.incluirTabelaNutricional,
              onChanged: gerar.setIncluirTabelaNutricional,
              activeColor: brand,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              title: Text(
                "Incluir tabela nutricional nesta etiqueta",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              subtitle: Text(
                "Ao ativar, os campos nutricionais serão salvos junto da etiqueta.",
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          AnimatedCrossFade(
            crossFadeState: gerar.incluirTabelaNutricional
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 450;

                  Widget twoFields(Widget left, Widget right) {
                    if (isSmall) {
                      return Column(
                        children: [
                          left,
                          const SizedBox(height: 12),
                          right,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: 12),
                        Expanded(child: right),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      twoFields(
                        _numericField(
                          controller: gerar.porcoesPorEmbalagemCtrl,
                          label: "Porções por embalagem",
                          suffix: "",
                          integerOnly: true,
                        ),
                        _numericField(
                          controller: gerar.porcaoCtrl,
                          label: "Porção",
                          suffix: "g",
                        ),
                      ),

                      const SizedBox(height: 12),

                      twoFields(
                        _quantidadeMedidaField(),
                        _medidaCaseiraField(),
                      ),

                      if (_mostrarQtdMedidaManual) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: gerar.quantidadeMedidaCtrl,
                          style: TextStyle(color: text),
                          decoration: inputDecoration("Digite a quantidade").copyWith(
                            hintText: "Ex: 7, 1/8, 2,5",
                          ),
                          validator: (v) {
                            if (!gerar.incluirTabelaNutricional) return null;
                            if ((v ?? '').trim().isEmpty) return "Campo obrigatório.";
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 12),

                      twoFields(
                        _numericField(
                          controller: gerar.valorEnergeticoCtrl,
                          label: "Valor energético",
                          suffix: "kcal",
                        ),
                        _numericField(
                          controller: gerar.carboidratosCtrl,
                          label: "Carboidratos",
                          suffix: "g",
                        ),
                      ),

                      const SizedBox(height: 12),

                      twoFields(
                        _numericField(
                          controller: gerar.acucaresTotaisCtrl,
                          label: "Açúcares totais",
                          suffix: "g",
                        ),
                        _numericField(
                          controller: gerar.acucaresAdicionadosCtrl,
                          label: "Açúcares adicionados",
                          suffix: "g",
                        ),
                      ),

                      const SizedBox(height: 12),

                      twoFields(
                        _numericField(
                          controller: gerar.proteinasCtrl,
                          label: "Proteínas",
                          suffix: "g",
                        ),
                        _numericField(
                          controller: gerar.gordurasTotaisCtrl,
                          label: "Gorduras totais",
                          suffix: "g",
                        ),
                      ),

                      const SizedBox(height: 12),

                      twoFields(
                        _numericField(
                          controller: gerar.gordurasSaturadasCtrl,
                          label: "Gorduras saturadas",
                          suffix: "g",
                        ),
                        _numericField(
                          controller: gerar.gordurasTransCtrl,
                          label: "Gorduras trans",
                          suffix: "g",
                        ),
                      ),

                      const SizedBox(height: 12),

                      twoFields(
                        _numericField(
                          controller: gerar.fibraAlimentarCtrl,
                          label: "Fibras alimentares",
                          suffix: "g",
                        ),
                        _numericField(
                          controller: gerar.sodioCtrl,
                          label: "Sódio",
                          suffix: "mg",
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: brand, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Os campos podem ser exibidos na tabela mesmo com valor zero. O ideal é manter a tabela completa e padronizada.",
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
