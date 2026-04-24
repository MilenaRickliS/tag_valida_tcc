 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './metric_chip.dart';

Widget buildHeroResultado({
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required String estadoGeral,
    required Color corPrincipal,
    required String produtoPrincipal,
    required double confiancaMedia,
    required bool success,
    required int quantidadeDetectada,
  }) {
    final tituloEstado = tituloEstadoHero(estadoGeral);
    final subtitulo = produtoPrincipal.isNotEmpty
        ? '$produtoPrincipal em análise'
        : 'Resultado geral da inspeção';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            corPrincipal.withOpacity(isDark ? 0.28 : 0.18),
            corPrincipal.withOpacity(isDark ? 0.14 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: corPrincipal.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: corPrincipal.withOpacity(isDark ? 0.10 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: corPrincipal.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  estadoIcon(estadoGeral),
                  color: corPrincipal,
                  size: 30,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDark ? 0.08 : 0.55),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: corPrincipal.withOpacity(0.20),
                  ),
                ),
                child: Text(
                  success ? 'Análise concluída' : 'Falha na análise',
                  style: TextStyle(
                    color: corPrincipal,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            tituloEstado,
            style: TextStyle(
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: corPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            acaoDescricao(estadoGeral),
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                icon: Icons.inventory_2_rounded,
                label: '$quantidadeDetectada item(ns)',
                color: corPrincipal,
              ),
              MetricChip(
                icon: Icons.analytics_rounded,
                label: '${confiancaMedia.toStringAsFixed(0)}% de confiança média',
                color: corPrincipal,
              ),
              MetricChip(
                icon: Icons.verified_rounded,
                label: acaoTitulo(estadoGeral),
                color: corPrincipal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color estadoColor(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return const Color(0xFF54A73B);
      case 'alerta':
        return const Color(0xFFED7227);
      case 'vencido':
        return const Color(0xFFE53935);
      default:
        return Colors.blueGrey;
    }
  }


  IconData estadoIcon(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return Icons.check_circle_rounded;
      case 'alerta':
        return Icons.warning_amber_rounded;
      case 'vencido':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String tituloEstadoHero(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'bom':
        return 'Produto em bom estado';
      case 'alerta':
        return 'Produto em estado de alerta';
      case 'vencido':
        return 'Produto fora do padrão';
      default:
        return 'Resultado inconclusivo';
    }
  }

  String acaoTitulo(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Tire da venda';
      case 'alerta':
        return 'Priorizar venda';
      case 'bom':
        return 'Apto para venda';
      default:
        return 'Revisão necessária';
    }
  }

  String acaoDescricao(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return 'Este item apresenta condição incompatível com a comercialização. Recomendamos retirar da área de venda e seguir o procedimento interno de avaliação ou descarte.';
      case 'alerta':
        return 'Este item exige atenção. Recomendamos priorizar sua saída, revisar sua condição e manter acompanhamento mais próximo para evitar perdas.';
      case 'bom':
        return 'Este item apresenta condição adequada para comercialização no momento. Mantenha o monitoramento dentro da rotina padrão da operação.';
      default:
        return 'Não foi possível definir uma ação automática com segurança. Faça uma conferência manual do item.';
    }
  }

  IconData acaoIcone(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'vencido':
        return Icons.block_rounded;
      case 'alerta':
        return Icons.priority_high_rounded;
      case 'bom':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
