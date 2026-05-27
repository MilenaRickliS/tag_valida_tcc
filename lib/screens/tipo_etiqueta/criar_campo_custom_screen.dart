// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/tipo_etiqueta_model.dart';
import '../../widgets/menu.dart';
import './tipo_etiqueta_helpers.dart';

class CriarCampoCustomScreen extends StatefulWidget {
  final CampoCustomModel? campo;

  const CriarCampoCustomScreen({
    super.key,
    this.campo,
  });

  @override
  State<CriarCampoCustomScreen> createState() => _CriarCampoCustomScreenState();
}

class _CriarCampoCustomScreenState extends State<CriarCampoCustomScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _outroSimboloCtrl;

  late CampoTipo _tipo;
  late bool _obrigatorio;
  late String _unidadeSelecionada;
  late String _outroSimbolo;
  late String? _prefixo;
  late String? _sufixo;
  late CampoPosicaoSimbolo _posicaoSimbolo;
  late int _casasDecimais;
  late List<String> _opcoesModoPreco;
  late String _modoPrecoPadrao;

  bool _userEditedKey = false;

  bool get _isEdit => widget.campo != null;
  bool get _keyLocked => _isEdit;

  final List<String> _modosDisponiveisBase = ['kg', 'un', 'cx', 'pct'];

  final List<String> _unidadesBase = const [
    '',
    'R\$',
    'kg',
    'g',
    'mg',
    'l',
    'ml',
    'mm',
    'cm',
    'm',
    'un',
    'pct',
    'cx',
    '__outro__',
  ];

  @override
  void initState() {
    super.initState();

    final c = widget.campo;

    _labelCtrl = TextEditingController(text: c?.label ?? "");
    _keyCtrl = TextEditingController(text: c?.key ?? "");
    _outroSimbolo = c?.unidadePadrao ?? "";
    _outroSimboloCtrl = TextEditingController(text: _outroSimbolo);

    _tipo = c?.tipo ?? CampoTipo.text;
    _obrigatorio = c?.obrigatorio ?? false;
    _unidadeSelecionada = c?.unidadePadrao ?? "";
    _prefixo = c?.prefixo;
    _sufixo = c?.sufixo;
    _posicaoSimbolo = c?.posicaoSimbolo ?? CampoPosicaoSimbolo.none;
    _casasDecimais = c?.casasDecimais ?? 2;
    _opcoesModoPreco = [...(c?.opcoesModoPreco ?? const [])];
    _modoPrecoPadrao = c?.modoPrecoPadrao ?? 'kg';

    _userEditedKey = _isEdit;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _keyCtrl.dispose();
    _outroSimboloCtrl.dispose();
    super.dispose();
  }

  void _aplicarSimboloConfig() {
    final simbolo = _unidadeSelecionada == '__outro__'
        ? _outroSimbolo.trim()
        : _unidadeSelecionada.trim();

    if (_tipo == CampoTipo.priceMode) {
      _prefixo = 'R\$ ';
      _sufixo = null;
      return;
    }

    if (_tipo == CampoTipo.currency) {
      if (_posicaoSimbolo == CampoPosicaoSimbolo.prefix) {
        _prefixo = simbolo.isEmpty ? 'R\$ ' : '$simbolo ';
        _sufixo = null;
      } else if (_posicaoSimbolo == CampoPosicaoSimbolo.suffix) {
        _prefixo = null;
        _sufixo = simbolo.isEmpty ? null : ' $simbolo';
      } else {
        _prefixo = 'R\$ ';
        _sufixo = null;
      }
      return;
    }

    if (_tipo == CampoTipo.integer || _tipo == CampoTipo.decimal) {
      if (_posicaoSimbolo == CampoPosicaoSimbolo.prefix) {
        _prefixo = simbolo.isEmpty ? null : '$simbolo ';
        _sufixo = null;
      } else if (_posicaoSimbolo == CampoPosicaoSimbolo.suffix) {
        _prefixo = null;
        _sufixo = simbolo.isEmpty ? null : ' $simbolo';
      } else {
        _prefixo = null;
        _sufixo = null;
      }
      return;
    }

    _prefixo = null;
    _sufixo = null;
  }

  String _formatarExemploNumero() {
    switch (_casasDecimais) {
      case 0:
        return '20';
      case 1:
        return '20,0';
      case 2:
        return '20,00';
      case 3:
        return '20,000';
      default:
        return '20,00';
    }
  }

  String _buildPreview() {
    final exemplo = _formatarExemploNumero();

    if (_tipo == CampoTipo.priceMode) {
      final modo = _opcoesModoPreco.isNotEmpty ? _modoPrecoPadrao : 'kg';
      return 'R\$ $exemplo/$modo';
    }

    if (_tipo == CampoTipo.currency ||
        _tipo == CampoTipo.integer ||
        _tipo == CampoTipo.decimal) {
      return '${_prefixo ?? ''}$exemplo${_sufixo ?? ''}'.trim();
    }

    switch (_tipo) {
      case CampoTipo.text:
        return 'Ex: Lote Especial';
      case CampoTipo.multiline:
        return 'Ex: Observação do produto';
      case CampoTipo.date:
        return 'Ex: 08/04/2026';
      case CampoTipo.boolType:
        return 'Ex: Sim';
      case CampoTipo.image:
        return 'Ex: Imagem do produto';
      default:
        return 'Pré-visualização';
    }
  }

  void _salvar() {
    FocusScope.of(context).unfocus();

    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) return;

    final label = _labelCtrl.text.trim();

    if (!_keyLocked && !_userEditedKey) {
      _keyCtrl.text = makeKeyFromLabel(label);
    }

    final key = _keyCtrl.text.trim();

    if (_tipo == CampoTipo.priceMode && _opcoesModoPreco.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione pelo menos um modo de preço.")),
      );
      return;
    }

    final unidadeFinal = _unidadeSelecionada == '__outro__'
        ? _outroSimbolo.trim()
        : _unidadeSelecionada.trim();

    final campo = CampoCustomModel(
      key: key,
      label: label,
      tipo: _tipo,
      obrigatorio: _obrigatorio,
      prefixo: _prefixo,
      sufixo: _sufixo,
      unidadePadrao: unidadeFinal.isEmpty ? null : unidadeFinal,
      opcoesUnidade: unidadeFinal.isEmpty ? const [] : [unidadeFinal],
      permitirUnidadeCustom: _unidadeSelecionada == '__outro__',
      posicaoSimbolo: _posicaoSimbolo,
      casasDecimais: _casasDecimais,
      habilitarModoPreco: _tipo == CampoTipo.priceMode,
      opcoesModoPreco:
          _tipo == CampoTipo.priceMode ? _opcoesModoPreco : const [],
      modoPrecoPadrao:
          _tipo == CampoTipo.priceMode ? _modoPrecoPadrao : null,
    );

    Navigator.pop(context, campo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted =
        isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final onBrand = isDark ? Colors.black : Colors.white;

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

    final previewKey = makeKeyFromLabel(_labelCtrl.text);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: compact ? 160 : 100,
        centerTitle: true,
        title: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/logo6.png', height: 78),
                  const SizedBox(height: 10),
                  const TopMenu(),
                ],
              )
            : Row(
                children: [
                  Image.asset('assets/logo6.png', height: 92),
                  const Spacer(),
                  const TopMenu(),
                ],
              ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? "Editar campo" : "Criar campo",
                    style: TextStyle(
                      color: text,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Configure como este campo será preenchido na etiqueta.",
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _labelCtrl,
                    style: TextStyle(color: text),
                    inputFormatters: [
                      const TitleCaseEachWordFormatter(),
                      LengthLimitingTextInputFormatter(CampoCustomLimits.labelMax),
                    ],
                    onChanged: (value) {
                      if (!_keyLocked && !_userEditedKey) {
                        _keyCtrl.text = makeKeyFromLabel(value);
                      }
                      setState(() {});
                    },
                    decoration: appTipoInputDecoration(
                      context: context,
                      label: "Nome do campo",
                      hint: "Ex: Preço de venda",
                      helper: "Label é o nome que aparece na etiqueta.",
                    ),
                    validator: (v) {
                      final s = (v ?? "").trim();

                      if (s.isEmpty) return "Informe o nome do campo.";
                      if (s.length < CampoCustomLimits.labelMin) {
                        return "Mínimo de ${CampoCustomLimits.labelMin} caracteres.";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _keyCtrl,
                    style: TextStyle(color: text),
                    readOnly: _keyLocked,
                    inputFormatters: _keyLocked
                        ? null
                        : [
                            keyDenyFormatter,
                            LengthLimitingTextInputFormatter(
                              CampoCustomLimits.keyMax,
                            ),
                          ],
                    onChanged: (_) {
                      if (!_keyLocked) {
                        setState(() => _userEditedKey = true);
                      }
                    },
                    decoration: appTipoInputDecoration(
                      context: context,
                      label: "Chave (Key)",
                      hint: "Ex: preco_venda",
                      helper: _keyLocked
                          ? "A key não pode ser alterada depois de criada."
                          : (_userEditedKey
                              ? "Editada manualmente."
                              : "Gerada automaticamente pelo nome."),
                      prefixIcon: Icon(
                        _keyLocked ? Icons.lock_outline : Icons.key_outlined,
                        color: _keyLocked ? muted : brand,
                      ),
                      suffixIcon: !_keyLocked && _userEditedKey
                          ? IconButton(
                              tooltip: "Gerar automaticamente",
                              onPressed: () {
                                setState(() {
                                  _userEditedKey = false;
                                  _keyCtrl.text =
                                      makeKeyFromLabel(_labelCtrl.text);
                                });
                              },
                              icon: Icon(Icons.auto_fix_high, color: brand),
                            )
                          : null,
                    ),
                    validator: (v) {
                      final s = (v ?? "").trim();

                      if (s.isEmpty) return "A key não pode ficar vazia.";
                      if (s.length < CampoCustomLimits.keyMin) {
                        return "Key muito curta.";
                      }

                      final ok = RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s);
                      if (!ok) {
                        return "Use apenas letras, números e _.";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Preview da key: $previewKey",
                    style: TextStyle(color: muted, fontSize: 12.5),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<CampoTipo>(
                    value: _tipo,
                    dropdownColor:
                        isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    style: TextStyle(color: text),
                    decoration: appTipoInputDecoration(
                      context: context,
                      label: "Tipo do campo",
                    ),
                    items: CampoTipo.values.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(
                          campoTipoLabel(tipo),
                          style: TextStyle(color: text),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _tipo = v ?? CampoTipo.text;

                        if (_tipo == CampoTipo.currency) {
                          _unidadeSelecionada =
                              _unidadeSelecionada.isEmpty ? 'R\$' : _unidadeSelecionada;
                          _posicaoSimbolo = CampoPosicaoSimbolo.prefix;
                        }

                        if (_tipo == CampoTipo.priceMode) {
                          if (_opcoesModoPreco.isEmpty) {
                            _opcoesModoPreco = ['kg', 'un'];
                          }

                          if (!_opcoesModoPreco.contains(_modoPrecoPadrao)) {
                            _modoPrecoPadrao = _opcoesModoPreco.first;
                          }
                        }

                        _aplicarSimboloConfig();
                      });
                    },
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Como será preenchido: ${campoTipoHint(_tipo)}",
                    style: TextStyle(color: muted, fontSize: 12.5),
                  ),

                  if (_tipo == CampoTipo.integer ||
                      _tipo == CampoTipo.decimal ||
                      _tipo == CampoTipo.currency) ...[
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _unidadesBase.contains(_unidadeSelecionada)
                          ? _unidadeSelecionada
                          : '__outro__',
                      dropdownColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: text),
                      decoration: appTipoInputDecoration(
                        context: context,
                        label: "Unidade / símbolo",
                      ),
                      items: _unidadesBase.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text(
                            u.isEmpty
                                ? "Nenhum"
                                : u == "__outro__"
                                    ? "Outro"
                                    : u,
                            style: TextStyle(color: text),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _unidadeSelecionada = v ?? '';

                          if (_unidadeSelecionada != '__outro__') {
                            _outroSimbolo = '';
                            _outroSimboloCtrl.clear();
                          }

                          _aplicarSimboloConfig();
                        });
                      },
                    ),

                    if (_unidadeSelecionada == '__outro__') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _outroSimboloCtrl,
                        style: TextStyle(color: text),
                        decoration: appTipoInputDecoration(
                          context: context,
                          label: "Outro símbolo",
                          hint: "Ex: caixa, pacote",
                        ),
                        onChanged: (v) {
                          setState(() {
                            _outroSimbolo = v;
                            _aplicarSimboloConfig();
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    DropdownButtonFormField<CampoPosicaoSimbolo>(
                      value: _posicaoSimbolo,
                      dropdownColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: text),
                      decoration: appTipoInputDecoration(
                        context: context,
                        label: "Posição do símbolo",
                      ),
                      items: [
                        DropdownMenuItem(
                          value: CampoPosicaoSimbolo.none,
                          child: Text("Sem símbolo", style: TextStyle(color: text)),
                        ),
                        DropdownMenuItem(
                          value: CampoPosicaoSimbolo.prefix,
                          child: Text("Antes", style: TextStyle(color: text)),
                        ),
                        DropdownMenuItem(
                          value: CampoPosicaoSimbolo.suffix,
                          child: Text("Depois", style: TextStyle(color: text)),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _posicaoSimbolo = v ?? CampoPosicaoSimbolo.none;
                          _aplicarSimboloConfig();
                        });
                      },
                    ),

                    if (_tipo == CampoTipo.decimal ||
                        _tipo == CampoTipo.currency) ...[
                      const SizedBox(height: 12),
                      _casasDecimaisDropdown(text, isDark),
                    ],
                  ],

                  if (_tipo == CampoTipo.priceMode) ...[
                    const SizedBox(height: 12),
                    _modosPrecoCard(text, muted, brand, isDark),
                    const SizedBox(height: 12),
                    _modoPadraoDropdown(text, isDark),
                    const SizedBox(height: 12),
                    _casasDecimaisDropdown(text, isDark),
                  ],

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: brand.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brand.withOpacity(0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pré-visualização",
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _buildPreview(),
                          style: TextStyle(
                            color: brand,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SwitchListTile(
                    value: _obrigatorio,
                    onChanged: (v) => setState(() => _obrigatorio = v),
                    title: Text(
                      "Campo obrigatório",
                      style: TextStyle(color: text, fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      "Se ativo, a etiqueta só salva se este campo estiver preenchido.",
                      style: TextStyle(color: muted),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _salvar,
                          icon: const Icon(Icons.check,  color: Colors.white,),
                          label: Text(_isEdit ? "Salvar" : "Adicionar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand,
                            foregroundColor: onBrand,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _casasDecimaisDropdown(Color text, bool isDark) {
    return DropdownButtonFormField<int>(
      value: _casasDecimais,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: text),
      decoration: appTipoInputDecoration(
        context: context,
        label: "Casas decimais",
      ),
      items: [0, 1, 2, 3].map((n) {
        return DropdownMenuItem(
          value: n,
          child: Text("$n", style: TextStyle(color: text)),
        );
      }).toList(),
      onChanged: (v) {
        setState(() => _casasDecimais = v ?? 2);
      },
    );
  }

  Widget _modoPadraoDropdown(Color text, bool isDark) {
    final opcoes = _opcoesModoPreco.isEmpty ? ['kg'] : _opcoesModoPreco;

    return DropdownButtonFormField<String>(
      value: opcoes.contains(_modoPrecoPadrao)
          ? _modoPrecoPadrao
          : opcoes.first,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: text),
      decoration: appTipoInputDecoration(
        context: context,
        label: "Modo padrão",
      ),
      items: opcoes.map((modo) {
        return DropdownMenuItem(
          value: modo,
          child: Text(modo, style: TextStyle(color: text)),
        );
      }).toList(),
      onChanged: (v) {
        setState(() => _modoPrecoPadrao = v ?? 'kg');
      },
    );
  }

  Widget _modosPrecoCard(
    Color text,
    Color muted,
    Color brand,
    bool isDark,
  ) {
    final fieldBg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF7F1);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Modos permitidos",
            style: TextStyle(color: text, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _modosDisponiveisBase.map((modo) {
              final selected = _opcoesModoPreco.contains(modo);

              return FilterChip(
                label: Text(modo),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      if (!_opcoesModoPreco.contains(modo)) {
                        _opcoesModoPreco.add(modo);
                      }
                    } else {
                      _opcoesModoPreco.remove(modo);
                    }

                    if (_opcoesModoPreco.isEmpty) {
                      _modoPrecoPadrao = 'kg';
                    } else if (!_opcoesModoPreco.contains(_modoPrecoPadrao)) {
                      _modoPrecoPadrao = _opcoesModoPreco.first;
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}