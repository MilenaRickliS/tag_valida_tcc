// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget buildAudienceCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String text,
  required double width,
}) {
  return _AudienceCardZoom(
    icon: icon,
    title: title,
    text: text,
    width: width,
  );
}

class _AudienceCardZoom extends StatefulWidget {
  final IconData icon;
  final String title;
  final String text;
  final double width;

  const _AudienceCardZoom({
    required this.icon,
    required this.title,
    required this.text,
    required this.width,
  });

  @override
  State<_AudienceCardZoom> createState() => _AudienceCardZoomState();
}

class _AudienceCardZoomState extends State<_AudienceCardZoom> {
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
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: _pressed ? 1.05 : 1.0,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: _pressed ? 1.1 : 1.0,
                child: Icon(
                  widget.icon,
                  size: 34,
                  color: const Color(0xFF54A73B),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}