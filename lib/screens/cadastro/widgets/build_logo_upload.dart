// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';

class LogoUploadCard extends StatelessWidget {
  final File? logoFile;
  final bool loading;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;

  const LogoUploadCard({
    super.key,
    required this.logoFile,
    required this.loading,
    required this.onPickLogo,
    required this.onRemoveLogo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onSurface.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image_outlined,
                color: onSurface.withOpacity(0.80),
              ),
              const SizedBox(width: 8),
              Text(
                'Logo da empresa (opcional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Selecione uma imagem para usar como logo da empresa.',
            style: TextStyle(
              fontSize: 13,
              color: onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 12),
          if (logoFile != null) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  logoFile!,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: loading ? null : onPickLogo,
                icon: Icon(
                  Icons.upload_outlined,
                  color: onSurface,
                ),
                label: Text(
                  logoFile == null ? 'Selecionar logo' : 'Trocar logo',
                  style: TextStyle(color: onSurface),
                ),
              ),
              if (logoFile != null)
                OutlinedButton.icon(
                  onPressed: loading ? null : onRemoveLogo,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}