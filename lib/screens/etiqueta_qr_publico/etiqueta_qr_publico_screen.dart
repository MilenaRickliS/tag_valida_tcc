// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/etiqueta_model.dart';
import '../../models/tabela_nutricional_model.dart';
import '../../models/user_model.dart';
import '../../providers/theme_provider.dart';
import '../../utils/formatar_lote.dart';
import '../etiqueta_detalhes/widgets/etiqueta_details_card.dart';
import '../etiqueta_detalhes/widgets/etiqueta_qr_card.dart';
import './widgets/qr_fullscreen.dart';

class EtiquetaPublicaScreen extends StatelessWidget {
  final String uid;
  final String etiquetaId;

  const EtiquetaPublicaScreen({
    super.key,
    required this.uid,
    required this.etiquetaId,
  });

  static const _lightBg = Color(0xFFFDF7ED);
  static const _lightCard = Colors.white;
  static const _lightText = Color(0xFF2B2B2B);
  static const _lightMuted = Color(0xFF6B6B6B);

  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkCard = Color(0xFF1E1E1E);
  static const _darkText = Colors.white;
  static const _darkMuted = Color(0xFFD6D6D6);

  static const _gold = Color(0xFFD4AF37);
  static const _accent = Color(0xFFED7227);
  static const _success = Color(0xFF428E2E);
  static const _warning = Color(0xFFF29F05);
  static const _danger = Color(0xFFD64545);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) => _isDark(context) ? _darkCard : _lightCard;
  Color _text(BuildContext context) => _isDark(context) ? _darkText : _lightText;
  Color _muted(BuildContext context) =>
      _isDark(context) ? _darkMuted : _lightMuted;

  Color _border(BuildContext context) => _isDark(context)
      ? _gold.withOpacity(0.16)
      : Colors.black.withOpacity(0.06);

  Color _bg(BuildContext context) => _isDark(context) ? _darkBg : _lightBg;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _daysToExpire(DateTime validade) {
    final today = _dateOnly(DateTime.now());
    final exp = _dateOnly(validade);
    return exp.difference(today).inDays;
  }

  String _validadeLabel(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Produto vencido";
    if (days <= 2) return "Produto em alerta";
    return "Produto em boa condição";
  }

  String _validadeShortLabel(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Vencido";
    if (days <= 2) return "Em alerta";
    return "Boa condição";
  }

  Color _validadeColor(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return _danger;
    if (days <= 2) return _warning;
    return _success;
  }

  IconData _validadeIcon(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return Icons.cancel_rounded;
    if (days <= 2) return Icons.warning_amber_rounded;
    return Icons.verified_rounded;
  }

  String _validadeHint(DateTime validade) {
    final days = _daysToExpire(validade);
    if (days < 0) return "Venceu há ${days.abs()} dia(s).";
    if (days == 0) return "Vence hoje.";
    if (days == 1) return "Vence em 1 dia.";
    return "Faltam $days dias para o vencimento.";
  }


  String _fmtDate(DateTime d) => DateFormat("dd/MM/yyyy").format(d);

  Color _statusColor(String s) {
    switch (s) {
      case "cancelado":
        return _danger;
      case "vendido":
        return _warning;
      default:
        return _success;
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

  Widget _buildTopHero({
    required BuildContext context,
    required UserModel usuario,
  }) {
    final isDark = _isDark(context);
    final textColor = _text(context);
    final mutedColor = _muted(context);
    final borderColor = _border(context);
    final cardColor = _card(context);

    final empresa = usuario.razao.trim().isNotEmpty
        ? usuario.razao.trim()
        : usuario.nome.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        _gold.withOpacity(0.26),
                        _gold.withOpacity(0.10),
                      ]
                    : [
                        _accent.withOpacity(0.18),
                        _success.withOpacity(0.10),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isDark
                    ? _gold.withOpacity(0.26)
                    : _accent.withOpacity(0.16),
              ),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 30,
              color: isDark ? _gold : _accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Consulta pública da etiqueta",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            empresa,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? _gold.withOpacity(0.10)
                  : _success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? _gold.withOpacity(0.16)
                    : _success.withOpacity(0.12),
              ),
            ),
            child: Text(
              "Informações visuais da etiqueta",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isDark ? _gold : _success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHero({
    required BuildContext context,
    required DateTime validade,
  }) {
    final color = _validadeColor(validade);
    final textColor = _text(context);
    final mutedColor = _muted(context);
    final isDark = _isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.18 : 0.12),
            color.withOpacity(isDark ? 0.08 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Icon(
              _validadeIcon(validade),
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _validadeLabel(validade),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _validadeHint(validade),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(BuildContext context) {
    final textColor = _text(context);
    final mutedColor = _muted(context);
    final borderColor = _border(context);
    final cardColor = _card(context);
    final isDark = _isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? _gold.withOpacity(0.10)
                  : _accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: isDark ? _gold : _accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Consulta pública",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Esta página é apenas informativa. Edição, impressão e outras ações internas não estão disponíveis aqui.",
                  style: TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final cardColor = _card(context);
    final borderColor = _border(context);
    final textColor = _text(context);

    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? _gold : Colors.black87),
        title: Text(
          "Etiqueta pública",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
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
                color: isDark ? _gold : _accent,
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

          final etiquetaDoc =
              snap.data![0] as DocumentSnapshot<Map<String, dynamic>>;
          final userDoc =
              snap.data![1] as DocumentSnapshot<Map<String, dynamic>>;

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
          
          final fabricacao = etiqueta.dataFabricacao;
          final validade = etiqueta.dataValidade;
          final status = etiqueta.statusEstoque.trim().isEmpty
              ? "ativo"
              : etiqueta.statusEstoque.trim();


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

          final qrPublico = 'PUBLICO:$uid:$etiquetaId';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    _buildTopHero(
                      context: context,
                      usuario: usuario,
                    ),
                    const SizedBox(height: 16),
                    _buildStatusHero(
                      context: context,
                      validade: validade,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.16 : 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 14),
                         EtiquetaDetailsCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            mutedColor: _muted(context),
                            tipoNome: "",
                            produtoNome: produtoNome,
                            statusLabel: _statusLabel(status),
                            statusColor: _statusColor(status),
                            validadeLabel: _validadeShortLabel(validade),
                            validadeHint: _validadeHint(validade),
                            validadeColor: _validadeColor(validade),

                            categoriaNome: "",
                            setorNome: "",

                            fabricacaoFormatada: _fmtDate(fabricacao),
                            validadeFormatada: _fmtDate(validade),
                            hasLote: hasLote,
                            loteLabel: loteLabel,
                            loteFormatado: loteFormatado,
                            lotePrefixo: lotePrefixo,

                            quantidade: "",
                            saidas: "",
                            restante: "",

                            customSemLote: customSemLote,
                            incluirTabelaNutricional: etiqueta.incluirTabelaNutricional,
                            tabelaNutricional: etiqueta.tabelaNutricional,
                            formatCustomDate: (ms) =>
                                _fmtDate(DateTime.fromMillisecondsSinceEpoch(ms)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.16 : 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "QR Code da etiqueta",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Use este código para acessar esta mesma consulta pública.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w600,
                              color: _muted(context),
                              height: 1.3,
                            ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterInfo(context),
                     const SizedBox(height: 16),
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