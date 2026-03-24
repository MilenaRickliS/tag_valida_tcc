// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ConfigTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ConfigTile({super.key, 
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF181818) : const Color(0xFFFDF7ED);

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD6D6D6)
          : Colors.black.withOpacity(0.60);

  Color _border(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFD4AF37).withOpacity(0.16)
          : Colors.black.withOpacity(0.10);

  Color _brand(BuildContext context) =>
      _isDark(context) ? const Color(0xFFD4AF37) : const Color(0xFFED7227);

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final card = _card(context);
    final text = _text(context);
    final muted = _muted(context);
    final border = _border(context);
    final brand = _brand(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brand,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? const Color(0xFFD4AF37) : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}