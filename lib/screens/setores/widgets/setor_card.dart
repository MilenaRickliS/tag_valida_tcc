// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/setor_model.dart';

class SetorCard extends StatelessWidget {
  final SetorModel setor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SetorCard({super.key, 
    required this.setor,
    required this.onEdit,
    required this.onDelete,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD6D6D6)
          : Colors.black.withOpacity(0.62);

  Color _border(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD4AF37).withOpacity(0.16)
          : Colors.black.withOpacity(0.07);

  Color _iconColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, color: _iconColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setor.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _text(context),
                  ),
                ),
                if ((setor.descricao ?? "").isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    setor.descricao!,
                    style: TextStyle(color: _muted(context)),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              color: isDark ? const Color(0xFFD4AF37) : null,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}