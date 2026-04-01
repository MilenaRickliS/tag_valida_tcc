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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined),
              SizedBox(width: 8),
              Text(
                'Logo da empresa (opcional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Selecione uma imagem para usar como logo da empresa.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
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
                icon: const Icon(Icons.upload_outlined),
                label: Text(
                  logoFile == null ? 'Selecionar logo' : 'Trocar logo',
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