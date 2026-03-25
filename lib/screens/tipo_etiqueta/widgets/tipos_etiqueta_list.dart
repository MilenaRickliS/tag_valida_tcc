import 'package:flutter/material.dart';
import '../../../models/tipo_etiqueta_model.dart';
import 'tipo_card.dart';

class TiposEtiquetaList extends StatelessWidget {
  final bool loading;
  final List<TipoEtiquetaModel> items;
  final Color mutedColor;
  final Function(TipoEtiquetaModel tipo) onEdit;
  final Function(TipoEtiquetaModel tipo) onDelete;

  const TiposEtiquetaList({
    super.key,
    required this.loading,
    required this.items,
    required this.mutedColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            "Nenhum tipo cadastrado ainda.\nClique em “Novo tipo”.",
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = items[i];
          return TipoCard(
            tipo: t,
            onEdit: () => onEdit(t),
            onDelete: () => onDelete(t),
          );
        },
      ),
    );
  }
}