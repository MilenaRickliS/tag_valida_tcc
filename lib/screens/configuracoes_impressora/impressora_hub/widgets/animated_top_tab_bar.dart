// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnimatedTopTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color accent;
  final Color accent2;
  final Color gold;

  const AnimatedTopTabBar({super.key, 
    required this.controller,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.accent,
    required this.accent2,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? gold.withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isDark
                ? [gold.withOpacity(0.95), const Color(0xFFF4D58D)]
                : [accent, accent2],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? gold : accent).withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: textColor.withOpacity(0.78),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashBorderRadius: BorderRadius.circular(14),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.home_rounded),
            text: 'Página inicial',
          ),
          Tab(
            icon: Icon(Icons.palette_outlined),
            text: 'Design da etiqueta',
          ),
        ],
      ),
    );
  }
}