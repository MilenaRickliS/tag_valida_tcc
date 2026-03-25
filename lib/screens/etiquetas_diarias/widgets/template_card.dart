// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class TemplateCard extends StatefulWidget {
  final String produtoNome;
  final String linha2;
  final String linha3;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool dense;

  const TemplateCard({super.key, 
    required this.produtoNome,
    required this.linha2,
    required this.linha3,
    required this.onTap,
    required this.onDelete,
    required this.dense,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool _hover = false;
  bool _pressed = false;

  Future<bool> _confirmDelete(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.12);
    final cancelColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.22)),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Excluir template?",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "Isso remove o modelo diário salvo. Você pode criar novamente depois, se precisar.",
          style: TextStyle(color: isDark ? const Color(0xFFD6D6D6) : null),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: cancelColor,
              side: BorderSide(color: border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              elevation: 0,
            ),
            child: const Text("Excluir"),
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
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.75);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.06);
    final gold = const Color(0xFFD4AF37);

    final scale = _pressed ? 0.985 : (_hover ? 1.01 : 1.0);
    final dy = _hover ? -2.0 : 0.0;

    final parts = widget.linha2.split("•").map((e) => e.trim()).toList();
    final tipo = parts.isNotEmpty ? parts.first : widget.linha2;
    final categoria = parts.length > 1 ? parts[1] : "";
    final setor = widget.linha3;

    Widget infoRow({
      required IconData icon,
      required String label,
      required String value,
    }) {
      if (value.trim().isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 15,
              color: isDark ? gold : Colors.black.withOpacity(0.55),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    color: muted,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: "$label: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    const TextSpan(
                      text: "",
                    ),
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, dy)..scale(scale),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hover
                  ? (isDark ? gold.withOpacity(0.25) : Colors.black.withOpacity(0.10))
                  : border,
              width: _hover ? 1.2 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hover ? (isDark ? 0.22 : 0.08) : (isDark ? 0.18 : 0.05)),
                blurRadius: _hover ? 26 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.dense ? 12 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: widget.dense ? 46 : 52,
                  height: widget.dense ? 46 : 52,
                  decoration: BoxDecoration(
                    color: isDark ? gold : const Color(0xFF428E2E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? gold : const Color(0xFF428E2E)).withOpacity(0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: isDark ? Colors.black : Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.produtoNome,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: widget.dense ? 15.5 : 16.8,
                                height: 1.15,
                                color: text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            tooltip: "Opções",
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            iconSize: 20,
                            icon: Icon(
                              Icons.more_horiz,
                              color: isDark ? gold : const Color(0xFF2B2B2B),
                            ),
                            onSelected: (v) async {
                              if (v == "delete") {
                                final ok = await _confirmDelete(context);
                                if (ok) widget.onDelete();
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem<String>(
                                value: "delete",
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline, color: Colors.red),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Excluir",
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      infoRow(
                        icon: Icons.local_offer_outlined,
                        label: "Tipo",
                        value: tipo,
                      ),
                      infoRow(
                        icon: Icons.category_outlined,
                        label: "Categoria",
                        value: categoria,
                      ),
                      infoRow(
                        icon: Icons.storefront_outlined,
                        label: "Setor",
                        value: setor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}