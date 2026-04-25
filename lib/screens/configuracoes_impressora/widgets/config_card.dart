// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrinterLimits {
  static const nomeMin = 3;
  static const nomeMax = 50;

  static const modeloMin = 2;
  static const modeloMax = 40;

  static const portaMin = 1;
  static const portaMax = 65535;
}

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

  ConfigCard({
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

  final RegExp _nomePrinterRegex =
      RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÇç0-9\- ]+$");

    final RegExp _modeloPrinterRegex =
        RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÇç0-9\- ]+$");

    final RegExp _onlyDigits = RegExp(r"^[0-9]+$");

    String? _vNomeImpressora(String? v) {
      final s = (v ?? '').trim();

      if (s.isEmpty) return "Nome da impressora não pode ser vazio.";
      if (s.length < PrinterLimits.nomeMin) {
        return "Nome muito curto (mín. ${PrinterLimits.nomeMin}).";
      }
      if (s.length > PrinterLimits.nomeMax) {
        return "Nome muito longo (máx. ${PrinterLimits.nomeMax}).";
      }
      if (!_nomePrinterRegex.hasMatch(s)) {
        return "Use apenas letras, números, acentos, espaços e hífen.";
      }

      return null;
    }

    String? _vModeloImpressora(String? v) {
      final s = (v ?? '').trim();

      if (s.isEmpty) return "Modelo não pode ser vazio.";
      if (s.length < PrinterLimits.modeloMin) {
        return "Modelo muito curto (mín. ${PrinterLimits.modeloMin}).";
      }
      if (s.length > PrinterLimits.modeloMax) {
        return "Modelo muito longo (máx. ${PrinterLimits.modeloMax}).";
      }
      if (!_modeloPrinterRegex.hasMatch(s)) {
        return "Use apenas letras, números, acentos, espaços e hífen.";
      }

      return null;
    }

    String? _vTipoConexao(String? v) {
      final s = (v ?? '').trim();

      if (s.isEmpty) return "Tipo de conexão não pode ser vazio.";

      return null;
    }

    String? _vIp(String? v) {
      final s = (v ?? '').trim();

      if (s.isEmpty) return "IP não pode ser vazio.";

      final partes = s.split('.');
      if (partes.length != 4) {
        return "IP inválido. Use o formato 192.168.0.100";
      }

      for (final parte in partes) {
        if (parte.isEmpty) return "IP inválido.";
        if (!_onlyDigits.hasMatch(parte)) return "IP deve conter apenas números.";
        final n = int.tryParse(parte);
        if (n == null || n < 0 || n > 255) {
          return "IP inválido. Cada parte deve ir de 0 a 255.";
        }
      }

      return null;
    }

    String? _vPorta(String? v) {
      final s = (v ?? '').trim();

      if (s.isEmpty) return "Porta não pode ser vazia.";
      if (!_onlyDigits.hasMatch(s)) return "Porta deve conter apenas números.";

      final porta = int.tryParse(s);
      if (porta == null) return "Porta inválida.";
      if (porta < PrinterLimits.portaMin || porta > PrinterLimits.portaMax) {
        return "Porta deve estar entre ${PrinterLimits.portaMin} e ${PrinterLimits.portaMax}.";
      }

      return null;
    }

    String? _vTamanhoEtiqueta(String? v) {
      final s = (v ?? '').trim();

      if (s.isEmpty) return "Tamanho da etiqueta não pode ser vazio.";

      return null;
    }


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
           validator: _vNomeImpressora,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿÇç0-9\- ]"),
              ),
              LengthLimitingTextInputFormatter(PrinterLimits.nomeMax),
            ],
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
            validator: _vModeloImpressora,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿÇç0-9\- ]"),
              ),
              LengthLimitingTextInputFormatter(PrinterLimits.modeloMax),
            ],
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
            validator: _vTipoConexao,
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: _text(context)),
                  decoration: _inputDecoration(
                    context,
                    label: 'IP da impressora',
                    hint: 'Ex.: 192.168.0.120',
                    icon: Icons.language_rounded,
                  ),
                  validator: _vIp,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
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
                  validator: _vPorta,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
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
            validator: _vTamanhoEtiqueta,
            items: const [
              DropdownMenuItem(
                value: '50x40',
                child: Text('50x40 mm'),
              ),
              DropdownMenuItem(
                value: '60x40',
                child: Text('60x40 mm'),
              ),
              DropdownMenuItem(
                value: '100x80',
                child: Text('100x80 mm'),
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