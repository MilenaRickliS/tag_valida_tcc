// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

 final List<FeatureItem> features = const [
    FeatureItem(
      icon: Icons.qr_code_2_rounded,
      title: 'Geração de etiquetas',
      description:
          'Criação de etiquetas inteligentes com QR Code para rastreabilidade dos produtos.',
    ),
    FeatureItem(
      icon: Icons.inventory_2_rounded,
      title: 'Controle de estoque',
      description:
          'Acompanhamento de entradas, saídas, perdas e organização dos itens no freezer.',
    ),
    FeatureItem(
      icon: Icons.event_available_rounded,
      title: 'Controle de validade',
      description:
          'Monitoramento de datas de fabricação e validade com alertas visuais.',
    ),
    FeatureItem(
      icon: Icons.print_rounded,
      title: 'Integração com impressora',
      description:
          'Envio direto para impressoras de etiquetas para agilizar o processo.',
    ),
    FeatureItem(
      icon: Icons.analytics_rounded,
      title: 'Relatórios e histórico',
      description:
          'Visualização de movimentações, perdas, vendas e indicadores importantes.',
    ),
    FeatureItem(
      icon: Icons.auto_awesome_rounded,
      title: 'Apoio de IA',
      description:
          'Uso de visão computacional para auxiliar na análise da condição dos alimentos.',
    ),
  ];


class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class FeatureCard extends StatelessWidget {
  final FeatureItem item;
  final bool isDark;

  const FeatureCard({super.key, 
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF2A2A2A),
                  Color(0xFF1A1A1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFF8CB39),
                  Color(0xFFFFE8A3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.90),
            child: Icon(
              item.icon,
              size: 30,
              color: const Color(0xFF54A73B),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.74),
            ),
          ),
        ],
      ),
    );
  }
}