// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'badge_chip.dart';
import 'status_chip.dart';

class EtiquetaDetailsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;

  final String tipoNome;
  final String produtoNome;
  final String statusLabel;
  final Color statusColor;

  final String validadeLabel;
  final String validadeHint;
  final Color validadeColor;

  final String categoriaNome;
  final String setorNome;
  final String fabricacaoFormatada;
  final String validadeFormatada;

  final bool hasLote;
  final String loteLabel;
  final String? loteFormatado;
  final String? lotePrefixo;

  final String quantidade;
  final String saidas;
  final String restante;

  final Map<String, dynamic> customSemLote;
  final String Function(int ms) formatCustomDate;

  const EtiquetaDetailsCard({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.tipoNome,
    required this.produtoNome,
    required this.statusLabel,
    required this.statusColor,
    required this.validadeLabel,
    required this.validadeHint,
    required this.validadeColor,
    required this.categoriaNome,
    required this.setorNome,
    required this.fabricacaoFormatada,
    required this.validadeFormatada,
    required this.hasLote,
    required this.loteLabel,
    required this.loteFormatado,
    required this.lotePrefixo,
    required this.quantidade,
    required this.saidas,
    required this.restante,
    required this.customSemLote,
    required this.formatCustomDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipoNome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      produtoNome,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    label: statusLabel,
                    color: statusColor,
                  ),
                  const SizedBox(height: 8),
                  BadgeChip(
                    label: validadeLabel,
                    subtitle: validadeHint,
                    color: validadeColor,
                    icon: Icons.event_outlined,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.black.withOpacity(0.06), height: 1),
          const SizedBox(height: 14),

          _linha("Categoria", categoriaNome),
          _linha("Setor/Responsável", setorNome),
          _linha("Fabricação", fabricacaoFormatada),
          _linhaColor("Validade", validadeFormatada, validadeColor),

          if (hasLote) ...[
            _linha(loteLabel, loteFormatado ?? "-"),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 18,
                    color: Colors.black.withOpacity(0.55),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$loteLabel: ",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lotePrefixo ?? "-",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _metric("Quantidade", quantidade)),
              const SizedBox(width: 10),
              Expanded(child: _metric("Saídas", saidas)),
              const SizedBox(width: 10),
              Expanded(child: _metric("Restante", restante)),
            ],
          ),

          if (customSemLote.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.black.withOpacity(0.06), height: 1),
            const SizedBox(height: 12),
            Text(
              "Campos adicionais",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            ...customSemLote.entries.map((entry) {
              final obj = Map<String, dynamic>.from(entry.value as Map);
              final label = (obj["label"] ?? entry.key).toString();
              final val = obj["value"];

              String texto;
              if (val is int) {
                texto = formatCustomDate(val);
              } else if (val is bool) {
                texto = val ? "Sim" : "Não";
              } else {
                texto = val?.toString() ?? "";
              }

              return _linha(label, texto);
            }),
          ],
        ],
      ),
    );
  }

  Widget _linha(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaColor(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : const Color(0xFFFAF7F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}