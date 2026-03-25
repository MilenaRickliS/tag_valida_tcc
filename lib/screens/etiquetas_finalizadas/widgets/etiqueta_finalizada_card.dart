// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/etiqueta_model.dart';
import './pill.dart';
import './mini_badge.dart';
import '../../etiqueta_preview/etiqueta_preview.dart';

class EtiquetaFinalizadaCard extends StatelessWidget {
  final String uid;
  final EtiquetaModel e;

  const EtiquetaFinalizadaCard({super.key, 
    required this.uid,
    required this.e,
  });

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
            builder: (_) => EtiquetaPreviewScreen(uid: uid, etiquetaId: e.id),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Reabrir no estoque (implementar)"),
                              ),
                            );
                          },
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
                          icon: Icon(
                            Icons.restart_alt_rounded,
                            size: 18,
                            color: _isDark(context) ? Colors.black : Colors.white,
                          ),
                          label: const Text(
                            "Reabrir",
                            style: TextStyle(fontWeight: FontWeight.w900),
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

