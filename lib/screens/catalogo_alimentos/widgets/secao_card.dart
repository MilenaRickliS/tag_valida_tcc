// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SecaoCard extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color cor;
  final Color fundoIcone;
  final Color cardColor;
  final Color borderColor;
  final Widget child;

  const SecaoCard({super.key, 
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.fundoIcone,
    required this.cardColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: fundoIcone,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}