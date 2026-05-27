// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/tipo_etiqueta_model.dart';
import '../../providers/tipos_etiqueta_provider.dart';
import '../../widgets/menu.dart';

import './criar_campo_custom_screen.dart';
import './tipo_etiqueta_helpers.dart';
import './widgets/campo_custom_section.dart';

class CriarTipoEtiquetaScreen extends StatefulWidget {
  final String uid;
  final TipoEtiquetaModel? tipo;

  const CriarTipoEtiquetaScreen({
    super.key,
    required this.uid,
    this.tipo,
  });

  @override
  State<CriarTipoEtiquetaScreen> createState() =>
      _CriarTipoEtiquetaScreenState();
}

class _CriarTipoEtiquetaScreenState extends State<CriarTipoEtiquetaScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descCtrl;

  late bool _usarRegra;
  late bool _controlaLote;
  late bool _permiteTabelaNutricional;
  late TipoQrEtiqueta _tipoQr;
  late List<CampoCustomModel> _campos;

  bool _saving = false;
  String? _erroGeral;

  bool get _isEdit => widget.tipo != null;

  @override
  void initState() {
    super.initState();

    final t = widget.tipo;

    _nomeCtrl = TextEditingController(text: t?.nome ?? "");
    _descCtrl = TextEditingController(text: t?.descricao ?? "");

    _usarRegra = t?.usarRegraValidadeCategoria ?? true;
    _controlaLote = t?.controlaLote ?? false;
    _permiteTabelaNutricional = t?.permiteTabelaNutricional ?? false;
    _tipoQr = t?.tipoQr ?? TipoQrEtiqueta.privado;
    _campos = [...(t?.camposCustom ?? [])];
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _validarTipo() {
    final nome = _nomeCtrl.text.trim().replaceAll(RegExp(r"\s+"), " ");
    final desc = _descCtrl.text.trim();

    if (nome.isEmpty) return "Informe o nome do tipo.";

    if (nome.length < TipoEtiquetaLimits.nomeMin) {
      return "Nome muito curto. Mínimo de ${TipoEtiquetaLimits.nomeMin} caracteres.";
    }

    if (nome.length > TipoEtiquetaLimits.nomeMax) {
      return "Nome muito longo. Máximo de ${TipoEtiquetaLimits.nomeMax} caracteres.";
    }

    final nomeOk = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÇç0-9 ]+$").hasMatch(nome);
    if (!nomeOk) return "Nome inválido. Use apenas letras, números e espaços.";

    if (desc.length > TipoEtiquetaLimits.descMax) {
      return "Descrição muito longa. Máximo de ${TipoEtiquetaLimits.descMax} caracteres.";
    }

    final labels = <String>{};
    final keys = <String>{};

    for (final c in _campos) {
      final label = c.label.trim();
      final key = c.key.trim();

      if (label.isEmpty) return "Existe um campo com nome vazio.";
      if (key.isEmpty) return "Existe um campo com key vazia.";

      final labelNormalizado = label.toLowerCase();
      final keyNormalizada = key.toLowerCase();

      if (labels.contains(labelNormalizado)) {
        return "Existe campo com nome duplicado: $label.";
      }

      if (keys.contains(keyNormalizada)) {
        return "Existe campo com key duplicada: $key.";
      }

      labels.add(labelNormalizado);
      keys.add(keyNormalizada);
    }

    return null;
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) return;

    final erro = _validarTipo();

    if (erro != null) {
      setState(() => _erroGeral = erro);
      return;
    }

    setState(() {
      _saving = true;
      _erroGeral = null;
    });

    final nome = _nomeCtrl.text.trim().replaceAll(RegExp(r"\s+"), " ");
    final desc = _descCtrl.text.trim();

    final novoTipo = TipoEtiquetaModel(
      id: widget.tipo?.id ?? "",
      nome: nome,
      descricao: desc.isEmpty ? null : desc,
      usarRegraValidadeCategoria: _usarRegra,
      controlaLote: _controlaLote,
      permiteTabelaNutricional: _permiteTabelaNutricional,
      camposCustom: _campos,
      tipoQr: _tipoQr,
    );

    try {
      final prov = context.read<TiposEtiquetaProvider>();

      if (_isEdit) {
        await prov.update(widget.uid, novoTipo);
      } else {
        await prov.create(widget.uid, novoTipo);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _erroGeral = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  Future<void> _adicionarCampo() async {
    final novo = await Navigator.push<CampoCustomModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const CriarCampoCustomScreen(),
      ),
    );

    if (novo == null) return;

    setState(() {
      _campos.add(novo);
      _erroGeral = null;
    });
  }

  Future<void> _editarCampo(int index, CampoCustomModel campo) async {
    final editado = await Navigator.push<CampoCustomModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CriarCampoCustomScreen(campo: campo),
      ),
    );

    if (editado == null) return;

    setState(() {
      _campos[index] = editado;
      _erroGeral = null;
    });
  }

  void _removerCampo(int index) {
    setState(() {
      _campos.removeAt(index);
      _erroGeral = null;
    });
  }

  void _reordenarCampos(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;

      final item = _campos.removeAt(oldIndex);
      _campos.insert(newIndex, item);
    });
  }

  Widget _switchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted =
        isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final fieldBg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF7F1);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: value ? brand.withOpacity(0.25) : border),
        borderRadius: BorderRadius.circular(14),
        color: value ? brand.withOpacity(0.10) : fieldBg,
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: muted, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
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
    final sectionBg = isDark ? const Color(0xFF181818) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF7F1);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;

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
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? "Editar tipo de etiqueta" : "Novo tipo de etiqueta",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Configure as regras e os campos personalizados deste modelo.",
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 18),

                  if (_erroGeral != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withOpacity(0.25)),
                      ),
                      child: Text(
                        _erroGeral!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextFormField(
                    controller: _nomeCtrl,
                    style: TextStyle(color: text),
                    inputFormatters: [
                      const TitleCaseEachWordFormatter(),
                      nomeDenyFormatter,
                      LengthLimitingTextInputFormatter(TipoEtiquetaLimits.nomeMax),
                    ],
                    decoration: appTipoInputDecoration(
                      context: context,
                      label: "Nome",
                      hint: "Ex: Etiqueta Freezer",
                    ),
                    validator: (v) {
                      final s = (v ?? "").trim();

                      if (s.isEmpty) return "Informe o nome do tipo.";
                      if (s.length < TipoEtiquetaLimits.nomeMin) {
                        return "Mínimo de ${TipoEtiquetaLimits.nomeMin} caracteres.";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descCtrl,
                    style: TextStyle(color: text),
                    maxLines: 2,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(TipoEtiquetaLimits.descMax),
                    ],
                    decoration: appTipoInputDecoration(
                      context: context,
                      label: "Descrição (opcional)",
                      hint: "Ex: Modelo para produtos congelados",
                    ),
                  ),

                  const SizedBox(height: 12),

                  _switchCard(
                    title: "Usar regra de validade da categoria",
                    subtitle: "Calcula a validade com base na categoria selecionada.",
                    value: _usarRegra,
                    onChanged: (v) => setState(() => _usarRegra = v),
                  ),

                  const SizedBox(height: 10),

                  _switchCard(
                    title: "Controlar lote",
                    subtitle: "Adiciona controle de lote automático ou obrigatório.",
                    value: _controlaLote,
                    onChanged: (v) => setState(() => _controlaLote = v),
                  ),

                  const SizedBox(height: 10),

                  _switchCard(
                    title: "Permitir tabela nutricional",
                    subtitle: "Permite usar tabela nutricional na criação da etiqueta.",
                    value: _permiteTabelaNutricional,
                    onChanged: (v) =>
                        setState(() => _permiteTabelaNutricional = v),
                  ),

                  const SizedBox(height: 10),

                  _switchCard(
                    title: "QR Code público",
                    subtitle: _tipoQr == TipoQrEtiqueta.publico
                        ? "Qualquer celular pode abrir a página pública."
                        : "O QR será privado e usado somente no app.",
                    value: _tipoQr == TipoQrEtiqueta.publico,
                    onChanged: (v) {
                      setState(() {
                        _tipoQr =
                            v ? TipoQrEtiqueta.publico : TipoQrEtiqueta.privado;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  CampoCustomSection(
                    campos: _campos,
                    sectionBg: sectionBg,
                    fieldBg: fieldBg,
                    borderColor: border,
                    textColor: text,
                    mutedColor: muted,
                    brandColor: brand,
                    onBrandColor: onBrand,
                    isDark: isDark,
                    onAdd: _adicionarCampo,
                    onEdit: _editarCampo,
                    onRemove: _removerCampo,
                    onReorder: _reordenarCampos,
                    campoTipoLabel: campoTipoLabel,
                    campoTipoHint: campoTipoHint,
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _saving ? null : () => Navigator.pop(context),
                          child: const Text("Cancelar"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _salvar,
                          icon: _saving
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: onBrand,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, color: Colors.white,),
                          label: Text(_saving ? "Salvando..." : "Salvar"),
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
}