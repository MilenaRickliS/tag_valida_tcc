// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/etiqueta_model.dart';
import '../../../utils/formatar_lote.dart';

enum MovimentoEstoqueTipo {
  venda,
  uso,
  descarte,
  ajuste,
  cancelamento,
}

extension MovimentoEstoqueTipoX on MovimentoEstoqueTipo {
  String get label {
    switch (this) {
      case MovimentoEstoqueTipo.venda:
        return "Venda";
      case MovimentoEstoqueTipo.uso:
        return "Uso";
      case MovimentoEstoqueTipo.descarte:
        return "Descarte";
      case MovimentoEstoqueTipo.ajuste:
        return "Ajuste";
      case MovimentoEstoqueTipo.cancelamento:
        return "Cancelamento";
    }
  }

  IconData get icon {
    switch (this) {
      case MovimentoEstoqueTipo.venda:
        return Icons.point_of_sale_rounded;
      case MovimentoEstoqueTipo.uso:
        return Icons.build_circle_outlined;
      case MovimentoEstoqueTipo.descarte:
        return Icons.delete_outline_rounded;
      case MovimentoEstoqueTipo.ajuste:
        return Icons.tune_rounded;
      case MovimentoEstoqueTipo.cancelamento:
        return Icons.cancel_outlined;
    }
  }
}

class MovimentacaoEstoqueData {
  final EtiquetaModel etiqueta;
  final MovimentoEstoqueTipo tipo;
  final num quantidade;
  final String observacao;

  const MovimentacaoEstoqueData({
    required this.etiqueta,
    required this.tipo,
    required this.quantidade,
    required this.observacao,
  });
}

class MovimentarEstoqueModal extends StatefulWidget {
  final EtiquetaModel etiqueta;

  const MovimentarEstoqueModal({
    super.key,
    required this.etiqueta,
  });

  @override
  State<MovimentarEstoqueModal> createState() => _MovimentarEstoqueModalState();
}

class _MovimentarEstoqueModalState extends State<MovimentarEstoqueModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeCtrl = TextEditingController(text: '1');
  final _obsCtrl = TextEditingController();
  bool _ajusteEntrada = true;

  MovimentoEstoqueTipo _tipo = MovimentoEstoqueTipo.venda;

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _loteFormatado() {
    final custom = Map<String, dynamic>.from(widget.etiqueta.camposCustomValores);
    final loteRaw = custom["lote"];

    if (loteRaw is Map) {
      final m = Map<String, dynamic>.from(loteRaw);
      final value = m["value"]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return formatarLote(value, formato: LoteFormato.prefixoL);
      }
    }

    if ((widget.etiqueta.lote ?? '').trim().isNotEmpty) {
      return widget.etiqueta.lote!.trim();
    }

    return "-";
  }

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.etiqueta;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFFDF7ED);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.65);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);
    final accent = isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Movimentar estoque",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.produtoNome,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _info("Validade", _fmtDate(e.dataValidade), text, muted),
                        _info("Lote", _loteFormatado(), text, muted),
                        _info(
                          "Quantidade atual",
                          e.quantidadeRestante.toString(),
                          text,
                          muted,
                        ),
                        _info(
                          "Setor",
                          e.setorNome.trim().isEmpty ? "-" : e.setorNome,
                          text,
                          muted,
                        ),
                        _info(
                          "Categoria",
                          e.categoriaNome.trim().isEmpty ? "-" : e.categoriaNome,
                          text,
                          muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Tipo de movimentação",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MovimentoEstoqueTipo.values.map((tipo) {
                      final selected = _tipo == tipo;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(tipo.label),
                        avatar: Icon(tipo.icon, size: 18),
                        onSelected: (_) => setState(() => _tipo = tipo),
                        selectedColor: accent.withOpacity(0.18),
                        labelStyle: TextStyle(
                          color: selected ? accent : text,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: selected ? accent : border,
                        ),
                        backgroundColor: card,
                      );
                    }).toList(),
                  ),
                  if (_tipo == MovimentoEstoqueTipo.ajuste) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            selected: _ajusteEntrada,
                            label: const Text("Entrada (+)"),
                            onSelected: (_) => setState(() => _ajusteEntrada = true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            selected: !_ajusteEntrada,
                            label: const Text("Saída (-)"),
                            onSelected: (_) => setState(() => _ajusteEntrada = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_tipo != MovimentoEstoqueTipo.cancelamento) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantidadeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Quantidade",
                        filled: true,
                        fillColor: card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (v) {
                        final n = num.tryParse((v ?? '').replaceAll(',', '.'));
                        if (n == null) return "Informe uma quantidade válida";
                        if (n <= 0) {
                          return "Informe uma quantidade maior que zero";
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _obsCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Observação",
                      hintText: "Opcional",
                      filled: true,
                      fillColor: card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) return;

                        num qtd = num.parse(
                          _quantidadeCtrl.text.trim().replaceAll(',', '.'),
                        );

                        if (_tipo == MovimentoEstoqueTipo.ajuste && !_ajusteEntrada) {
                          qtd = -qtd;
                        }

                        Navigator.pop(
                          context,
                          MovimentacaoEstoqueData(
                            etiqueta: e,
                            tipo: _tipo,
                            quantidade: qtd,
                            observacao: _obsCtrl.text.trim(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded, color: Colors.white,),
                      label: const Text("Confirmar movimentação"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value, Color text, Color muted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}