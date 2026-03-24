// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ConfigCard extends StatelessWidget {
  final TextEditingController nomeCtrl;
  final TextEditingController modeloCtrl;
  final TextEditingController ipCtrl;
  final TextEditingController portaCtrl;

  final String tipoConexao;
  final String tamanhoEtiqueta;
  final bool ativo;
  final bool padrao;

  final void Function(String?) onTipoConexaoChanged;
  final void Function(String?) onTamanhoEtiquetaChanged;
  final void Function(bool) onAtivoChanged;
  final void Function(bool) onPadraoChanged;

  const ConfigCard({
    super.key,
    required this.nomeCtrl,
    required this.modeloCtrl,
    required this.ipCtrl,
    required this.portaCtrl,
    required this.tipoConexao,
    required this.tamanhoEtiqueta,
    required this.ativo,
    required this.padrao,
    required this.onTipoConexaoChanged,
    required this.onTamanhoEtiquetaChanged,
    required this.onAtivoChanged,
    required this.onPadraoChanged,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF2B2B2B);

  Color _muted(BuildContext context) => _isDark(context)
      ? const Color(0xFFD6D6D6)
      : Colors.black.withOpacity(0.60);

  Color _accent(BuildContext context) =>
      _isDark(context) ? const Color(0xFFD4AF37) : const Color(0xFFED7227);

  Color _border(BuildContext context) => _isDark(context)
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.07);

  Color _inputFill(BuildContext context) =>
      _isDark(context) ? const Color(0xFF181818) : const Color(0xFFFFFBF5);

  Color _iconColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFD4AF37) : Colors.black54;

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: _muted(context)),
      labelStyle: TextStyle(
        color: _muted(context),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: icon != null ? Icon(icon, color: _iconColor(context)) : null,
      filled: true,
      fillColor: _inputFill(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _accent(context), width: 1.4),
      ),
    );
  }

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
                  color: _accent(context).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.tune_rounded, color: _text(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Dados da impressora",
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
          TextFormField(
            controller: nomeCtrl,
            style: TextStyle(color: _text(context)),
            decoration: _inputDecoration(
              context,
              label: 'Nome da impressora',
              icon: Icons.drive_file_rename_outline,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: modeloCtrl,
            style: TextStyle(color: _text(context)),
            decoration: _inputDecoration(
              context,
              label: 'Modelo',
              icon: Icons.print_outlined,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o modelo' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: tipoConexao,
            dropdownColor: _card(context),
            style: TextStyle(color: _text(context)),
            decoration: _inputDecoration(
              context,
              label: 'Tipo de conexão',
              icon: Icons.settings_ethernet_rounded,
            ),
            items: const [
              DropdownMenuItem(
                value: 'network',
                child: Text('Rede'),
              ),
            ],
            onChanged: onTipoConexaoChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: TextFormField(
                  controller: ipCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _text(context)),
                  decoration: _inputDecoration(
                    context,
                    label: 'IP da impressora',
                    hint: 'Ex.: 192.168.0.120',
                    icon: Icons.language_rounded,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o IP' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: portaCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _text(context)),
                  decoration: _inputDecoration(
                    context,
                    label: 'Porta',
                    icon: Icons.numbers_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe a porta';
                    final p = int.tryParse(v.trim());
                    if (p == null || p <= 0) return 'Inválida';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: tamanhoEtiqueta,
            dropdownColor: _card(context),
            style: TextStyle(color: _text(context)),
            decoration: _inputDecoration(
              context,
              label: 'Tamanho da etiqueta',
              icon: Icons.straighten_rounded,
            ),
            items: const [
              DropdownMenuItem(
                value: '60x40',
                child: Text('60x40 mm'),
              ),
            ],
            onChanged: onTamanhoEtiquetaChanged,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: ativo,
            onChanged: onAtivoChanged,
            title: Text(
              'Impressora ativa',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _text(context),
              ),
            ),
            subtitle: Text(
              'Permite utilizar esta configuração nas impressões.',
              style: TextStyle(color: _muted(context)),
            ),
            activeColor: _accent(context),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: padrao,
            onChanged: onPadraoChanged,
            title: Text(
              'Definir como padrão',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _text(context),
              ),
            ),
            subtitle: Text(
              'Usar esta impressora automaticamente nas etiquetas.',
              style: TextStyle(color: _muted(context)),
            ),
            activeColor: _accent(context),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}