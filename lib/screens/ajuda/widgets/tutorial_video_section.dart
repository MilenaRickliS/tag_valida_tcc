// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialVideoSection extends StatelessWidget {
  const TutorialVideoSection({super.key});

  final List<TutorialVideoItem> videos = const [
    TutorialVideoItem(
      title: 'Página de Categorias (Criar, Visualizar, Editar, Excluir)',
      url: 'https://drive.google.com/file/d/1mUUNHfEqqNZgW6zK4dOiey9do9s8Ywyc/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página de Setores (Criar, Visualizar, Editar, Excluir)',
      url: 'https://drive.google.com/file/d/1zMwQcSyo8jLfkAdrz-zKja_J-QwNb2Fb/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página de Tipo de Etiqueta (Criar, Visualizar, Editar, Excluir)',
      url: 'https://drive.google.com/file/d/1rSuNzR7jZkQPN2iozW3H6MVjgjnwv3_W/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Como gerar etiqueta?',
      url: 'https://drive.google.com/file/d/1_T7tI3ouQkGitIiuFAFSZz-7E1X656jr/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página Etiquetas Diárias',
      url: 'https://drive.google.com/file/d/1ec51rchYzgfLjHuJVuOkGSiwT3jIF01r/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página Etiquetas Ativas',
      url: 'https://drive.google.com/file/d/1x39MleFtvj8ptT01tIdOqA0Mo5W7GuF2/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página de Detalhes da Etiqueta (Criar, Visualizar, Editar, Excluir)',
      url: 'https://drive.google.com/file/d/1amLn1OepL-GthoeziW61SM3ac2BHq7AK/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página de Etiquetas Finalizadas',
      url: 'https://drive.google.com/file/d/1AXX7c8J6o_EWOXAbIUUmcs6b9V3H9_b4/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página de Histórico',
      url: 'https://drive.google.com/file/d/1dqBF36X5GP9YKtynp_2cEQKGvH7Hj7kx/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Página de Relatórios',
      url: 'https://drive.google.com/file/d/1i1IF5ujAwRj_LLYw5eg_G2zfaDEJ8LrA/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Ler Qr Code Privado',
      url: 'https://drive.google.com/file/d/1AccxkI9CpZU4RaySFRtKOJEq7h8wW4zW/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Ler Qr Code Público',
      url: 'https://drive.google.com/file/d/1wUqqG5J7X1SORJ_mGpkqDNcxJ1ilWOLC/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Como utilizar a inteligência artificial?',
      url: 'https://drive.google.com/file/d/1GxVtxb7V1-uG8el10FqtdFzQEiH_rVQS/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Catálogo Alimentos',
      url: 'https://drive.google.com/file/d/1g1taygmttWR7o-VuWsd3-OFeIfCbFrME/view?usp=sharing',
    ),
    TutorialVideoItem(
      title: 'Sincronização e Backup de dados',
      url: 'https://drive.google.com/file/d/1hZ9OzX6m5NOwKAOZ08Ajv0QryL2hQp9D/view?usp=sharing',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: videos
          .map(
            (video) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TutorialVideoCard(video: video),
            ),
          )
          .toList(),
    );
  }
}

class TutorialVideoItem {
  final String title;
  final String url;

  const TutorialVideoItem({
    required this.title,
    required this.url,
  });
}

class TutorialVideoCard extends StatelessWidget {
  final TutorialVideoItem video;

  const TutorialVideoCard({
    super.key,
    required this.video,
  });

  Future<void> _openVideo() async {
    final uri = Uri.parse(video.url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final border = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);

    final muted = isDark
        ? Colors.white70
        : Colors.black54;

   return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: border,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.24 : 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4AF37),
                const Color(0xFFFFD54F),
              ],
            ),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: text,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Vídeo tutorial do sistema',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        ElevatedButton.icon(
          onPressed: _openVideo,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text(
            'Assistir',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
  }
}