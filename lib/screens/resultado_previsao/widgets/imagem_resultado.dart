 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget buildImagemResultado({
  required String imageUrl,
  required String fallbackPath,
  required Color cardColor,
  required Color borderColor,
}) {
  Widget buildZoomableImage(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        panEnabled: true,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(24),
        child: SizedBox.expand(
          child: child,
        ),
      ),
    );
  }

  Widget fallbackWidget() {
    return const Center(
      child: Text('Não foi possível carregar a imagem'),
    );
  }

  return Container(
    width: double.infinity,
    height: 340,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.03),
            child: imageUrl.isNotEmpty
                ? buildZoomableImage(
                    Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => fallbackWidget(),
                    ),
                  )
                : buildZoomableImage(
                    fallbackWidget(),
                  ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Use dois dedos para dar zoom',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}