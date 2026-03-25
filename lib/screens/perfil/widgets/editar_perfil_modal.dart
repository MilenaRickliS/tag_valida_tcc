// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tag_valida/screens/perfil/widgets/profile_form_field.dart';
import '../../../providers/auth_provider.dart'; 


class EditarPerfilModal extends StatefulWidget {
  const EditarPerfilModal({super.key});

  @override
  State<EditarPerfilModal> createState() => _EditarPerfilModalState();
}

class _EditarPerfilModalState extends State<EditarPerfilModal> {

  final _formKey = GlobalKey<FormState>();
  final FocusNode _numeroFocus = FocusNode();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cepMask = MaskTextInputFormatter(
    mask: '##.###-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final RegExp _lettersAccentsAndNumbers = RegExp(r"^[A-Za-zÀ-ÿ0-9çÇ ]+$");
  final RegExp _lettersAccentsOnly = RegExp(r"^[A-Za-zÀ-ÿçÇ ]+$");
  final RegExp _onlyDigits = RegExp(r"^[0-9]+$");


  late final TextEditingController nome;
  late final TextEditingController razao;
  late final TextEditingController telefone;
  late final TextEditingController responsavel;

  late final TextEditingController cep;
  late final TextEditingController rua;
  late final TextEditingController numero;
  late final TextEditingController bairro;
  late final TextEditingController complemento;
  late final TextEditingController cidade;
  late final TextEditingController estado;

  bool _saving = false;

  bool _cepLoading = false;
  String _lastCepFetched = "";

  String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user!;

    nome = TextEditingController(text: u.nome);
    razao = TextEditingController(text: u.razao);

 
    telefone = TextEditingController(text: _formatPhoneFromDigits(u.telefone));
    responsavel = TextEditingController(text: u.responsavel);

    cep = TextEditingController(text: _formatCepFromDigits(u.cep));
    rua = TextEditingController(text: u.rua);
    numero = TextEditingController(text: u.numero);
    bairro = TextEditingController(text: u.bairro);
    complemento = TextEditingController(text: u.complemento);
    cidade = TextEditingController(text: u.cidade);
    estado = TextEditingController(text: u.estado);
  }

  @override
  void dispose() {
    _numeroFocus.dispose();
    nome.dispose();
    razao.dispose();
    telefone.dispose();
    responsavel.dispose();
    cep.dispose();
    rua.dispose();
    numero.dispose();
    bairro.dispose();
    complemento.dispose();
    cidade.dispose();
    estado.dispose();
    super.dispose();
  }



  String? _vNome(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Nome não pode ser vazio.";
    if (!_lettersAccentsAndNumbers.hasMatch(s)) {
      return "Nome só pode conter letras, acentos, ç e números.";
    }
    return null;
  }

  String? _vRazao(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Razão social não pode ser vazia.";
    if (!_lettersAccentsAndNumbers.hasMatch(s)) {
      return "Razão social só pode conter letras, acentos, ç e números.";
    }
    return null;
  }

  String? _vTelefone(String? _) {
    final digits = _digits(telefone.text);
    if (digits.isEmpty) return "Telefone não pode ser vazio.";
    if (digits.length != 11) return "Telefone inválido. Use: (xx) xxxxx-xxxx";
    return null;
  }


  String? _vResponsavel(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Responsável não pode ser vazio.";
    if (!_lettersAccentsOnly.hasMatch(s)) {
      return "Responsável só pode conter letras, acentos e ç.";
    }
    return null;
  }

  String? _vCep(String? _) {
    final digits = _digits(cep.text);
    if (digits.isEmpty) return "CEP não pode ser vazio.";
    if (digits.length != 8) return "CEP inválido. Use: xx.xxx-xxx";
    return null;
  }

  String? _vRua(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Rua não pode ser vazia.";
    if (!_lettersAccentsAndNumbers.hasMatch(s)) {
      return "Rua só pode conter letras, acentos, ç e números.";
    }
    return null;
  }

  String? _vNumero(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Número não pode ser vazio.";
    if (!_onlyDigits.hasMatch(s)) return "Número deve conter apenas números.";
    return null;
  }

  String? _vBairro(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Bairro não pode ser vazio.";
    return null;
  }

  String? _vCidade(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Cidade não pode ser vazia.";
    if (!_lettersAccentsOnly.hasMatch(s)) {
      return "Cidade só pode conter letras, acentos e ç.";
    }
    return null;
  }

  String? _vEstado(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Estado não pode ser vazio.";
    if (!_lettersAccentsOnly.hasMatch(s)) {
      return "Estado só pode conter letras, acentos e ç.";
    }
    if (s.length != 2) return "UF deve ter 2 letras.";
    return null;
  }

