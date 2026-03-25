import 'package:flutter/material.dart';
import '../../../models/setor_model.dart';
import 'setor_card.dart';

class SetoresList extends StatelessWidget {
  final bool loading;
  final List<SetorModel> items;
  final Color mutedColor;

  final Function(SetorModel) onEdit;
  final Function(SetorModel) onDelete;

  const SetoresList({
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
            "Nenhum setor cadastrado ainda.\nClique em “Novo setor”.",
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
          final s = items[i];
          return SetorCard(
            setor: s,
            onEdit: () => onEdit(s),
            onDelete: () => onDelete(s),
          );
        },
      ),
    );
  }
}