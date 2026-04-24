 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './acao_recomendada_card.dart';
 
 Widget buildAcaoPrincipal({
    required String estado,
    required Color card,
    required Color border,
    required bool isDark,
  }) {
    final color = estadoColor(estado);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AcaoRecomendadaCard(
        estado: estado,
        titulo: acaoTitulo(estado),
        descricao: acaoDescricao(estado),
        icon: acaoIcone(estado),
        color: color,
        isDark: isDark,
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
