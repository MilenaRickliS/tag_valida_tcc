// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class FilterButtonAnimated extends StatelessWidget {
  final int activeCount;
  final VoidCallback onPressed;

  const FilterButtonAnimated({super.key, 
    required this.activeCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.12);
    final text = isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.75);

    return Material(
      color: card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 20, color: text),
              const SizedBox(width: 8),
              Text(
                "Filtros",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: activeCount > 0
                    ? Container(
                        key: ValueKey(activeCount),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFFD4AF37) : Colors.black,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "$activeCount",
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey(0),
                        width: 0,
                        height: 0,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}