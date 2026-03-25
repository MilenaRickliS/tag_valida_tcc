// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'mini_count_badge.dart';

class ProdutosStatusCard extends StatelessWidget {
  final int qtdVencidas;
  final int qtdAlerta;
  final bool loading;

  final double titleSize;
  final double subtitleSize;

  const ProdutosStatusCard({
    super.key,
    required this.qtdVencidas,
    required this.qtdAlerta,
    required this.loading,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    final hasVencidas = qtdVencidas > 0;
    final hasAlerta = qtdAlerta > 0;

    late final String titulo;
    late final String subtitulo;
    late final List<Color> grad;
    late final Color tituloColor;
    late final VoidCallback onTap;
    late final Widget? badge;
    late final IconData icone;

    if (hasVencidas) {
      titulo = "Produtos vencidos";
      subtitulo = "Clique aqui para visualizar seus produtos vencidos";
      grad = const [
        Color(0xFFFFD6D6),
        Color(0xFFFF8A80),
        Color(0xFFD32F2F),
      ];
      tituloColor = const Color(0xFFB71C1C);
      icone = Icons.error_rounded;

      badge = MiniCountBadge(
        text: "$qtdVencidas vencido(s)",
        bg: Colors.white.withOpacity(0.85),
        fg: const Color(0xFFB71C1C),
      );

      onTap = () => Navigator.pushNamed(
            context,
            '/etiquetas-ativas',
            arguments: const {"statusFiltro": "vencido"},
          );
    } else if (hasAlerta) {
      titulo = "Produtos em alerta";
      subtitulo = "Clique aqui para visualizar seus produtos em alerta";
      grad = const [
        Color(0xFFFFF3C4),
        Color(0xFFFFD54F),
        Color(0xFFF9A825),
      ];
      tituloColor = const Color(0xFF8D6E00);
      icone = Icons.warning_amber_rounded;

      badge = MiniCountBadge(
        text: "$qtdAlerta em alerta",
        bg: Colors.white.withOpacity(0.85),
        fg: const Color(0xFF8D6E00),
      );

      onTap = () => Navigator.pushNamed(
            context,
            '/etiquetas-ativas',
            arguments: const {"statusFiltro": "alerta"},
          );
    } else {
      titulo = "Todos os produtos\ndentro da validade";
      subtitulo = "Clique aqui para visualizar seus produtos";
      grad = const [
        Color(0xFFB7E4C7),
        Color(0xFF74C69D),
        Color(0xFF40916C),
      ];
      tituloColor = const Color(0xFF2E8B73);
      icone = Icons.check_circle_rounded;

      badge = null;

      onTap = () => Navigator.pushNamed(context, '/etiquetas-ativas');
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: grad,
          ),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            if (loading)
              const LinearProgressIndicator(minHeight: 3),

            if (loading) const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icone,
                    size: 26,
                    color: tituloColor,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      color: tituloColor,
                    ),
                  ),
                ),
              ],
            ),

            if (badge != null) ...[
              const SizedBox(height: 10),
              badge,
            ],

            const SizedBox(height: 12),

            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                decoration: TextDecoration.underline,
                color: Colors.black.withOpacity(0.60),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}