// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import './widgets/secao_detalhe.dart';
import '../../models/alimento_catalogo_model.dart';
import './widgets/header_alimento.dart';
import './widgets/secao_card.dart';

class DetalheAlimentoScreen extends StatelessWidget {
  final AlimentoCatalogo item;

  const DetalheAlimentoScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final brandSoft = brand.withOpacity(0.12);
    final warning = Colors.orange;
    final warningSoft = Colors.orange.withOpacity(0.12);
    final danger = const Color(0xFFD64545);
    final dangerSoft = danger.withOpacity(0.12);

    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFFDF7ED);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final textSecondary = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.65);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          item.nome,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderAlimento(
              item: item,
              isDark: isDark,
              brand: brand,
              brandSoft: brandSoft,
              card: card,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 18),

            SecaoCard(
              titulo: 'Quando está bom',
              icone: Icons.check_circle_rounded,
              cor: brand,
              fundoIcone: brandSoft,
              cardColor: card,
              borderColor: border,
              child: SecaoDetalhe(
                titulo: 'Quando está bom',
                cor: brand,
                itens: item.sinaisBom,
              ),
            ),
            const SizedBox(height: 14),

            SecaoCard(
              titulo: 'Sinais de alerta',
              icone: Icons.warning_amber_rounded,
              cor: warning,
              fundoIcone: warningSoft,
              cardColor: card,
              borderColor: border,
              child: SecaoDetalhe(
                titulo: 'Sinais de alerta',
                cor: warning,
                itens: item.sinaisAlerta,
              ),
            ),
            const SizedBox(height: 14),

            SecaoCard(
              titulo: 'Sinais de deterioração',
              icone: Icons.dangerous_rounded,
              cor: danger,
              fundoIcone: dangerSoft,
              cardColor: card,
              borderColor: border,
              child: SecaoDetalhe(
                titulo: 'Sinais de deterioração',
                cor: danger,
                itens: item.sinaisRuim,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SecaoCard(
                    titulo: 'Cheiro',
                    icone: Icons.air_rounded,
                    cor: brand,
                    fundoIcone: brandSoft,
                    cardColor: card,
                    borderColor: border,
                    child: SecaoDetalhe(
                      titulo: 'Cheiro',
                      cor: brand,
                      itens: item.cheiro,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SecaoCard(
                    titulo: 'Textura',
                    icone: Icons.pan_tool_alt_rounded,
                    cor: brand,
                    fundoIcone: brandSoft,
                    cardColor: card,
                    borderColor: border,
                    child: SecaoDetalhe(
                      titulo: 'Textura',
                      cor: brand,
                      itens: item.textura,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SecaoCard(
                    titulo: 'Cor',
                    icone: Icons.palette_rounded,
                    cor: brand,
                    fundoIcone: brandSoft,
                    cardColor: card,
                    borderColor: border,
                    child: SecaoDetalhe(
                      titulo: 'Cor',
                      cor: brand,
                      itens: item.cor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.20 : 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: warningSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Importante: este catálogo serve como apoio visual. Sempre que houver dúvida, cheiro muito forte, mofo, alteração incomum ou aparência suspeita, evite o consumo do alimento.',
                      style: TextStyle(
                        color: textSecondary,
                        height: 1.6,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}


