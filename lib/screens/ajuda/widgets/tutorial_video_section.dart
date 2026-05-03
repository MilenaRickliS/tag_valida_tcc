// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialVideoSection extends StatelessWidget {
  const TutorialVideoSection({super.key});

  final List<TutorialVideoItem> videos = const [
    TutorialVideoItem(
      title: 'Página de Categorias (Criar, Visualizar, Editar, Excluir)',
      assetPath: 'assets/videos/categorias.mp4',
    ),
    TutorialVideoItem(
      title: 'Página de Setores (Criar, Visualizar, Editar, Excluir)',
      assetPath: 'assets/videos/setores.mp4',
    ),
    TutorialVideoItem(
      title: 'Página de Tipo de Etiqueta (Criar, Visualizar, Editar, Excluir)',
      assetPath: 'assets/videos/tipo_de_etiqueta.mp4',
    ),
    TutorialVideoItem(
      title: 'Como gerar etiqueta?',
      assetPath: 'assets/videos/gerar_etiqueta.mp4',
    ),
    TutorialVideoItem(
      title: 'Página Etiquetas Diárias',
      assetPath: 'assets/videos/etiquetas_diarias.mp4',
    ),
    TutorialVideoItem(
      title: 'Página Etiquetas Ativas',
      assetPath: 'assets/videos/etiquetas_ativas.mp4',
    ),
    TutorialVideoItem(
      title: 'Página de Detalhes da Etiqueta (Criar, Visualizar, Editar, Excluir)',
      assetPath: 'assets/videos/detalhes_etiqueta.mp4',
    ),
    TutorialVideoItem(
      title: 'Página de Etiquetas Finalizadas',
      assetPath: 'assets/videos/etiquetas_finalizadas.mp4',
    ),
    TutorialVideoItem(
      title: 'Página de Histórico',
      assetPath: 'assets/videos/historico.mp4',
    ),
    TutorialVideoItem(
      title: 'Página de Relatórios',
      assetPath: 'assets/videos/relatorios.mp4',
    ),
    TutorialVideoItem(
      title: 'Ler Qr Code Privado',
      assetPath: 'assets/videos/ler_qr_privado.mp4',
    ),
    TutorialVideoItem(
      title: 'Ler Qr Code Público',
      assetPath: 'assets/videos/ler_qr_publico.mp4',
    ),
    TutorialVideoItem(
      title: 'Como utilizar a inteligência artificial?',
      assetPath: 'assets/videos/ia.mp4',
    ),
    TutorialVideoItem(
      title: 'Catálogo Alimentos',
      assetPath: 'assets/videos/catalogo.mp4',
    ),
    TutorialVideoItem(
      title: 'Sincronização e Backup de dados',
      assetPath: 'assets/videos/sincronizacao_backup.mp4',
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
  final String assetPath;

  const TutorialVideoItem({
    required this.title,
    required this.assetPath,
  });
}

class TutorialVideoCard extends StatefulWidget {
  final TutorialVideoItem video;

  const TutorialVideoCard({
    super.key,
    required this.video,
  });

  @override
  State<TutorialVideoCard> createState() => _TutorialVideoCardState();
}

class _TutorialVideoCardState extends State<TutorialVideoCard> {
  late final VideoPlayerController _controller;
  bool _erro = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.video.assetPath)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      }).catchError((_) {
        if (mounted) setState(() => _erro = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playPause() {
    if (!_controller.value.isInitialized) return;

    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : const Color(0xFF6B6B6B);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
          const SizedBox(height: 10),

          if (_erro)
            Text(
              'Não foi possível carregar este vídeo. Verifique se o arquivo está nos assets.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            )
          else if (!_controller.value.isInitialized)
            Text(
              'Carregando vídeo...',
              style: TextStyle(color: muted),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    IconButton(
                      iconSize: 54,
                      color: Colors.white,
                      onPressed: _playPause,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}