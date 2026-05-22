// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';


class EtiquetaLoadingView extends StatefulWidget {
  final bool isDark;
  final bool offline;

  const EtiquetaLoadingView({super.key, 
    required this.isDark,
    required this.offline,
  });

  @override
  State<EtiquetaLoadingView> createState() =>
      _EtiquetaLoadingViewState();
}

class _EtiquetaLoadingViewState
    extends State<EtiquetaLoadingView> {
  int index = 0;

  final mensagens = [
    'Carregando etiqueta...',
    'Buscando dados salvos...',
    'Sincronizando informações...',
    'Preparando visualização...',
  ];

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return false;

      setState(() {
        index = (index + 1) % mensagens.length;
      });

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4AF37);
    final orange = const Color(0xFFED7227);

    final textColor =
        widget.isDark ? Colors.white : const Color(0xFF2B2B2B);

    final muted =
        widget.isDark ? const Color(0xFFD6D6D6) : const Color(0xFF6B6B6B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? gold.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  size: 52,
                  color: widget.isDark ? gold : orange,
                ),

                const SizedBox(height: 18),

                Text(
                  'TagValida',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 18),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    backgroundColor:
                        Colors.grey.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(
                      widget.isDark ? gold : orange,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    mensagens[index],
                    key: ValueKey(index),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.offline
                      ? 'Modo offline ativo.'
                      : 'Isso pode levar alguns segundos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (widget.offline) ...[
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Carregando dados locais',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}