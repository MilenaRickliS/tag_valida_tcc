 // ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

 Widget buildMensagemAnalise({
    required Color card,
    required Color border,
    required Color text,
    required Color muted,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFED7227).withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFED7227),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mensagem da análise',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message.isNotEmpty
                      ? message
                      : 'A análise foi finalizada com sucesso.',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }