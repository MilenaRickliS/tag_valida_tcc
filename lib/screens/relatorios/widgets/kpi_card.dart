// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final num value;
  final Color bg;
  final Color fg;

  const KpiCard({super.key, 
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final v =
        (value % 1 == 0) ? value.toInt().toString() : value.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: fg.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconFor(label), color: fg, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: fg.withOpacity(0.95),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  v,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'Entradas':
        return Icons.add_circle_outline;
      case 'Vendas':
        return Icons.shopping_cart_outlined;
      case 'Cancelamentos':
        return Icons.cancel_outlined;
      case 'Exclusões':
        return Icons.delete_outline;
      case 'Perdas':
        return Icons.warning_amber_rounded;
      case 'Saldo':
        return Icons.account_balance_wallet_outlined;
      case 'Ajuste Entrada':
        return Icons.tune;
      case 'Ajuste Saída':
        return Icons.tune;
      default:
        return Icons.analytics_outlined;
    }
  }
}
