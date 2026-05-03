// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'badge_chip.dart';
import 'status_chip.dart';
import 'tabela_nutricional_preview_card.dart';
import 'rotulagem_frontal_card.dart';
import './tabela_nutricional_pdf_service.dart';
import '../../../models/tabela_nutricional_model.dart';


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

  final bool incluirTabelaNutricional;
  final TabelaNutricionalModel? tabelaNutricional;
  final VoidCallback onOuvirEtiqueta;

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
    required this.incluirTabelaNutricional,
    required this.tabelaNutricional,
    required this.onOuvirEtiqueta,
  });

  String _formatNum(dynamic val, {int casasDecimais = 2}) {
    if (val == null) return "";

    num? n;
    if (val is num) {
      n = val;
    } else {
      n = num.tryParse(val.toString().replaceAll(",", "."));
    }

    if (n == null) return val.toString();

    if (casasDecimais <= 0) {
      return n.toInt().toString();
    }

    return n.toStringAsFixed(casasDecimais).replaceAll(".", ",");
  }

  String _formatCustomValue({
    required String tipo,
    required dynamic val,
    required String? prefixo,
    required String? sufixo,
    required int casasDecimais,
  }) {
    switch (tipo) {
      case "date":
        if (val is int) return formatCustomDate(val);
        return val?.toString() ?? "";

      case "bool":
      case "boolType":
        if (val is bool) return val ? "Sim" : "Não";
        final s = (val ?? "").toString().toLowerCase().trim();
        const verdadeiros = ["true", "1", "sim", "yes"];
        const falsos = ["false", "0", "não", "nao", "no"];
        if (verdadeiros.contains(s)) return "Sim";
        if (falsos.contains(s)) return "Não";
        return "Não";

      case "integer":
        final base = _formatNum(val, casasDecimais: 0);
        return "${prefixo ?? ""}$base${sufixo ?? ""}".trim();

      case "decimal":
        final base = _formatNum(val, casasDecimais: casasDecimais);
        return "${prefixo ?? ""}$base${sufixo ?? ""}".trim();

      case "currency":
        final base = _formatNum(val, casasDecimais: casasDecimais);
        return "${prefixo ?? ""}$base${sufixo ?? ""}".trim();

      case "priceMode":
        if (val is Map) {
          final map = Map<String, dynamic>.from(val);
          final valor = _formatNum(
            map["valor"],
            casasDecimais: casasDecimais,
          );
          final modo = (map["modo"] ?? "").toString().trim();
          final base = "${prefixo ?? ""}$valor${sufixo ?? ""}".trim();
          return modo.isEmpty ? base : "$base/$modo";
        }
        return "${prefixo ?? ""}${val?.toString() ?? ""}${sufixo ?? ""}".trim();

      case "number":
        
        final base = _formatNum(val, casasDecimais: casasDecimais);
        return "${prefixo ?? ""}$base${sufixo ?? ""}".trim();

      default:
        return val?.toString() ?? "";
    }
  }

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
                    if (tipoNome.isNotEmpty)
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
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.black.withOpacity(0.06), height: 1),
          const SizedBox(height: 14),
          if (categoriaNome.isNotEmpty)
            _linha("Categoria", categoriaNome),
          if (setorNome.isNotEmpty)
            _linha("Setor/Responsável", setorNome),
          _linha("Fabricação", fabricacaoFormatada),
          _linhaColor("Validade", validadeFormatada, validadeColor),

          const SizedBox(height: 17),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                button: true,
                label: 'Ouvir detalhes da etiqueta',
                child: GestureDetector(
                  onTap: onOuvirEtiqueta,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: validadeColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: validadeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: validadeColor.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: validadeColor.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up_rounded,
                            color: validadeColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ouvir detalhes da etiqueta',
                            style: TextStyle(
                              color: validadeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Toque no botão para ouvir os alertas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          if (hasLote) ...[
            
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
                      loteFormatado ?? lotePrefixo ?? "-",
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

          if (quantidade.isNotEmpty)
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
                final tipo = (obj["tipo"] ?? "text").toString();
                final prefixo = obj["prefixo"]?.toString();
                final sufixo = obj["sufixo"]?.toString();
                final casasDecimais = (obj["casasDecimais"] as num?)?.toInt() ?? 2;

                if (_isImageValue(val)) {
                  return _linhaImagem(label, val.toString());
                }

                final texto = _formatCustomValue(
                  tipo: tipo,
                  val: val,
                  prefixo: prefixo,
                  sufixo: sufixo,
                  casasDecimais: casasDecimais,
                );

                return _linha(label, texto);
              }),
          ],
          if (incluirTabelaNutricional && tabelaNutricional != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tabela nutricional',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visualização conforme padrão de rotulagem',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TabelaNutricionalPreviewCard(
                    tabela: tabelaNutricional!,
                  ),

                  const SizedBox(height: 6),

                  RotulagemFrontalImagem(
                    tabela: tabelaNutricional!,
                  ),

                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        'Exportação',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff88be8e),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => _EscolherLayoutTabelaPdfSheet(
                              tabela: tabelaNutricional!,
                              produtoNome: produtoNome,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.download_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Gerar PDF da tabela nutricional',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Baixe a tabela no padrão exigido pela ANVISA',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isImageValue(dynamic value) {
    if (value == null) return false;

    final s = value.toString().trim().toLowerCase();
    if (s.isEmpty) return false;

    final isHttp = s.startsWith('http://') || s.startsWith('https://');
    final looksLikeImage = s.contains('.jpg') ||
        s.contains('.jpeg') ||
        s.contains('.png') ||
        s.contains('.webp') ||
        s.contains('firebasestorage') ||
        s.contains('storage.googleapis.com') ||
        s.contains('alt=media');

    return isHttp && looksLikeImage;
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

  Widget _linhaImagem(String label, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181818) : const Color(0xFFFAF7F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Não foi possível carregar a imagem.",
                        style: TextStyle(
                          color: mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
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

class _EscolherLayoutTabelaPdfSheet extends StatelessWidget {
  final TabelaNutricionalModel tabela;
  final String produtoNome;

  const _EscolherLayoutTabelaPdfSheet({
    required this.tabela,
    required this.produtoNome,
  });

  Future<void> _gerar(
    BuildContext context,
    LayoutTabelaNutricionalPdf layout,
  ) async {
    Navigator.pop(context);

    final service = TabelaNutricionalPdfService();

    try {
      final file = await service.gerarPdf(
        tabela: tabela,
        layout: layout,
        produtoNome: produtoNome,
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolha o layout do PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.view_agenda_outlined),
              title: const Text('Modelo vertical'),
              onTap: () => _gerar(context, LayoutTabelaNutricionalPdf.vertical),
            ),
            ListTile(
              leading: const Icon(Icons.table_rows_outlined),
              title: const Text('Modelo horizontal'),
              onTap: () => _gerar(context, LayoutTabelaNutricionalPdf.horizontal),
            ),
            ListTile(
              leading: const Icon(Icons.view_column_outlined),
              title: const Text('Modelo vertical quebrado'),
              onTap: () => _gerar(context, LayoutTabelaNutricionalPdf.verticalQuebrado),
            ),
            ListTile(
              leading: const Icon(Icons.splitscreen_outlined),
              title: const Text('Modelo horizontal quebrado'),
              onTap: () => _gerar(context, LayoutTabelaNutricionalPdf.horizontalQuebrado),
            ),
          ],
        ),
      ),
    );
  }
}