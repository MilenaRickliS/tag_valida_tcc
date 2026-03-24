import 'package:flutter/material.dart';

class EtiquetaActionsRow extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color borderColor;
  final Color gold;
  final Color darkCard;

  final VoidCallback onSalvarPdf;
  final VoidCallback onPreview;
  final VoidCallback onImprimir;

  const EtiquetaActionsRow({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.borderColor,
    required this.gold,
    required this.darkCard,
    required this.onSalvarPdf,
    required this.onPreview,
    required this.onImprimir,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSalvarPdf,
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: Colors.black,
            ),
            label: const Text("Salvar PDF"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xff88be8e),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPreview,
            icon: Icon(
              Icons.remove_red_eye_outlined,
              color: isDark ? gold : textColor,
            ),
            label: const Text("Pré-visualização"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: isDark ? gold : textColor,
              backgroundColor: isDark ? darkCard : Colors.white,
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onImprimir,
            icon: const Icon(Icons.print_outlined, color: Colors.black),
            label: const Text("Imprimir"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xffF4D58D),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}