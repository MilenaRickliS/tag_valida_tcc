// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DesignEtiquetaScreen extends StatefulWidget {
  const DesignEtiquetaScreen({super.key});

  @override
  State<DesignEtiquetaScreen> createState() => _DesignEtiquetaScreenState();
}

class _DesignEtiquetaScreenState extends State<DesignEtiquetaScreen> {
  static const _lightBg = Color(0xFFFDF7ED);
  static const _lightText = Color(0xFF2B2B2B);
  static const _orange = Color(0xFFED7227);
  static const _green = Color(0xFF88BE8E);

  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkCard = Color(0xFF1E1E1E);
  static const _darkText = Colors.white;
  static const _gold = Color(0xFFD4AF37);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final bg = isDark ? _darkBg : _lightBg;
    final card = isDark ? _darkCard : Colors.white;
    final text = isDark ? _darkText : _lightText;
    final border = isDark
        ? _gold.withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return Container(
      color: bg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design da etiqueta',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aqui você pode organizar a aparência visual da etiqueta, pré-visualização, estilo, logo e disposição das informações.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: text.withOpacity(0.72),
                        ),
                      ),
                      const SizedBox(height: 22),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _optionCard(
                            title: 'Modelo',
                            subtitle: 'Compacta 60x40',
                            icon: Icons.local_offer_outlined,
                            color: _orange,
                            isDark: isDark,
                          ),
                          _optionCard(
                            title: 'Logo',
                            subtitle: 'TagValida',
                            icon: Icons.image_outlined,
                            color: _green,
                            isDark: isDark,
                          ),
                          _optionCard(
                            title: 'Cor principal',
                            subtitle: 'Laranja da marca',
                            icon: Icons.palette_outlined,
                            color: _orange,
                            isDark: isDark,
                          ),
                          _optionCard(
                            title: 'QR Code',
                            subtitle: 'Ativado',
                            icon: Icons.qr_code_2_outlined,
                            color: _green,
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Pré-visualização',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Center(
                        child: Container(
                          width: 500,
                          height: 330,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF181818)
                                : const Color(0xFFFFFCF8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [_orange, _green],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.local_offer_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'TagValida',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF222222)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pão Francês',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: text,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _previewLine('Validade', '25/03/2026', text),
                                      _previewLine('Lote', 'L202603250830', text),
                                      _previewLine('Qtd', '32', text),
                                      const Spacer(),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.black.withOpacity(0.08),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_2,
                                            size: 56,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? _gold.withOpacity(0.12)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : _lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: (isDark ? Colors.white : _lightText).withOpacity(0.68),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewLine(String label, String value, Color text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: text,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}