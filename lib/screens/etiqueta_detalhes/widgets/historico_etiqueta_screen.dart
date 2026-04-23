// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/estoque_mov_provider.dart';
import '../../../models/estoque_mov_model.dart';

class HistoricoEtiquetaScreen extends StatelessWidget {
  final String uid;
  final String etiquetaId;
  final String produtoNome;

  const HistoricoEtiquetaScreen({
    super.key,
    required this.uid,
    required this.etiquetaId,
    required this.produtoNome,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<EstoqueMovProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : const Color(0xFF6B6B6B);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.07);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Histórico da etiqueta"),
      ),
      body: FutureBuilder<List<EstoqueMovModel>>(
        future: repo.listByEtiqueta(uid: uid, etiquetaId: etiquetaId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
              debugPrint('ERRO histórico etiqueta: ${snap.error}');
              return Center(
                child: Text(
                  "Erro ao carregar histórico: ${snap.error}",
                  style: TextStyle(color: text),
                  textAlign: TextAlign.center,
                ),
              );
            }

          final itens = snap.data ?? [];

          if (itens.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 38,
                      color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Nenhuma movimentação registrada",
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      produtoNome,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produtoNome,
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${itens.length} registro(s) no histórico",
                      style: TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...itens.map(
                (mov) => _TimelineCard(
                  mov: mov,
                  isDark: isDark,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final EstoqueMovModel mov;
  final bool isDark;

  const _TimelineCard({
    required this.mov,
    required this.isDark,
  });

  Color get _text => isDark ? Colors.white : const Color(0xFF2B2B2B);
  Color get _muted => isDark ? const Color(0xFFD6D6D6) : const Color(0xFF6B6B6B);
  Color get _card => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _border => isDark
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.07);

  Color _acaoColor(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoVenda:
        return Colors.orange;
      case EstoqueMovModel.tipoUso:
        return Colors.blue;
      case EstoqueMovModel.tipoDescarte:
        return Colors.red;
      case EstoqueMovModel.tipoCancelamento:
        return Colors.red;
      case EstoqueMovModel.tipoAjusteEntrada:
        return Colors.green;
      case EstoqueMovModel.tipoAjusteSaida:
        return Colors.deepOrange;
      case EstoqueMovModel.tipoEntrada:
        return Colors.green;
      case EstoqueMovModel.tipoExclusao:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _acaoIcon(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoVenda:
        return Icons.point_of_sale_rounded;
      case EstoqueMovModel.tipoUso:
        return Icons.build_circle_outlined;
      case EstoqueMovModel.tipoDescarte:
        return Icons.delete_outline_rounded;
      case EstoqueMovModel.tipoCancelamento:
        return Icons.cancel_outlined;
      case EstoqueMovModel.tipoAjusteEntrada:
        return Icons.add_circle_outline_rounded;
      case EstoqueMovModel.tipoAjusteSaida:
        return Icons.remove_circle_outline_rounded;
      case EstoqueMovModel.tipoEntrada:
        return Icons.inventory_2_outlined;
      case EstoqueMovModel.tipoExclusao:
        return Icons.delete_forever_outlined;
      default:
        return Icons.history_rounded;
    }
  }

  String _acaoLabel(String tipo) {
    switch (tipo) {
      case EstoqueMovModel.tipoVenda:
        return "Venda";
      case EstoqueMovModel.tipoUso:
        return "Uso interno";
      case EstoqueMovModel.tipoDescarte:
        return "Descarte";
      case EstoqueMovModel.tipoCancelamento:
        return "Cancelamento";
      case EstoqueMovModel.tipoAjusteEntrada:
        return "Ajuste de entrada";
      case EstoqueMovModel.tipoAjusteSaida:
        return "Ajuste de saída";
      case EstoqueMovModel.tipoEntrada:
        return "Entrada";
      case EstoqueMovModel.tipoExclusao:
        return "Exclusão";
      default:
        return tipo;
    }
  }

  String _fmtDateTime(DateTime d) {
    return DateFormat("dd/MM/yyyy • HH:mm").format(d);
  }

  @override
  Widget build(BuildContext context) {
    final color = _acaoColor(mov.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _acaoIcon(mov.tipo),
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _acaoLabel(mov.tipo),
                        style: TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        mov.quantidade.toString(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _fmtDateTime(mov.createdAt),
                  style: TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                if ((mov.motivo ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Motivo: ${mov.motivo!.trim()}",
                    style: TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}