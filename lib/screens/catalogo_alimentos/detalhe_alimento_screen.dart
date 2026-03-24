// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './widgets/secao_detalhe.dart';
import '../../models/alimento_catalogo_model.dart';

class DetalheAlimentoScreen extends StatelessWidget {
  final AlimentoCatalogo item;

  const DetalheAlimentoScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final muted = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.65);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.nome),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SecaoDetalhe(
              titulo: 'Quando está bom',
              cor: brand,
              itens: item.sinaisBom,
            ),
            const SizedBox(height: 14),
            SecaoDetalhe(
              titulo: 'Sinais de alerta',
              cor: Colors.orange,
              itens: item.sinaisAlerta,
            ),
            const SizedBox(height: 14),
            SecaoDetalhe(
              titulo: 'Sinais de deterioração',
              cor: Colors.red,
              itens: item.sinaisRuim,
            ),
            const SizedBox(height: 14),
            SecaoDetalhe(
              titulo: 'Cheiro',
              cor: brand,
              itens: item.cheiro,
            ),
            const SizedBox(height: 14),
            SecaoDetalhe(
              titulo: 'Textura',
              cor: brand,
              itens: item.textura,
            ),
            const SizedBox(height: 14),
            SecaoDetalhe(
              titulo: 'Cor',
              cor: brand,
              itens: item.cor,
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Importante: este catálogo serve como apoio visual. Sempre que houver dúvida, evite o consumo do alimento.',
                style: TextStyle(
                  color: muted,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
