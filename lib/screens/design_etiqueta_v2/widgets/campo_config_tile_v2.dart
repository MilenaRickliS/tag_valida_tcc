// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';

const _lightText = Color(0xFF2B2B2B);
const _orange = Color(0xFFED7227);
const _darkSoft = Color(0xFF232323);
const _gold = Color(0xFFD4AF37);

Widget campoConfigTileV2({
  required CampoDesignEtiquetaV2Model campo,
  required bool isDark,
  required bool bloqueado,
  required Widget dragHandle,
  required ValueChanged<bool?>? onToggle,
  required bool temTabelaNutricional,
  ValueChanged<bool>? onBoldChanged,
  ValueChanged<TextAlign?>? onAlignChanged,
}) {
  final border = isDark ? _gold.withOpacity(0.12) : Colors.black.withOpacity(0.06);

  final tileBg = isDark ? _darkSoft : const Color(0xFFFFFBF5);
  final text = isDark ? Colors.white : _lightText;
  final muted = text.withOpacity(0.65);
  final isQrCode = campo.tipo == CampoDesignV2Tipo.qrcode;
  final isTabelaNutricional =
      campo.tipo == CampoDesignV2Tipo.tabelaNutricional ||
      campo.id == 'tabela_nutricional';
  
  final podeEditarEstilo = !isQrCode && !isTabelaNutricional;

  final podeAlinhar = !isQrCode &&
    !isTabelaNutricional &&
    (
      !temTabelaNutricional ||
      campo.id == 'empresa' ||
      campo.id == 'produto'
    );

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
            isTabelaNutricional
              ? const SizedBox(width: 24)
              : dragHandle,
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
                      if (campo.obrigatorio) _tag('Obrigatório'),
                      if (bloqueado || isTabelaNutricional) ...[
                        const SizedBox(width: 6),
                        _tag('Fixo'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    campo.tipo == CampoDesignV2Tipo.qrcode
                        ? 'Mostrar QR Code na etiqueta'
                        : getValorExemploV2(campo).replaceAll('\n', ' • '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (podeEditarEstilo) ...[
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            final estilo = miniConfigBoxV2(
              isDark: isDark,
              title: 'Estilo',
              child: buildEstiloControlV2(text, campo, onBoldChanged),
            );

            final alinhamento = miniConfigBoxV2(
              isDark: isDark,
              title: 'Alinhamento',
              child: buildAlignControlV2(isDark, campo, onAlignChanged),
            );

            if (!podeAlinhar) {
              return estilo;
            }

            if (isMobile) {
              return Column(
                children: [
                  estilo,
                  const SizedBox(height: 10),
                  alinhamento,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: estilo),
                const SizedBox(width: 10),
                Expanded(child: alinhamento),
              ],
            );
          },
        ),
      ],
      ],
    ),
  );
}

Widget _tag(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _orange.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: _orange,
      ),
    ),
  );
}

Widget miniConfigBoxV2({
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
        color: isDark ? _gold.withOpacity(0.10) : Colors.black.withOpacity(0.06),
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

InputDecoration inputDecorationV2(bool isDark) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: isDark ? const Color(0xFF222222) : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? _gold.withOpacity(0.12) : Colors.black.withOpacity(0.08),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? _gold.withOpacity(0.12) : Colors.black.withOpacity(0.08),
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: _orange, width: 1.2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

String getValorExemploV2(CampoDesignEtiquetaV2Model campo) {
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
      return '2,500 kg';
    case 'lote':
      return 'A2D3FD20';
    case 'observacao':
      return 'feito por alice';
    case 'preco':
      return '20,00';
    case 'ingredientes':
      return 'farinha de trigo, água, sal';
    case 'alergenicos':
      return 'contém glúten';
    case 'contem_gluten':
      return 'Sim';
    case 'contem_lactose':
      return 'Sim';
    case 'tabela_nutricional':
      return 'Tabela nutricional';
    default:
      if (campo.tipo == CampoDesignV2Tipo.imagem) {
        return 'Imagem do produto';
      }
      return campo.valorExemplo ?? campo.nome;
  }
}

Widget buildEstiloControlV2(
  Color text,
  CampoDesignEtiquetaV2Model campo,
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

Widget buildAlignControlV2(
  bool isDark,
  CampoDesignEtiquetaV2Model campo,
  ValueChanged<TextAlign?>? onAlignChanged,
) {
  return DropdownButtonFormField<TextAlign>(
    value: campo.align,
    decoration: inputDecorationV2(isDark),
    items: const [
      DropdownMenuItem(value: TextAlign.left, child: Text('Esquerda')),
      DropdownMenuItem(value: TextAlign.center, child: Text('Centro')),
    ],
    onChanged: onAlignChanged,
  );
}