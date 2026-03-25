// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/user.dart';
import 'pill.dart';
import 'header_button.dart';
import 'initials_avatar.dart';

class HeaderCard extends StatelessWidget {
  final UserModel user;
  final bool compact;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const HeaderCard({super.key, 
    required this.user,
    required this.compact,
    required this.onEdit,
    required this.onLogout,
  });

  static const _brand = Color(0xFFED7227);
  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : const Color(0xFF6B6B6B);
    final border = isDark
        ? _gold.withOpacity(0.16)
        : Colors.black.withOpacity(0.06);
    final shadow = Colors.black.withOpacity(isDark ? 0.28 : 0.06);

    final avatar = _buildAvatar(isDark);

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: shadow,
          ),
        ],
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              avatar,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.razao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: muted.withOpacity(0.95),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Pill(
                          icon: Icons.badge_rounded,
                          text: _maskCnpj(user.cnpj),
                        ),
                        Pill(
                          icon: Icons.place_rounded,
                          text: "${user.cidade}/${user.estado}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                HeaderButtons(
                  onEdit: onEdit,
                  onLogout: onLogout,
                ),
              ],
            ],
          ),
          if (compact) ...[
            const SizedBox(height: 14),
            HeaderButtons(onEdit: onEdit, onLogout: onLogout),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
  
    final logo = user.logo.trim();

    Widget child;
    if (logo.isEmpty) {
      child = InitialsAvatar(text: user.nome);
    } else if (logo.startsWith("http")) {
      child = ClipOval(
        child: Image.network(
          logo,
          width: 78,
          height: 78,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => InitialsAvatar(text: user.nome),
        ),
      );
    } else if (logo.startsWith("assets/")) {
      child = ClipOval(
        child: Image.asset(
          logo,
          width: 78,
          height: 78,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => InitialsAvatar(text: user.nome),
        ),
      );
    } else {
     
      child = InitialsAvatar(text: user.nome);
    }

    return Container(
      width: 86,
      height: 86,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
           colors: isDark
              ? [
                  _gold.withOpacity(0.95),
                  _gold.withOpacity(0.35),
                ]
              : [
                  _brand.withOpacity(0.95),
                  _brand.withOpacity(0.35),
                ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            width: 2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  String _maskCnpj(String cnpj) {
    final digits = cnpj.replaceAll(RegExp(r"\D"), "");
    if (digits.length != 14) return cnpj;
    return "${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}";
  
  }
}
