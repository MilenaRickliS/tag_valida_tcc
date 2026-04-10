// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/etiqueta_model.dart';
import '../../models/tabela_nutricional_model.dart';
import '../../models/user_model.dart';
import '../../providers/theme_provider.dart';
import '../etiqueta_preview/widgets/etiqueta_details_card.dart';
import '../etiqueta_preview/widgets/etiqueta_qr_card.dart';
import '../../utils/formatar_lote.dart';
import './widgets/qr_fullscreen.dart';

class EtiquetaPublicaScreen extends StatelessWidget {
  final String uid;
  final String etiquetaId;

  const EtiquetaPublicaScreen({
    super.key,
    required this.uid,
    required this.etiquetaId,
  });

  static const _lightCard = Colors.white;
  static const _lightText = Color(0xFF2B2B2B);
  static const _lightMuted = Color(0xFF6B6B6B);
  static const _darkCard = Color(0xFF1E1E1E);
  static const _darkText = Colors.white;
  static const _darkMuted = Color(0xFFD6D6D6);
  static const _gold = Color(0xFFD4AF37);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) => _isDark(context) ? _darkCard : _lightCard;
  Color _text(BuildContext context) => _isDark(context) ? _darkText : _lightText;
  Color _muted(BuildContext context) => _isDark(context) ? _darkMuted : _lightMuted;
  Color _border(BuildContext context) => _isDark(context)
      ? _gold.withOpacity(0.16)
      : Colors.black.withOpacity(0.06);

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _daysToExpire(DateTime validade) {
    final today = _dateOnly(DateTime.now());
    final exp = _dateOnly(validade);
    return exp.difference(today).inDays;
  }

  String _validadeLabel(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Vencida";
    if (days <= 2) return "Em alerta";
    return "Boa";
  }

  Color _validadeColor(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return Colors.red;
    if (days <= 2) return Colors.orange;
    return Colors.green;
  }

  String _validadeHint(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Venceu há ${days.abs()} dia(s)";
    if (days == 0) return "Vence hoje";
    return "Faltam $days dia(s)";
  }

  String _fmtNum(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(".", ",");
  }

  String _fmtDate(DateTime d) => DateFormat("dd/MM/yyyy").format(d);

  Color _statusColor(String s) {
    switch (s) {
      case "cancelado":
        return Colors.red;
      case "vendido":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case "cancelado":
        return "Cancelado";
      case "vendido":
        return "Vendido";
      default:
        return "Ativo";
    }
  }

  EtiquetaModel _etiquetaFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    DateTime dt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      return DateTime.now();
    }

    bool toBool(dynamic v, {bool defaultValue = false}) {
      if (v == null) return defaultValue;
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is num) return v.toInt() == 1;
      final s = v.toString().trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
      return defaultValue;
    }

    final tabelaMap = data["tabelaNutricional"];
    final tabelaNutricional = (tabelaMap is Map)
        ? TabelaNutricionalModel.fromMap(
            Map<String, dynamic>.from(tabelaMap),
          )
        : null;

    return EtiquetaModel(
      id: doc.id,
      tipoId: (data["tipoId"] ?? "").toString(),
      tipoNome: (data["tipoNome"] ?? "").toString(),
      produtoNome: (data["produtoNome"] ?? "").toString(),
      categoriaId: (data["categoriaId"] ?? "").toString(),
      categoriaNome: (data["categoriaNome"] ?? "").toString(),
      setorId: (data["setorId"] ?? "").toString(),
      setorNome: (data["setorNome"] ?? "").toString(),
      dataFabricacao: dt(data["dataFabricacao"]),
      dataValidade: dt(data["dataValidade"]),
      camposCustomValores: Map<String, dynamic>.from(
        data["camposCustomValores"] ?? {},
      ),
      status: (data["status"] ?? "").toString(),
      lote: data["lote"]?.toString(),
      quantidade: (data["quantidade"] ?? 0) as num,
      quantidadeRestante: (data["quantidadeRestante"] ?? 0) as num,
      statusEstoque: (data["statusEstoque"] ?? "").toString(),
      soldAt: data["soldAt"] == null ? null : dt(data["soldAt"]),
      createdAt: data["createdAt"] == null ? null : dt(data["createdAt"]),
      incluirTabelaNutricional: toBool(data["incluirTabelaNutricional"]),
      tabelaNutricional: tabelaNutricional,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final cardColor = _card(context);
    final borderColor = _border(context);
    final textColor = _text(context);
    final bgColor =
        isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFDF7ED);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? _gold : Colors.black87),
        title: Text(
          "Etiqueta",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: isDark ? "Modo claro" : "Modo escuro",
              icon: Icon(
                isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: isDark ? _gold : Colors.black87,
              ),
              onPressed: () {
                final brightness = Theme.of(context).brightness;

                final newTheme = brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;

                context.read<ThemeProvider>().setTheme(newTheme);
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .collection('etiquetas')
              .doc(etiquetaId)
              .get(),
          FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
        ]),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? _gold : const Color(0xFFED7227),
              ),
            );
          }

          if (!snap.hasData) {
            return Center(
              child: Text(
                "Erro ao carregar etiqueta.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          final etiquetaDoc = snap.data![0] as DocumentSnapshot<Map<String, dynamic>>;
          final userDoc = snap.data![1] as DocumentSnapshot<Map<String, dynamic>>;

          if (!etiquetaDoc.exists || etiquetaDoc.data() == null) {
            return Center(
              child: Text(
                "Etiqueta não encontrada.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          if (!userDoc.exists || userDoc.data() == null) {
            return Center(
              child: Text(
                "Usuário não encontrado.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          final etiqueta = _etiquetaFromDoc(etiquetaDoc);
          final usuario = UserModel.fromMap(userDoc.data()!);

          final produtoNome = etiqueta.produtoNome;
          final categoriaNome = etiqueta.categoriaNome;
          final setorNome = etiqueta.setorNome;
          final tipoNome = etiqueta.tipoNome;
          final fabricacao = etiqueta.dataFabricacao;
          final validade = etiqueta.dataValidade;
          final qtd = etiqueta.quantidade;
          final rest = etiqueta.quantidadeRestante;
          final status = etiqueta.statusEstoque.trim().isEmpty
              ? "ativo"
              : etiqueta.statusEstoque.trim();

          final num saidas =
              status == "cancelado" ? qtd : ((qtd - rest) < 0 ? 0 : (qtd - rest));
          final num restanteView = status == "cancelado" ? 0 : rest;

          final custom = Map<String, dynamic>.from(etiqueta.camposCustomValores);

          String? loteValue;
          String loteLabel = "Lote";

          final loteRaw = custom["lote"];
          if (loteRaw is Map) {
            final m = Map<String, dynamic>.from(loteRaw);
            loteLabel = (m["label"] ?? "Lote").toString();
            final v = m["value"];
            final s = v?.toString().trim();
            if (s != null && s.isNotEmpty) loteValue = s;
          }

          final customSemLote = Map<String, dynamic>.from(custom)..remove("lote");

          final hasLote = loteValue != null && loteValue.trim().isNotEmpty;

          final loteFormatado = hasLote
              ? formatarLote(loteValue.trim(), formato: LoteFormato.dataHora)
              : null;

          final lotePrefixo = hasLote
              ? formatarLote(loteValue.trim(), formato: LoteFormato.prefixoL)
              : null;

          // final qrPublico = 'https://seudominio.com/e/$etiquetaId';
          final qrPublico = 'PUBLICO:$uid:$etiquetaId';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.public,
                            color: isDark ? _gold : const Color(0xFF428E2E),
                            size: 28,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Consulta pública da etiqueta",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            usuario.razao.trim().isNotEmpty
                                ? usuario.razao.trim()
                                : usuario.nome.trim(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _muted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    EtiquetaDetailsCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      mutedColor: _muted(context),
                      tipoNome: tipoNome,
                      produtoNome: produtoNome,
                      statusLabel: _statusLabel(status),
                      statusColor: _statusColor(status),
                      validadeLabel: _validadeLabel(validade),
                      validadeHint: _validadeHint(validade),
                      validadeColor: _validadeColor(validade),
                      categoriaNome: categoriaNome,
                      setorNome: setorNome,
                      fabricacaoFormatada: _fmtDate(fabricacao),
                      validadeFormatada: _fmtDate(validade),
                      hasLote: hasLote,
                      loteLabel: loteLabel,
                      loteFormatado: loteFormatado,
                      lotePrefixo: lotePrefixo,
                      quantidade: _fmtNum(qtd),
                      saidas: _fmtNum(saidas),
                      restante: _fmtNum(restanteView),
                      customSemLote: customSemLote,
                      incluirTabelaNutricional: etiqueta.incluirTabelaNutricional,
                      tabelaNutricional: etiqueta.tabelaNutricional,
                      formatCustomDate: (ms) =>
                          _fmtDate(DateTime.fromMillisecondsSinceEpoch(ms)),
                    ),
                    const SizedBox(height: 14),
                    EtiquetaQrCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      qrData: qrPublico,
                      onTapQr: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QrFullscreenScreen(
                              data: qrPublico,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Página pública informativa. Impressão e edição não estão disponíveis aqui.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _muted(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}