// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/local/repos/etiquetas_local_repo.dart';
import '../../../models/etiqueta_model.dart';
import './empty_box.dart';
import './etiqueta_finalizada_card.dart';

class FinalizadasList extends StatelessWidget {
  final String uid;
  final String? statusEstoqueFilter;
  final String query;

  const FinalizadasList({super.key, 
    required this.uid,
    required this.statusEstoqueFilter,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<EtiquetasLocalRepo>();

    return FutureBuilder<List<EtiquetaModel>>(
      future: repo.listByPeriodo(
        uid: uid,
        inicio: DateTime(2000, 1, 1),
        fim: DateTime(2100, 1, 1),
        status: "ativa",
        tipoId: null,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return EmptyBox(
            icon: Icons.error_outline,
            title: "Erro ao carregar",
            subtitle: snap.error.toString(),
          );
        }

        var all = snap.data ?? [];

        all = all.where((e) {
          final st = (e.statusEstoque.trim().isEmpty)
              ? "ativo"
              : e.statusEstoque.trim().toLowerCase();
          final isFinal = st == "vendido" || st == "cancelado";
          if (!isFinal) return false;

          if (statusEstoqueFilter != null && st != statusEstoqueFilter) {
            return false;
          }

          final q = query.trim().toLowerCase();
          if (q.isNotEmpty) {
            final s = [
              e.produtoNome,
              e.categoriaNome,
              e.setorNome,
              e.tipoNome,
              e.id,
              st,
            ].join(" ").toLowerCase();
            if (!s.contains(q)) return false;
          }
          return true;
        }).toList();

        DateTime sortKey(EtiquetaModel e) {
          return e.soldAt ??
              e.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(int.tryParse(e.id) ?? 0);
        }

        all.sort((a, b) => sortKey(b).compareTo(sortKey(a)));

        if (all.isEmpty) {
          return const EmptyBox(
            icon: Icons.inventory_2_outlined,
            title: "Nada por aqui",
            subtitle: "Não há etiquetas finalizadas nesse filtro.",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 14),
          itemCount: all.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: EtiquetaFinalizadaCard(uid: uid, e: all[i]),
          ),
        );
      },
    );
  }
}
