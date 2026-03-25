// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './section_card.dart';

class HeaderActions extends StatelessWidget {
  final bool isPhone;
  final String title;
  final String subtitle;
  final VoidCallback onPickRange;
  final VoidCallback onExportPdf;

  const HeaderActions({super.key, 
    required this.isPhone,
    required this.title,
    required this.subtitle,
    required this.onPickRange,
    required this.onExportPdf,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final accent =
        _isDark(context) ? const Color(0xFFD4AF37) : const Color(0xff428e2e);

    final trailing = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: onPickRange,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: accent),
            foregroundColor: accent,
          ),
          icon: Icon(Icons.date_range, color: accent),
          label: Text('Período', style: TextStyle(color: accent)),
        ),
        FilledButton.icon(
          onPressed: onExportPdf,
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: _isDark(context) ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Salvar PDF'),
        ),
      ],
    );

    return SectionCard(
      title: title,
      trailing: isPhone ? null : trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: _isDark(context)
                  ? const Color(0xFFD6D6D6)
                  : const Color(0xFF6B5E4B),
            ),
          ),
          if (isPhone) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: trailing),
          ],
        ],
      ),
    );
  }
}
