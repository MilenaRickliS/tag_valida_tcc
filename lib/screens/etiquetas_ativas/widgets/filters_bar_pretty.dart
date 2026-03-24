// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './drop_count.dart';

class FiltersBarPretty extends StatelessWidget {
  final bool fBom;
  final bool fAlerta;
  final bool fVencido;

  final VoidCallback onToggleBom;
  final VoidCallback onToggleAlerta;
  final VoidCallback onToggleVencido;

  final List<String> setores;
  final List<String> categorias;

  final String? setorSelecionado;
  final String? categoriaSelecionada;

  final ValueChanged<String?> onSetorChanged;
  final ValueChanged<String?> onCategoriaChanged;

  final VoidCallback onClearAll;

  final Map<String, int> countBySetor;
  final Map<String, int> countByCategoria;

  final int countBom;
  final int countAlerta;
  final int countVencido;

  const FiltersBarPretty({super.key, 
    required this.fBom,
    required this.fAlerta,
    required this.fVencido,
    required this.onToggleBom,
    required this.onToggleAlerta,
    required this.onToggleVencido,
    required this.setores,
    required this.categorias,
    required this.setorSelecionado,
    required this.categoriaSelecionada,
    required this.onSetorChanged,
    required this.onCategoriaChanged,
    required this.onClearAll,
    required this.countBySetor,
    required this.countByCategoria,
    required this.countBom,
    required this.countAlerta,
    required this.countVencido,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);
    final text = isDark ? Colors.white : Colors.black.withOpacity(0.75);
    final plainChip = isDark ? const Color(0xFF181818) : Colors.white;

    Widget statusChip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      required int count,
      required IconData icon,
    }) {
      Color base;
      Color lightBg;

      switch (label) {
        case "Vencido":
          base = const Color(0xFFB00020);
          lightBg = const Color(0xFFFFEBEE);
          break;
        case "Em alerta":
          base = const Color(0xFFEF6C00);
          lightBg = const Color(0xFFFFF3E0);
          break;
        default:
          base = const Color(0xFF428E2E);
          lightBg = const Color(0xFFE8F5E9);
      }

      final bg = selected
          ? (isDark ? base.withOpacity(0.14) : lightBg)
          : (isDark ? plainChip : Colors.white);

      final fg = selected
          ? base
          : (isDark
              ? const Color(0xFFD6D6D6)
              : const Color.fromARGB(255, 24, 44, 18));

      final borderColor = selected
          ? base.withOpacity(0.35)
          : (isDark
              ? const Color(0xFFD4AF37).withOpacity(0.16)
              : Colors.black.withOpacity(0.10));

      return Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(selected ? 0.06 : 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: fg,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: selected ? base : base.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? base.withOpacity(0.20) : base.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : base,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget clearChip() {
      final iconColor = isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.75);
      final textColor = isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.80);

      return Material(
        color: plainChip,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onClearAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restart_alt_rounded, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  "Limpar",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              statusChip(
                label: "Bom",
                selected: fBom,
                onTap: onToggleBom,
                count: countBom,
                icon: Icons.check_circle_outline_rounded,
              ),
              statusChip(
                label: "Em alerta",
                selected: fAlerta,
                onTap: onToggleAlerta,
                count: countAlerta,
                icon: Icons.notification_important_outlined,
              ),
              statusChip(
                label: "Vencido",
                selected: fVencido,
                onTap: onToggleVencido,
                count: countVencido,
                icon: Icons.warning_amber_rounded,
              ),
              clearChip(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Refinar por",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, c) {
              final isNarrow = c.maxWidth < 600;

              if (!isNarrow) {
                return Row(
                  children: [
                    Expanded(
                      child: DropCount(
                        label: "Setor",
                        value: setorSelecionado,
                        items: setores,
                        onChanged: onSetorChanged,
                        counts: countBySetor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropCount(
                        label: "Categoria",
                        value: categoriaSelecionada,
                        items: categorias,
                        onChanged: onCategoriaChanged,
                        counts: countByCategoria,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  DropCount(
                    label: "Setor",
                    value: setorSelecionado,
                    items: setores,
                    onChanged: onSetorChanged,
                    counts: countBySetor,
                  ),
                  const SizedBox(height: 10),
                  DropCount(
                    label: "Categoria",
                    value: categoriaSelecionada,
                    items: categorias,
                    onChanged: onCategoriaChanged,
                    counts: countByCategoria,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
