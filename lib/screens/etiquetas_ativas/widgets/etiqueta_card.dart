// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/etiqueta_model.dart';
import '../../../providers/estoque_mov_local_provider.dart';
import '../../../data/local/repos/etiquetas_local_repo.dart';
import '../../etiqueta_preview/etiqueta_preview.dart';
import '../../criar_etiqueta/criar_etiqueta.dart';
import './mini_pill.dart';

class EtiquetaCard extends StatelessWidget {
  final String uid;
  final EtiquetaModel e;

  const EtiquetaCard({super.key, required this.uid, required this.e});

Future<bool> _confirmDeleteEtiqueta(BuildContext context, String produtoNome) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
  final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
  final cancelColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);

  final ok = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => AlertDialog(
      backgroundColor: dialogBg,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.15)),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Excluir etiqueta?",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: text,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Produto:",
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 4),
          Text(
            "“${produtoNome.isEmpty ? "Sem nome" : produtoNome}”",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "A etiqueta será desativada (exclusão suave).\nEla pode continuar aparecendo em históricos.",
            style: TextStyle(
              color: muted,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: cancelColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            "Cancelar",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB00020),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            "Excluir",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );

  return ok ?? false;
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.07);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final neutralIconBg = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final neutralIconColor = isDark ? const Color(0xFFD4AF37) : Colors.black87;
    final repo = context.read<EtiquetasLocalRepo>();

    final produto = e.produtoNome;
    final categoria = e.categoriaNome;
    final setor = e.setorNome;

    final fab = e.dataFabricacao;
    final val = e.dataValidade;

    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    final vencida = val.isBefore(hoje);
    final alerta = !vencida && val.difference(hoje).inDays <= 3;

    return Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EtiquetaPreviewScreen(uid: uid, etiquetaId: e.id),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
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
                    color: vencida
                        ? Colors.red.withOpacity(0.12)
                        : alerta
                            ? const Color.fromARGB(255, 255, 123, 0).withOpacity(0.12)
                            : neutralIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    vencida
                        ? Icons.warning_amber_rounded
                        : alerta
                            ? Icons.notification_important_outlined
                            : Icons.local_offer_outlined,
                    color: vencida
                      ? Colors.red
                      : alerta
                          ? Colors.orange
                          : neutralIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.isEmpty ? "Sem nome" : produto,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (categoria.isNotEmpty) categoria,
                          if (setor.isNotEmpty) setor,
                        ].join(" • "),
                        style:
                            TextStyle(color: muted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          MiniPill(
                            icon: Icons.calendar_month_outlined,
                            text: "Fab: ${_fmtDate(fab)}",
                          ),
                          MiniPill(
                            icon: Icons.event_available_outlined,
                            text: "Val: ${_fmtDate(val)}",
                            danger: vencida,
                            warn: alerta,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

       Positioned(
        top: 6,
        right: 6,
        child: PopupMenuButton<String>(
          tooltip: "Opções",
          splashRadius: 22,
          offset: const Offset(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 10,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withOpacity(0.92)
                  : Colors.white.withOpacity(0.92),
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.more_vert,
              size: 18,
              color: isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.75),
            ),
          ),
          onSelected: (v) async {
            if (v == "edit") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CriarEtiquetaScreen(editarEtiquetaId: e.id),
                ),
              );
            }

            if (v == "delete") {
              final ok = await _confirmDeleteEtiqueta(context, produto);
              if (!ok) return;

              // ignore: use_build_context_synchronously
              final mov = context.read<EstoqueMovLocalProvider>();

              final before = await repo.getById(uid: uid, id: e.id);
              if (before == null) return;

              final st = (before.statusEstoque.trim().isEmpty)
                  ? "ativo"
                  : before.statusEstoque.trim().toLowerCase();

              final rest = before.quantidadeRestante;

              if (st == "ativo" && rest > 0) {
                await mov.registrarCancelamento(
                  uid: uid,
                  etiquetaId: before.id,
                  quantidade: rest,
                  produtoNome: before.produtoNome,
                  motivo: "Exclusão da etiqueta (removeu do estoque)",
                );
              }

              await mov.registrarExclusao(
                uid: uid,
                etiquetaId: before.id,
                produtoNome: before.produtoNome,
                motivo: "Exclusão suave (tela de ativas)",
              );

              await repo.deleteSoft(uid, before.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Etiqueta excluída.")),
                );
                (context as Element).markNeedsBuild();
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: "edit",
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.edit_outlined,
                  color: isDark ? const Color(0xFFD4AF37) : null,
                ),
                title: Text(
                  "Editar",
                  style: TextStyle(color: isDark ? Colors.white : null),
                ),
              ),
            ),
            PopupMenuItem(
              value: "delete",
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  "Excluir",
                  style: TextStyle(color: isDark ? Colors.white : null),
                ),
              ),
            ),
          ],
        )
      ),
      ],
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return "--/--/----";
    final dd = d.day.toString().padLeft(2, "0");
    final mm = d.month.toString().padLeft(2, "0");
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }
}

