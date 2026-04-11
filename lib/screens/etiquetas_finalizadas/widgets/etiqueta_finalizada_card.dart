// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/etiqueta_model.dart';
import './pill.dart';
import './mini_badge.dart';
import '../../etiqueta_detalhes/etiqueta_detalhes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/estoque_mov_local_provider.dart';
import '../../../providers/gerar_etiqueta_local_provider.dart';
import '../../../models/estoque_mov_model.dart';

class EtiquetaFinalizadaCard extends StatelessWidget {
  final String uid;
  final EtiquetaModel e;

  const EtiquetaFinalizadaCard({
    super.key,
    required this.uid,
    required this.e,
  });

  Future<num?> _perguntarQuantidade(
    BuildContext context, {
    required num quantidadeInicial,
  }) async {
    final controller = TextEditingController(
      text: quantidadeInicial.toString().replaceAll('.0', ''),
    );

    return showDialog<num>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Reabrir etiqueta',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF2B2B2B),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Informe a quantidade que deve voltar para o estoque.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFD6D6D6)
                      : Colors.black.withOpacity(0.70),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  hintText: 'Ex: 10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = controller.text.trim().replaceAll(',', '.');
                final qtd = num.tryParse(txt);

                if (qtd == null || qtd <= 0) {
                  Navigator.of(dialogContext).pop(-1);
                  return;
                }

                Navigator.of(dialogContext).pop(qtd);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reabrirEtiqueta(BuildContext context, EtiquetaModel etiqueta) async {
    final authProvider = context.read<AuthProvider>();
    final gerarEtiquetaProvider = context.read<GerarEtiquetaLocalProvider>();
    final estoqueMovProvider = context.read<EstoqueMovLocalProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final authUid = authProvider.user?.uid;
    if (authUid == null) return;

    final quantidadeBase = (etiqueta.quantidadeRestante > 0)
        ? etiqueta.quantidadeRestante
        : (etiqueta.quantidade > 0 ? etiqueta.quantidade : 1);

    final quantidadeParaReabrir = await _perguntarQuantidade(
      context,
      quantidadeInicial: quantidadeBase,
    );

    if (quantidadeParaReabrir == null) return;

    if (quantidadeParaReabrir <= 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade válida maior que zero.'),
        ),
      );
      return;
    }

    try {
      debugPrint('REABRINDO ETIQUETA: ${etiqueta.id}');
      debugPrint('UID: $authUid');
      debugPrint('QTD: $quantidadeParaReabrir');

      await gerarEtiquetaProvider.reabrirEtiqueta(
        uid: authUid,
        etiquetaId: etiqueta.id,
        quantidadeRestante: quantidadeParaReabrir,
      );

      await estoqueMovProvider.registrar(
        uid: authUid,
        etiquetaId: etiqueta.id,
        tipo: EstoqueMovModel.tipoAjusteEntrada,
        quantidade: quantidadeParaReabrir,
        produtoNome: etiqueta.produtoNome,
        motivo: 'Reabertura da etiqueta',
      );

      debugPrint('ETIQUETA REABERTA COM SUCESSO');

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Etiqueta reaberta e devolvida ao estoque.'),
        ),
      );
    } catch (e) {
      debugPrint('ERRO AO REABRIR ETIQUETA: $e');

      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao reabrir etiqueta: $e'),
        ),
      );
    }
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) => _isDark(context)
      ? const Color(0xFFD6D6D6)
      : Colors.black.withOpacity(0.60);

  Color _border(BuildContext context) => _isDark(context)
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.07);

  @override
  Widget build(BuildContext context) {
    final produto = e.produtoNome.trim().isEmpty ? "Sem nome" : e.produtoNome;
    final setor = e.setorNome.trim();
    final categoria = e.categoriaNome.trim();

    final st = (e.statusEstoque.trim().isEmpty)
        ? "ativo"
        : e.statusEstoque.trim().toLowerCase();

    final isVendido = st == "vendido";
    final isCancelado = st == "cancelado";

    final badgeBg = isVendido
        ? Colors.orange.withOpacity(0.12)
        : isCancelado
            ? Colors.red.withOpacity(0.10)
            : Colors.black.withOpacity(0.06);

    final badgeFg = isVendido
        ? Colors.orange.shade900
        : isCancelado
            ? Colors.red.shade800
            : Colors.black87;

    String badgeText() => isVendido ? "Vendido" : "Cancelado";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EtiquetaDetalhesScreen(uid: uid, etiquetaId: e.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isDark(context) ? 0.18 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeFg.withOpacity(0.18)),
              ),
              child: Icon(
                isVendido ? Icons.local_mall_outlined : Icons.block_outlined,
                color: badgeFg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          produto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _text(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      MiniBadge(text: badgeText(), fg: badgeFg, bg: badgeBg),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (e.tipoNome.trim().isNotEmpty) e.tipoNome.trim(),
                      if (categoria.isNotEmpty) categoria,
                      if (setor.isNotEmpty) setor,
                    ].join(" • "),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _muted(context)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Pill(
                        icon: Icons.numbers_outlined,
                        text: "Qtd: ${_fmtNum(e.quantidade)}",
                      ),
                      Pill(
                        icon: Icons.inventory_2_outlined,
                        text: "Rest: ${_fmtNum(e.quantidadeRestante)}",
                      ),
                      Pill(
                        icon: Icons.event_available_outlined,
                        text: "Val: ${_fmtDate(e.dataValidade)}",
                      ),
                      if (e.soldAt != null)
                        Pill(
                          icon: Icons.schedule_rounded,
                          text: "Final: ${_fmtDt(e.soldAt!)}",
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _reabrirEtiqueta(context, e),
                          icon: Icon(
                            Icons.restart_alt_rounded,
                            size: 18,
                            color: _isDark(context) ? Colors.black : Colors.white,
                          ),
                          label: const Text(
                            "Reabrir",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDark(context)
                                ? const Color(0xFFD4AF37)
                                : const Color(0xFF428E2E),
                            foregroundColor:
                                _isDark(context) ? Colors.black : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return "--/--/----";
    final dd = d.day.toString().padLeft(2, "0");
    final mm = d.month.toString().padLeft(2, "0");
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  static String _fmtDt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}";
  }

  static String _fmtNum(num v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(".", ",");
  }
}