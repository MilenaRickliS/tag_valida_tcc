// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'clear_filters_button.dart';

class TemplatesHeader extends StatelessWidget {
  final bool isDark;
  final Color card;
  final Color cardAlt;
  final Color text;
  final Color muted;
  final Color border;
  final Color gold;

  final TextEditingController searchCtrl;
  final String query;
  final String? setorSel;
  final String? categoriaSel;
  final List<String> setores;
  final List<String> categorias;
  final int filteredCount;

  final VoidCallback onRefresh;
  final VoidCallback onClearAll;
  final ValueChanged<String?> onSetorChanged;
  final ValueChanged<String?> onCategoriaChanged;
  final VoidCallback onClearSearch;

  const TemplatesHeader({
    super.key,
    required this.isDark,
    required this.card,
    required this.cardAlt,
    required this.text,
    required this.muted,
    required this.border,
    required this.gold,
    required this.searchCtrl,
    required this.query,
    required this.setorSel,
    required this.categoriaSel,
    required this.setores,
    required this.categorias,
    required this.filteredCount,
    required this.onRefresh,
    required this.onClearAll,
    required this.onSetorChanged,
    required this.onCategoriaChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    Widget dropdown({
      required String label,
      required String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
      required IconData icon,
    }) {
      return DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        style: TextStyle(color: text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: isDark ? gold : const Color(0xFF2B2B2B),
          ),
          labelStyle: TextStyle(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: isDark ? gold : const Color(0xFF2B2B2B),
            fontWeight: FontWeight.w800,
          ),
          filled: true,
          fillColor: cardAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? gold : const Color(0xFF2B2B2B),
              width: 1.6,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text("Todos"),
          ),
          ...items.map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      );
    }

    final search = TextField(
      controller: searchCtrl,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        hintText: "Pesquisar por nome do produto...",
        hintStyle: TextStyle(color: muted),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? gold : const Color(0xFF2B2B2B),
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: "Limpar",
                onPressed: onClearSearch,
                icon: Icon(
                  Icons.close,
                  color: isDark ? gold : const Color(0xFF2B2B2B),
                ),
              ),
        filled: true,
        fillColor: cardAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? gold : const Color(0xFF2B2B2B),
            width: 1.6,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );

    final filters = LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;

        if (wide) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              Expanded(
                child: dropdown(
                  label: "Setor",
                  icon: Icons.storefront_outlined,
                  value: setorSel,
                  items: setores,
                  onChanged: onSetorChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: dropdown(
                  label: "Categoria",
                  icon: Icons.category_outlined,
                  value: categoriaSel,
                  items: categorias,
                  onChanged: onCategoriaChanged,
                ),
              ),
              const SizedBox(width: 12),
              ClearFiltersButton(
                enabled: query.isNotEmpty ||
                    setorSel != null ||
                    categoriaSel != null,
                onPressed: onClearAll,
              ),
            ],
          );
        }

        return Column(
          children: [
            search,
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: dropdown(
                    label: "Setor",
                    icon: Icons.storefront_outlined,
                    value: setorSel,
                    items: setores,
                    onChanged: onSetorChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dropdown(
                    label: "Categoria",
                    icon: Icons.category_outlined,
                    value: categoriaSel,
                    items: categorias,
                    onChanged: onCategoriaChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ClearFiltersButton(
                enabled: query.isNotEmpty ||
                    setorSel != null ||
                    categoriaSel != null,
                onPressed: onClearAll,
              ),
            ),
          ],
        );
      },
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Etiquetas diárias",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Escolha um molde para criar uma nova etiqueta no estoque de forma rápida.",
            style: TextStyle(color: muted, height: 1.35),
          ),
          const SizedBox(height: 14),
          filters,
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cardAlt,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: border),
                ),
                child: Text(
                  "$filteredCount item(ns)",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? gold : text,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: "Recarregar",
                onPressed: onRefresh,
                icon: Icon(
                  Icons.refresh,
                  color: isDark ? gold : text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}