// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EtiquetaQrCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final String qrData;
  final VoidCallback onTapQr;

  const EtiquetaQrCard({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.qrData,
    required this.onTapQr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFD4AF37).withOpacity(0.25)
                    : borderColor,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTapQr,
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    size: 180,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Toque para tela cheia",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Escaneie para abrir e gerar PDF",
            style: TextStyle(fontSize: 12.5, color: textColor),
          ),
        ],
      ),
    );
  }
}