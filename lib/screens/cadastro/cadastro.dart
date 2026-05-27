// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import './widgets/build_logo_upload.dart';
import './widgets/form_field.dart';

class FieldLimits {
  static const nomeMin = 3;
  static const nomeMax = 60;

  static const razaoMin = 5;
  static const razaoMax = 100;

  static const emailMin = 5;
  static const emailMax = 100;

  static const senhaMin = 6;
  static const senhaMax = 20;

  static const ruaMin = 3;
  static const ruaMax = 80;

  static const numeroMin = 1;
  static const numeroMax = 6;

  static const bairroMin = 2;
  static const bairroMax = 60;

  static const complementoMax = 60;

  static const cidadeMin = 2;
  static const cidadeMax = 60;

  static const responsavelMin = 3;
  static const responsavelMax = 80;
}


class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {

  final FocusNode _numeroFocus = FocusNode();

  
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
  final RegExp _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");


  final _formKey = GlobalKey<FormState>();

  final nome = TextEditingController();
  final razao = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final cnpj = TextEditingController();
  final cep = TextEditingController();
  final rua = TextEditingController();
  final numero = TextEditingController();
  final bairro = TextEditingController();
  final complemento = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final telefone = TextEditingController();
  final responsavel = TextEditingController();
  File? _logoFile;

  bool _loading = false;
  bool _obscure = true;
  double _forcaSenha = 0;
  String _nivelSenha = "";

  final List<String> dominiosPermitidos = [
    'gmail.com',
    'hotmail.com',
    'outlook.com',
    'yahoo.com',
    'yahoo.com.br',
    'icloud.com'
  ];

  @override
  void dispose() {
    _numeroFocus.dispose();
    nome.dispose();
    razao.dispose();
    email.dispose();
    senha.dispose();
    cnpj.dispose();
    cep.dispose();
    rua.dispose();
    numero.dispose();
    bairro.dispose();
    complemento.dispose();
    cidade.dispose();
    estado.dispose();
    telefone.dispose();
    responsavel.dispose();
    super.dispose();
  }
  

  String? _vNome(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Nome não pode ser vazio.";
    if (s.length < FieldLimits.nomeMin) {
      return "Nome muito curto (mín. ${FieldLimits.nomeMin}).";
    }
    if (s.length > FieldLimits.nomeMax) {
      return "Nome muito longo (máx. ${FieldLimits.nomeMax}).";
    }
    if (!_lettersAccentsAndNumbers.hasMatch(s)) {
      return "Nome só pode conter letras, acentos, ç e números.";
    }
    return null;
  }

  String? _vRazao(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Razão social não pode ser vazia.";
    if (s.length < FieldLimits.razaoMin) {
      return "Razão muito curta (mín. ${FieldLimits.razaoMin}).";
    }
    if (s.length > FieldLimits.razaoMax) {
      return "Razão muito longa (máx. ${FieldLimits.razaoMax}).";
    }
    if (!_lettersAccentsAndNumbers.hasMatch(s)) {
      return "Razão social só pode conter letras, acentos, ç e números.";
    }
    return null;
  }

  String? _vEmail(String? v) {
    final s = (v ?? '').trim().toLowerCase();

    if (s.isEmpty) return "E-mail não pode ser vazio.";
    if (s.length < FieldLimits.emailMin) return "E-mail muito curto.";
    if (s.length > FieldLimits.emailMax) return "E-mail muito longo.";

    if (!_emailRegex.hasMatch(s)) return "E-mail inválido.";

    final dominio = s.split('@').last;

    if (!dominiosPermitidos.contains(dominio)) {
      return "Use um e-mail válido (gmail, outlook, etc).";
    }

    return null;
  }

  String? _vSenha(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return "Senha não pode ser vazia.";
    if (s.length < FieldLimits.senhaMin) {
      return "Senha muito curta (mín. ${FieldLimits.senhaMin}).";
    }
    if (s.length > FieldLimits.senhaMax) {
      return "Senha muito longa (máx. ${FieldLimits.senhaMax}).";
    }
    if (s.contains(' ')) {
      return "Senha não pode conter espaços.";
    }
    return null;
  }

  int _calcularForcaSenha(String senha) {
    int score = 0;

    if (RegExp(r'[a-z]').hasMatch(senha)) score++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) score++;
    if (RegExp(r'[0-9]').hasMatch(senha)) score++;
    if (RegExp(r'[!@#\$&*~_%\-]').hasMatch(senha)) score++;