  Future<void> _buscarCep(String rawCepDigits) async {
    if (rawCepDigits.length != 8) return;
    if (rawCepDigits == _lastCepFetched) return;

    setState(() => _cepLoading = true);

    try {
      final url = Uri.parse("https://viacep.com.br/ws/$rawCepDigits/json/");
      final res = await http.get(url);

      if (res.statusCode != 200) {
        throw Exception("Falha ao consultar CEP.");
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['erro'] == true) {
        throw Exception("CEP não encontrado.");
      }

      rua.text = (data['logradouro'] ?? '').toString();
      bairro.text = (data['bairro'] ?? '').toString();
      cidade.text = (data['localidade'] ?? '').toString();
      estado.text = (data['uf'] ?? '').toString();

      _lastCepFetched = rawCepDigits;

      if (mounted) FocusScope.of(context).requestFocus(_numeroFocus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no CEP: $e")),
      );
    } finally {
      if (mounted) setState(() => _cepLoading = false);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        nome: nome.text.trim(),
        razao: razao.text.trim(),
        telefone: _digits(telefone.text),
        responsavel: responsavel.text.trim(),
        cep: _digits(cep.text),
        rua: rua.text.trim(),
        numero: numero.text.trim(),
        bairro: bairro.text.trim(),
        complemento: complemento.text.trim(),
        cidade: cidade.text.trim(),
        estado: estado.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados atualizados!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFFDF7ED);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : const Color(0xFF6B6B6B);
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.06);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                    ? Colors.white.withOpacity(0.14)
                    : Colors.black.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),

        
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: brand.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Icon(Icons.edit_rounded, color: brand),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Editar dados",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Atualize as informações da empresa",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: text),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _sectionTitle("Dados principais", brand, text),
                          ProfileFormField(
                            controller: nome,
                            label: "Nome (fantasia)",
                            validator: _vNome,
                            prefixIcon: const Icon(Icons.storefront_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: razao,
                            label: "Razão social",
                            validator: _vRazao,
                            prefixIcon: const Icon(Icons.business_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: telefone,
                            label: "Telefone",
                            type: TextInputType.phone,
                            validator: _vTelefone,
                            inputFormatters: [_phoneMask],
                            prefixIcon: const Icon(Icons.phone_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: responsavel,
                            label: "Responsável",
                            validator: _vResponsavel,
                            prefixIcon: const Icon(Icons.person_outline),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),

                          const SizedBox(height: 4),
                          Divider(height: 18, color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.06),),
                          const SizedBox(height: 2),

                          _sectionTitle("Endereço", brand, text),
                          ProfileFormField(
                            controller: cep,
                            label: "CEP",
                            type: TextInputType.number,
                            validator: _vCep,
                            inputFormatters: [_cepMask],
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            suffixIcon: _cepLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    tooltip: "Buscar CEP",
                                    onPressed: () => _buscarCep(_cepMask.getUnmaskedText()),
                                    icon: Icon(Icons.search, color: text),
                                  ),
                            onChanged: (_) {
                              final digits = _cepMask.getUnmaskedText();
                              if (digits.length == 8) _buscarCep(digits);
                            },
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: rua,
                            label: "Rua",
                            validator: _vRua,
                            prefixIcon: const Icon(Icons.signpost_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: numero,
                            label: "Número",
                            type: TextInputType.number,
                            validator: _vNumero,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            prefixIcon: const Icon(Icons.tag_outlined),
                            focusNode: _numeroFocus,
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: bairro,
                            label: "Bairro",
                            validator: _vBairro,
                            prefixIcon: const Icon(Icons.map_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: complemento,
                            label: "Complemento (opcional)",
                            validator: (_) => null,
                            prefixIcon: const Icon(Icons.add_location_alt_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: cidade,
                            label: "Cidade",
                            validator: _vCidade,
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),
                          ProfileFormField(
                            controller: estado,
                            label: "Estado (UF)",
                            validator: _vEstado,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿçÇ]")),
                              LengthLimitingTextInputFormatter(2),
                            ],
                            prefixIcon: const Icon(Icons.flag_outlined),
                            onChanged: (v) {
                              final up = v.toUpperCase();
                              if (up != v) {
                                estado.value = estado.value.copyWith(
                                  text: up,
                                  selection: TextSelection.collapsed(offset: up.length),
                                );
                              }
                            },
                            isDark: isDark,
                            textColor: text,
                            borderColor: border,
                          ),

                          const SizedBox(height: 10),

                        
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saving ? null : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: text,
                                    side: BorderSide(color: border, width: 1.4),
                                    backgroundColor:
                                      isDark ? const Color(0xFF1A1A1A) : null,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brand,
                                    foregroundColor: isDark ? Colors.black : Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: _saving
                                      ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white,),
                                        )
                                      : const Text("Salvar", style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, Color brand, Color text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: brand,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatCepFromDigits(String s) {
    final d = s.replaceAll(RegExp(r'\D'), '');
    if (d.length != 8) return s;
    _cepMask.clear();
    return _cepMask.maskText(d);
  }

  String _formatPhoneFromDigits(String s) {
    final d = s.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11) return s;
    _phoneMask.clear();
    return _phoneMask.maskText(d);
  }
}