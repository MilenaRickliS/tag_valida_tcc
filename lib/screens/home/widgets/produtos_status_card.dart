// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'mini_count_badge.dart';

class ProdutosStatusCard extends StatelessWidget {
  final int qtdVencidas;
  final int qtdAlerta;
  final bool loading;

  final double titleSize;
  final double subtitleSize;
  final VoidCallback onOuvirResumo;


  const ProdutosStatusCard({
    super.key,
    required this.qtdVencidas,
    required this.qtdAlerta,
    required this.loading,
    required this.titleSize,
    required this.subtitleSize,
    required this.onOuvirResumo,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
              Color(0xFF90CAF9),
            ],
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
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync_rounded,
                    size: 26,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    "Carregando status dos produtos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize.clamp(22, 28),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Aguarde enquanto os indicadores são atualizados.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.black.withOpacity(0.60),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final emLinha = constraints.maxWidth >= 720;

              final conteudoProdutos = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icone, size: 26, color: tituloColor),
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
              );

              final acessibilidade = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    button: true,
                    label: 'Ouvir resumo das etiquetas',
                    child: GestureDetector(
                      onTap: onOuvirResumo,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white.withOpacity(0.45)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: tituloColor.withOpacity(0.22),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: tituloColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  color: tituloColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Ouvir resumo',
                                style: TextStyle(
                                  color: tituloColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: subtitleSize + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toque no botão para ouvir os alertas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black.withOpacity(0.48),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );

              if (emLinha) {
                return Row(
                  children: [
                    Expanded(flex: 2, child: conteudoProdutos),
                    Container(
                      height: 96,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      color: Colors.white.withOpacity(0.35),
                    ),
                    Expanded(child: acessibilidade),
                  ],
                );
              }

              return Column(
                children: [
                  conteudoProdutos,
                  const SizedBox(height: 17),
                  Container(
                    height: 1,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.white.withOpacity(0.35),
                  ),
                  const SizedBox(height: 17),
                  acessibilidade,
                ],
              );
            },
          ),
        )
      )
    );  
  }
}