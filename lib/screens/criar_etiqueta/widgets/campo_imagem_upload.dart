// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CampoImagemUploadCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final bool obrigatorio;
  final bool isDark;
  final Future<void> Function() onUpload;
  final VoidCallback? onRemove;

  const CampoImagemUploadCard({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.obrigatorio,
    required this.isDark,
    required this.onUpload,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted =
        isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.12);
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);

    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            obrigatorio ? '$label *' : label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 10),
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: Text(
                    'Não foi possível carregar a imagem.',
                    style: TextStyle(color: muted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ] else
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: brand.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brand.withOpacity(0.18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, color: brand, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma imagem enviada',
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(hasImage ? Icons.refresh : Icons.upload),
                  label: Text(hasImage ? 'Trocar imagem' : 'Fazer upload'),
                ),
              ),
              if (hasImage && onRemove != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Remover imagem',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}