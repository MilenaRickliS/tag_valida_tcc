// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'resumo_linha.dart';

class ResumoCard extends StatelessWidget {
  final String modelo;
  final String tipoConexao;
  final String ip;
  final String porta;
  final String tamanhoEtiqueta;
  final bool ativo;
  final Color statusColor;
  final Color green;
  final Color red;

  const ResumoCard({
    super.key,
    required this.modelo,
    required this.tipoConexao,
    required this.ip,
    required this.porta,
    required this.tamanhoEtiqueta,
    required this.ativo,
    required this.statusColor,
    required this.green,
    required this.red,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _cardAlt(BuildContext context) =>
      _isDark(context) ? const Color(0xFF181818) : const Color(0xFFFFFBF5);

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) => _isDark(context)
      ? const Color(0xFFD6D6D6)
      : Colors.black.withOpacity(0.60);

  Color _border(BuildContext context) => _isDark(context)
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.07);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark(context) ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.router_rounded, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Resumo rápido",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _text(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResumoLinha(
            label: "Modelo",
            value: modelo.trim().isEmpty ? "-" : modelo.trim(),
          ),
          ResumoLinha(
            label: "Conexão",
            value: tipoConexao == 'network' ? 'Rede' : tipoConexao,
          ),
          ResumoLinha(
            label: "IP",
            value: ip.trim().isEmpty ? "-" : ip.trim(),
          ),
          ResumoLinha(
            label: "Porta",
            value: porta.trim().isEmpty ? "-" : porta.trim(),
          ),
          ResumoLinha(
            label: "Etiqueta",
            value: tamanhoEtiqueta,
          ),
          ResumoLinha(
            label: "Status",
            value: ativo ? 'Ativa' : 'Inativa',
            valueColor: ativo ? green : red,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cardAlt(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dicas",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _text(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "• Conecte a Elgin L42 Pro e o tablet na mesma rede.\n"
                  "• A porta padrão normalmente é 9100.\n"
                  "• Use “Testar conexão” antes de salvar.\n"
                  "• Use “Imprimir etiqueta teste” para validar a impressão real.",
                  style: TextStyle(
                    color: _muted(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}