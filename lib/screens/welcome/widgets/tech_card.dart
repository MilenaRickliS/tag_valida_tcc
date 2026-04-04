// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

final List<TechItem> techs = const [
    TechItem(
      title: 'Impressora Térmica',
      asset: 'assets/portifolio/impressora.png',
    ),
    TechItem(
      title: 'Etiqueta Térmica',
      asset: 'assets/portifolio/etiqueta.png',
    ),
    TechItem(
      title: 'Tablet',
      asset: 'assets/portifolio/tablet.png',
    ),
    TechItem(
      title: 'Flutter',
      asset: 'assets/portifolio/flutter.png',
    ),
    TechItem(
      title: 'API',
      asset: 'assets/portifolio/api.jpg',
    ),
    TechItem(
      title: 'Yolo V8',
      asset: 'assets/portifolio/yolo.jpg',
    ),
    TechItem(
      title: 'Firebase',
      asset: 'assets/portifolio/firebase.png',
    ),
    TechItem(
      title: 'SQLite',
      asset: 'assets/portifolio/sqlite.png',
    ),
  ];

class TechItem {
  final String title;
  final String asset;

  const TechItem({
    required this.title,
    required this.asset,
  });
}

class TechCard extends StatefulWidget {
  final TechItem item;
  final bool isDark;

  const TechCard({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  State<TechCard> createState() => _TechCardState();
}

class _TechCardState extends State<TechCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.03 : 0.05),
              blurRadius: _pressed ? 8 : 12,
              offset: Offset(0, _pressed ? 3 : 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: _pressed ? 1.04 : 1.0,
                  child: Image.asset(
                    widget.item.asset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported_rounded,
                      size: 42,
                      color: theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
              child: Text(
                widget.item.title,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}