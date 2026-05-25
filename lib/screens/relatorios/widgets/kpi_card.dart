// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color fg;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 170;

        return Container(
          padding: EdgeInsets.all(isSmall ? 12 : 14),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isSmall ? 32 : 36,
                height: isSmall ? 32 : 36,
                decoration: BoxDecoration(
                  color: fg.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(label),
                  color: fg,
                  size: isSmall ? 16 : 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 13,
                        color: fg.withOpacity(0.95),
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 18 : 20,
                        fontWeight: FontWeight.w900,
                        color: fg,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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