    return score;
  }

  String? _vCnpj(String? v) {
    final digits = _cnpjMask.getUnmaskedText(); 
    if (digits.trim().isEmpty) return "CNPJ não pode ser vazio.";
    if (digits.length != 14) return "CNPJ inválido. Use: xx.xxx.xxx/xxxx-xx";
    if (!_onlyDigits.hasMatch(digits)) return "CNPJ deve conter apenas números.";
    return null;
  }

  String? _vTelefone(String? v) {
    final digits = _phoneMask.getUnmaskedText();
    if (digits.trim().isEmpty) return "Telefone não pode ser vazio.";
    if (digits.length != 11) return "Telefone inválido. Use: (xx) xxxxx-xxxx";
    if (!_onlyDigits.hasMatch(digits)) return "Telefone deve conter apenas números.";
    return null;
  }

  String? _vResponsavel(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Responsável não pode ser vazio.";
    if (s.length < FieldLimits.responsavelMin) return "Nome muito curto (min. ${FieldLimits.responsavelMin}).";
    if (s.length > FieldLimits.responsavelMax) return "Nome muito longo (máx. ${FieldLimits.responsavelMax}).";
    if (!_lettersAccentsOnly.hasMatch(s)) {
      return "Responsável só pode conter letras, acentos e ç.";
    }
    return null;
  }

  String? _vCep(String? v) {
    final digits = _cepMask.getUnmaskedText();
    if (digits.trim().isEmpty) return "CEP não pode ser vazio.";
    if (digits.length != 8) return "CEP inválido. Use: xx.xxx-xxx";
    if (!_onlyDigits.hasMatch(digits)) return "CEP deve conter apenas números.";
    return null;
  }

  String? _vRua(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Rua não pode ser vazia.";
    if (s.length < FieldLimits.ruaMin) return "Rua muito curta (min. ${FieldLimits.ruaMin}).";
    if (s.length > FieldLimits.ruaMax) return "Rua muito longa (máx. ${FieldLimits.ruaMax}).";
    if (!_lettersAccentsAndNumbers.hasMatch(s)) {
      return "Rua só pode conter letras, acentos, ç e números.";
    }
    return null;
  }

  String? _vNumero(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Número não pode ser vazio.";
    if (s.length < FieldLimits.numeroMin) return "Número inválido (min. ${FieldLimits.numeroMin}).";
    if (s.length > FieldLimits.numeroMax) return "Número muito longo (máx. ${FieldLimits.numeroMax}).";
    if (!_onlyDigits.hasMatch(s)) return "Número deve conter apenas números.";
    return null;
  }

  String? _vBairro(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Bairro não pode ser vazio.";
    if (s.length < FieldLimits.bairroMin) return "Bairro muito curto (min. ${FieldLimits.bairroMin}).";
    if (s.length > FieldLimits.bairroMax) return "Bairro muito longo (máx. ${FieldLimits.bairroMax}).";
    return null;
  }

  String? _vCidade(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Cidade não pode ser vazia.";
    if (s.length < FieldLimits.cidadeMin) return "Cidade muito curta (min. ${FieldLimits.cidadeMin}).";
    if (s.length > FieldLimits.cidadeMax) return "Cidade muito longa (máx. ${FieldLimits.cidadeMax}).";
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
    return null;
  }

  String? _vComplemento(String? v) {
    final s = (v ?? '').trim();

    if (s.length > FieldLimits.complementoMax) {
      return "Complemento muito longo (máx. ${FieldLimits.complementoMax}).";
    }

    return null;
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _logoFile = File(picked.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar logo: $e')),
      );
    }
  }

  void _removerLogo() {
    setState(() {
      _logoFile = null;
    });
  }

  String? _vLogoFile() {
    if (_logoFile == null) return null; 

    final path = _logoFile!.path.toLowerCase();

    final permitido = path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');

    if (!permitido) {
      return 'Selecione uma imagem PNG, JPG, JPEG ou WEBP.';
    }

    final tamanho = _logoFile!.lengthSync();
    const maxBytes = 5 * 1024 * 1024;

    if (tamanho > maxBytes) {
      return 'A logo deve ter no máximo 5 MB.';
    }

    return null;
  }


  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

     final logoErro = _vLogoFile();
      if (logoErro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(logoErro)),
        );
        return;
      }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            nome: nome.text.trim(),
            razao: razao.text.trim(),
            email: email.text.trim(),
            senha: senha.text,
            cnpj: _cnpjMask.getUnmaskedText(),
            telefone: _phoneMask.getUnmaskedText(),
            cep: _cepMask.getUnmaskedText(),
          
            rua: rua.text.trim(),
            numero: numero.text.trim(),
            bairro: bairro.text.trim(),
            complemento: complemento.text.trim(),
            cidade: cidade.text.trim(),
            estado: estado.text.trim(),
            
            responsavel: responsavel.text.trim(),
            logoFile: _logoFile,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado!")),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  bool _cepLoading = false;
  String _lastCepFetched = "";

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
      // ignore: use_build_context_synchronously
      FocusScope.of(context).requestFocus(_numeroFocus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no CEP: $e")),
      );
    } finally {
      if (mounted) setState(() => _cepLoading = false);
    }
    

  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Cadastro",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (_) => false,
            );
          },
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: isDark ? 'Modo claro' : 'Modo escuro',
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  key: ValueKey(isDark),
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo3-semfundo.png',
                  height: 150,
                ),
                const SizedBox(height: 16),
                Card(
                  color: theme.cardColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppFormField(
                            controller: nome,
                            label: "Nome (fantasia)",
                            validator: _vNome,
                            prefixIcon: Icon(
                              Icons.storefront_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: razao,
                            label: "Razão social",
                            validator: _vRazao,
                            prefixIcon: Icon(
                              Icons.business_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: email,
                            label: "E-mail",
                            keyboardType: TextInputType.emailAddress,
                            validator: _vEmail,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: senha,
                            label: "Senha",
                            obscureText: _obscure,
                            validator: _vSenha,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: colorScheme.onSurface.withOpacity(0.75),
                              ),
                            ),
                            onChanged: (value) {
                              final score = _calcularForcaSenha(value);

                              setState(() {
                                _forcaSenha = score / 4;

                                if (score <= 1) {
                                  _nivelSenha = "Fraca";
                                } else if (score <= 3) {
                                  _nivelSenha = "Média";
                                } else {
                                  _nivelSenha = "Forte";
                                }
                              });
                            },
                          ),

                         Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _forcaSenha,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _forcaSenha <= 0.25
                                        ? Colors.red.shade400
                                        : _forcaSenha <= 0.75
                                            ? Colors.orange.shade400
                                            : Colors.green.shade500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Icon(
                                    _forcaSenha <= 0.25
                                        ? Icons.warning_amber_rounded
                                        : _forcaSenha <= 0.75
                                            ? Icons.info_outline
                                            : Icons.check_circle,
                                    size: 18,
                                    color: _forcaSenha <= 0.25
                                        ? Colors.red.shade400
                                        : _forcaSenha <= 0.75
                                            ? Colors.orange.shade400
                                            : Colors.green.shade500,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    _nivelSenha,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: _forcaSenha <= 0.25
                                          ? Colors.red.shade400
                                          : _forcaSenha <= 0.75
                                              ? Colors.orange.shade400
                                              : Colors.green.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          Divider(
                            height: 24,
                            color: theme.dividerColor.withOpacity(0.35),
                          ),

                          AppFormField(
                            controller: cnpj,
                            label: "CNPJ",
                            keyboardType: TextInputType.number,
                            validator: _vCnpj,
                            inputFormatters: [_cnpjMask],
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: telefone,
                            label: "Telefone",
                            keyboardType: TextInputType.phone,
                            validator: _vTelefone,
                            inputFormatters: [_phoneMask],
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: responsavel,
                            label: "Responsável",
                            validator: _vResponsavel,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),

                          Divider(
                            height: 24,
                            color: theme.dividerColor.withOpacity(0.35),
                          ),

                          AppFormField(
                            controller: cep,
                            label: "CEP",
                            keyboardType: TextInputType.number,
                            validator: _vCep,
                            inputFormatters: [_cepMask],
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                            suffixIcon: _cepLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    tooltip: "Buscar CEP",
                                    onPressed: () =>
                                        _buscarCep(_cepMask.getUnmaskedText()),
                                    icon: Icon(
                                      Icons.search,
                                      color: colorScheme.onSurface
                                          .withOpacity(0.75),
                                    ),
                                  ),
                            onChanged: (_) {
                              final digits = _cepMask.getUnmaskedText();
                              if (digits.length == 8) _buscarCep(digits);
                            },
                          ),
                          AppFormField(
                            controller: rua,
                            label: "Rua",
                            validator: _vRua,
                            prefixIcon: Icon(
                              Icons.signpost_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: numero,
                            label: "Número",
                            keyboardType: TextInputType.number,
                            validator: _vNumero,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            prefixIcon: Icon(
                              Icons.tag_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                            focusNode: _numeroFocus,
                          ),
                          AppFormField(
                            controller: bairro,
                            label: "Bairro",
                            validator: _vBairro,
                            prefixIcon: Icon(
                              Icons.map_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: complemento,
                            label: "Complemento (opcional)",
                            validator: _vComplemento,
                            prefixIcon: Icon(
                              Icons.add_location_alt_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: cidade,
                            label: "Cidade",
                            validator: _vCidade,
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                          ),
                          AppFormField(
                            controller: estado,
                            label: "Estado (UF)",
                            validator: _vEstado,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[A-Za-zÀ-ÿçÇ]"),
                              ),
                              LengthLimitingTextInputFormatter(2),
                            ],
                            prefixIcon: Icon(
                              Icons.flag_outlined,
                              color: colorScheme.onSurface.withOpacity(0.75),
                            ),
                            onChanged: (v) {
                              final up = v.toUpperCase();
                              if (up != v) {
                                estado.value = estado.value.copyWith(
                                  text: up,
                                  selection: TextSelection.collapsed(
                                    offset: up.length,
                                  ),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 8),

                          LogoUploadCard(
                            logoFile: _logoFile,
                            loading: _loading,
                            onPickLogo: _pickLogo,
                            onRemoveLogo: _removerLogo,
                          ),

                          const SizedBox(height: 8),

                          ElevatedButton(
                            onPressed: _loading ? null : _cadastrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC29500),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Cadastrar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => Navigator.pushNamed(
                                          context,
                                          '/login',
                                        ),
                                child: Text(
                                  "Já possui conta? Faça login.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onSurface,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}