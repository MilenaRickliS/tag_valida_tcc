// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EtiquetaPrintPreview extends StatelessWidget {
  final String produto;
  final String validade;
  final String lote;
  final String quantidade;
  final String qrData;

  const EtiquetaPrintPreview({
    super.key,
    required this.produto,
    required this.validade,
    required this.lote,
    required this.quantidade,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const previewWidth = 420.0;
    const ratio = 60 / 40;
    final previewHeight = previewWidth / ratio;

    return Center(
      child: Container(
        width: previewWidth,
        height: previewHeight,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border.all(
            color: isDark
                ? const Color(0xFFD4AF37).withOpacity(0.16)
                : Colors.black.withOpacity(0.10),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Val: $validade',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lote: $lote',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Qtd: $quantidade',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: qrData,
                    size: 125,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}