// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/categorias_local_provider.dart';
import '../../providers/setores_local_provider.dart';
import '../../providers/tipos_etiqueta_local_provider.dart';
import '../../providers/gerar_etiqueta_local_provider.dart';

import '../../models/tipo_etiqueta_model.dart';
import '../../models/categoria_model.dart';
import '../../models/setor_model.dart';
import '../../models/etiqueta_model.dart';

import '../../data/local/repos/etiquetas_local_repo.dart';
import '../../data/local/repos/etiqueta_template_local_repo.dart';


import '../etiqueta_preview/etiqueta_preview.dart';
import 'package:flutter/services.dart';
import '../../widgets/menu.dart';
import './widgets/app_dropdown.dart';
import './widgets/date_field.dart';
import './widgets/lote_read_only_card.dart';
import './widgets/gerenciar_tipos_card.dart';
import './widgets/criar_etiqueta_form_card.dart';


class TitleCaseFormatter extends TextInputFormatter {
  TitleCaseFormatter({required this.allowed, required this.maxLen});
  final RegExp allowed;
  final int maxLen;

  String _toTitleCase(String input) {
    final cleaned = input.replaceAll(RegExp(r"\s+"), " ").trimLeft();
    final words = cleaned.split(" ");
    final fixed = words.map((w) {
      if (w.isEmpty) return w;
      final lower = w.toLowerCase();
      final first = lower.substring(0, 1).toUpperCase();
      final rest = lower.length > 1 ? lower.substring(1) : "";
      return "$first$rest";
    }).join(" ");
    return fixed;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var t = newValue.text;

    if (t.length > maxLen) t = t.substring(0, maxLen);

  
    final buf = StringBuffer();
    for (final ch in t.characters) {
      if (allowed.hasMatch(ch) || ch == " ") buf.write(ch);
    }
    t = buf.toString();

    t = _toTitleCase(t);

    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

class CriarEtiquetaScreen extends StatefulWidget {
  final String? editarEtiquetaId;
  final String? templateId;

  const CriarEtiquetaScreen({
    super.key,
    this.editarEtiquetaId,
    this.templateId,
  });

  @override
  State<CriarEtiquetaScreen> createState() => _CriarEtiquetaScreenState();
}

class _CriarEtiquetaScreenState extends State<CriarEtiquetaScreen> {
  bool _loaded = false;
  bool _loadedEdit = false;
  bool _loadedTemplate = false;
  final _formKey = GlobalKey<FormState>();
  final _allowedBasic = RegExp(r"^[0-9A-Za-zÀ-ÿçÇ\s]+$");
  

  String? _validateDates(DateTime? fab, DateTime? val) {
    if (fab == null) return "Selecione a data de fabricação.";
    if (val == null) return "Selecione a data de validade.";
    if (val.isBefore(fab)) return "Validade deve ser igual ou após a fabricação.";
    return null;
  }

  InputDecoration appInputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B);
    final fill = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.18);
    final labelColor = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.6);

    const radius = 16.0;

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fill,
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(brand),
      errorBorder: border(Colors.red.withOpacity(0.75)),
      focusedErrorBorder: border(Colors.red),
      labelStyle: TextStyle(
        color: labelColor,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: brand,
        fontWeight: FontWeight.w800,
      ),
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      context.read<CategoriasLocalProvider>().fetch(uid);
      context.read<SetoresLocalProvider>().fetch(uid);
      context.read<TiposEtiquetaLocalProvider>().fetch(uid);
      _loaded = true;
    }
  }

  Future<void> _tryLoadEditIfNeeded({
    required String uid,
    required List<CategoriaModel> cats,
    required List<SetorModel> sets,
    required List<TipoEtiquetaModel> tipos,
  }) async {
    if (_loadedEdit) return;

    if (widget.editarEtiquetaId == null) {
      _loadedEdit = true;
      return;
    }

    if (cats.isEmpty || sets.isEmpty || tipos.isEmpty) return;

    final repo = context.read<EtiquetasLocalRepo>();
    final gerar = context.read<GerarEtiquetaLocalProvider>();

    final e = await repo.getById(uid: uid, id: widget.editarEtiquetaId!);

    if (e == null) {
      _loadedEdit = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Etiqueta para edição não encontrada.")),
      );
      Navigator.pop(context);
      return;
    }

    final categoriaObj = cats.any((c) => c.id == e.categoriaId)
        ? cats.firstWhere((c) => c.id == e.categoriaId)
        : null;

    final setorObj = sets.any((s) => s.id == e.setorId)
        ? sets.firstWhere((s) => s.id == e.setorId)
        : null;

    final tipoAtual = tipos.any((t) => t.id == e.tipoId)
        ? tipos.firstWhere((t) => t.id == e.tipoId)
        : null;

    gerar.loadFromEtiqueta(
      e: e,
      categoriaObj: categoriaObj,
      setorObj: setorObj,
      tipoAtual: tipoAtual,
    );

    _loadedEdit = true;
  }

  Future<void> _tryLoadTemplateIfNeeded({
    required String uid,
    required List<CategoriaModel> cats,
    required List<SetorModel> sets,
    required List<TipoEtiquetaModel> tipos,
  }) async {
    if (_loadedTemplate) return;

    if (widget.templateId == null) {
      _loadedTemplate = true;
      return;
    }

  
    if (widget.editarEtiquetaId != null) {
      _loadedTemplate = true;
      return;
    }

    if (cats.isEmpty || sets.isEmpty || tipos.isEmpty) return;

    final tplRepo = context.read<EtiquetasTemplatesLocalRepo>();
    final gerar = context.read<GerarEtiquetaLocalProvider>();

    final t = await tplRepo.getById(uid: uid, id: widget.templateId!);

    if (t == null) {
      _loadedTemplate = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Modelo diário não encontrado.")),
      );
      Navigator.pop(context);
      return;
    }

    final categoriaObj = cats.any((c) => c.id == t.categoriaId)
        ? cats.firstWhere((c) => c.id == t.categoriaId)
        : null;

    final setorObj = sets.any((s) => s.id == t.setorId)
        ? sets.firstWhere((s) => s.id == t.setorId)
        : null;

    final tipoAtual = tipos.any((x) => x.id == t.tipoId)
        ? tipos.firstWhere((x) => x.id == t.tipoId)
        : null;

    final now = DateTime.now();

    final Map<String, dynamic> safeCampos =
        Map<String, dynamic>.from(t.camposCustomValores);

    safeCampos.putIfAbsent("lote", () => {"label": "Lote", "value": ""});

    final loteStr = (safeCampos["lote"]?["value"] ?? "").toString().trim();
    final String? loteFinal = loteStr.isEmpty ? null : loteStr;


    final fake = EtiquetaModel(
      id: "temp",
      tipoId: t.tipoId,
      tipoNome: t.tipoNome,
      produtoNome: t.produtoNome,
      categoriaId: t.categoriaId,
      categoriaNome: t.categoriaNome,
      setorId: t.setorId,
      setorNome: t.setorNome,
      dataFabricacao: now,
      dataValidade: now, 
      camposCustomValores: t.camposCustomValores,
      lote: loteFinal,
      status: "ativa",
      quantidade: t.quantidadePadrao,
      quantidadeRestante: t.quantidadePadrao,
      statusEstoque: "ativo",
      soldAt: null,
      createdAt: now,
    );

    gerar.resetAll();
    gerar.loadFromEtiqueta(
      e: fake,
      categoriaObj: categoriaObj,
      setorObj: setorObj,
      tipoAtual: tipoAtual,
    );

    if (tipoAtual?.controlaLote == true) {
      gerar.ensureLoteAuto(tipoAtual: tipoAtual!);
    }

    _loadedTemplate = true;
  }

  Future<bool> _confirmSaveWithWarning({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
        final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.75);
        final cancelColor = isDark ? const Color(0xFFD4AF37) : Colors.black.withOpacity(0.85);

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withOpacity(0.15)),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: muted),
          ),
          actions: [
            SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFFD4AF37).withOpacity(0.22)
                        : Colors.black.withOpacity(0.14),
                  ),
                  foregroundColor: cancelColor,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Salvar mesmo assim",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        );
      },
    );
    return ok ?? false;
  }

  @override
Widget build(BuildContext context) {
  debugPrint("templateId: ${widget.templateId} | editarEtiquetaId: ${widget.editarEtiquetaId}");

  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final bg = theme.scaffoldBackgroundColor;
  final softCard = isDark ? const Color(0xFF181818) : const Color(0xFFFDF7ED);
  final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
  final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
  final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
  final onBrand = isDark ? Colors.black : Colors.white;
  final border = isDark
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.07);

  final w = MediaQuery.of(context).size.width;
  final compact = w < 835;

  final uid = context.watch<AuthProvider>().user?.uid;
  if (uid == null) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Text(
          "Faça login novamente.",
          style: TextStyle(color: text),
        ),
      ),
    );
  }

  final cats = context.watch<CategoriasLocalProvider>().items;
  final sets = context.watch<SetoresLocalProvider>().items;
  final tipos = context.watch<TiposEtiquetaLocalProvider>().items;
  final gerar = context.watch<GerarEtiquetaLocalProvider>();

  if (widget.editarEtiquetaId != null) {
    _tryLoadEditIfNeeded(uid: uid, cats: cats, sets: sets, tipos: tipos);
    _loadedTemplate = true;
  } else {
    _tryLoadTemplateIfNeeded(uid: uid, cats: cats, sets: sets, tipos: tipos);
  }

  final bool isEditing = widget.editarEtiquetaId != null;

  final TipoEtiquetaModel? tipoAtual = (gerar.tipoId == null)
      ? null
      : (tipos.any((t) => t.id == gerar.tipoId)
          ? tipos.firstWhere((t) => t.id == gerar.tipoId)
          : null);

  final deveAutoValidade = tipoAtual?.usarRegraValidadeCategoria == true &&
      gerar.categoria != null &&
      gerar.fabricacao != null;

  if (deveAutoValidade) {
    final novaValidade =
        gerar.fabricacao!.add(Duration(days: gerar.categoria!.diasVencimento));

    if (gerar.validade != novaValidade) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<GerarEtiquetaLocalProvider>().setValidadeManual(novaValidade);
      });
    }
  }

  return Scaffold(
    backgroundColor: bg,
    appBar: AppBar(
      backgroundColor: bg,
      elevation: 0,
      toolbarHeight: compact ? 160 : 100,
      centerTitle: true,
      title: compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
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
          child: Column(
            children: [
              GerenciarTiposCard(
                onTap: () => Navigator.pushNamed(context, '/tipos-etiqueta'),
              ),
              const SizedBox(height: 18),
              CriarEtiquetaFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? "Editar etiqueta" : "Gerar etiqueta",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? "Altere os dados e salve as mudanças."
                          : "Selecione o tipo, preencha os dados e gere sua etiqueta.",
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 18),

                    if (tipos.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          "Cadastre um tipo de etiqueta primeiro.",
                          style: TextStyle(color: muted),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: (gerar.tipoId != null && tipos.any((t) => t.id == gerar.tipoId))
                            ? gerar.tipoId
                            : null,
                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        style: TextStyle(color: text),
                        items: tipos
                            .map((t) => DropdownMenuItem<String>(
                                  value: t.id,
                                  child: Text(
                                    t.nome,
                                    style: TextStyle(color: text),
                                  ),
                                ))
                            .toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          final novoTipo = tipos.firstWhere((t) => t.id == id);
                          context.read<GerarEtiquetaLocalProvider>().setTipoId(
                                id,
                                tipoAtual: novoTipo,
                              );
                        },
                        decoration: appInputDecoration("Tipo de etiqueta"),
                      ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: gerar.produtoCtrl,
                      style: TextStyle(color: text),
                      decoration: appInputDecoration("Nome do produto"),
                      inputFormatters: [
                        TitleCaseFormatter(
                          allowed: RegExp(r"[0-9A-Za-zÀ-ÿçÇ]"),
                          maxLen: 40,
                        ),
                      ],
                      validator: (v) {
                        final s = (v ?? "").trim();
                        if (s.isEmpty) return "Informe o nome do produto.";
                        if (!_allowedBasic.hasMatch(s)) {
                          return "Use apenas letras, números, espaços, acentos e ç.";
                        }
                        if (s.length > 40) return "Máximo de 40 caracteres.";
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: gerar.quantidadeCtrl,
                      style: TextStyle(color: text),
                      keyboardType: TextInputType.number,
                      decoration: appInputDecoration("Quantidade"),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (v) {
                        final s = (v ?? "").trim();
                        if (s.isEmpty) return "Informe a quantidade.";
                        final n = int.tryParse(s);
                        if (n == null) return "Quantidade inválida.";
                        if (n <= 0) return "Quantidade deve ser maior que 0.";
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    if (!isEditing)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: brand.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: brand.withOpacity(0.30)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: brand,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Status do estoque: Ativo",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: text,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: (gerar.editingStatusEstoque == null ||
                                gerar.editingStatusEstoque!.isEmpty)
                            ? "ativo"
                            : gerar.editingStatusEstoque,
                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        style: TextStyle(color: text),
                        items: [
                          DropdownMenuItem(
                            value: "ativo",
                            child: Text("Ativo", style: TextStyle(color: text)),
                          ),
                          DropdownMenuItem(
                            value: "vendido",
                            child: Text("Vendido", style: TextStyle(color: text)),
                          ),
                          DropdownMenuItem(
                            value: "cancelado",
                            child: Text("Cancelado", style: TextStyle(color: text)),
                          ),
                        ],
                        onChanged: (v) => context
                            .read<GerarEtiquetaLocalProvider>()
                            .setStatusEstoqueEdicao(v),
                        decoration: appInputDecoration("Status do estoque"),
                      ),

                    const SizedBox(height: 12),

                    Dropdown<CategoriaModel>(
                      label: "Categoria",
                      value: gerar.categoria,
                      items: cats,
                      getLabel: (c) => c.nome,
                      onChanged: (c) => context
                          .read<GerarEtiquetaLocalProvider>()
                          .setCategoria(c, tipoAtual: tipoAtual),
                      emptyHint: "Cadastre categorias na tela Categorias.",
                    ),

                    const SizedBox(height: 12),

                    Dropdown<SetorModel>(
                      label: "Setor/Responsável",
                      value: gerar.setor,
                      items: sets,
                      getLabel: (s) => s.nome,
                      onChanged: (s) =>
                          context.read<GerarEtiquetaLocalProvider>().setSetor(s),
                      emptyHint: "Cadastre setores na tela Setores.",
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DateField(
                            label: "Fabricação",
                            value: gerar.fabricacao,
                            onPick: (d) => context
                                .read<GerarEtiquetaLocalProvider>()
                                .setFabricacao(d, tipoAtual: tipoAtual),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DateField(
                            label: "Validade",
                            value: gerar.validade,
                            onPick: (d) => context
                                .read<GerarEtiquetaLocalProvider>()
                                .setValidadeManual(d),
                          ),
                        ),
                      ],
                    ),

                    if (tipoAtual?.usarRegraValidadeCategoria == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        "A validade é calculada automaticamente pela categoria (você ainda pode ajustar manualmente).",
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    if (tipoAtual?.controlaLote == true) ...[
                      const SizedBox(height: 12),
                      LoteReadOnlyCard(
                        lote: (gerar.camposValores["lote"]?["value"] ?? "").toString(),
                        onRegenerate: () {
                          context.read<GerarEtiquetaLocalProvider>().setCampoValor(
                                key: "lote",
                                label: "Lote",
                                value: "",
                              );
                          context
                              .read<GerarEtiquetaLocalProvider>()
                              .ensureLoteAuto(tipoAtual: tipoAtual!);
                        },
                      ),
                      const SizedBox(height: 6),
                    ],

                    const SizedBox(height: 18),

                    if (tipoAtual != null) ...[
                      Text(
                        "Campos adicionais",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...tipoAtual.camposCustom.map((campo) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCampoDinamico(context, gerar, campo),
                        );
                      }),
                      const SizedBox(height: 6),
                    ],

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: gerar.saving
                            ? null
                            : () async {
                                final okForm = _formKey.currentState?.validate() ?? false;
                                if (!okForm) return;

                                final dateErr =
                                    _validateDates(gerar.fabricacao, gerar.validade);
                                if (dateErr != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(dateErr)),
                                  );
                                  return;
                                }

                                final now = DateTime.now();
                                final val = gerar.validade!;
                                final days = val
                                    .difference(DateTime(now.year, now.month, now.day))
                                    .inDays;

                                if (val.isBefore(DateTime(now.year, now.month, now.day))) {
                                  final go = await _confirmSaveWithWarning(
                                    context: context,
                                    title: "Validade vencida",
                                    message:
                                        "Essa etiqueta ficará com validade no passado. Deseja salvar mesmo assim?",
                                  );
                                  if (!go) return;
                                } else if (days <= 1) {
                                  final go = await _confirmSaveWithWarning(
                                    context: context,
                                    title: "Validade em alerta",
                                    message:
                                        "A validade está muito próxima (até 1 dia). Deseja salvar mesmo assim?",
                                  );
                                  if (!go) return;
                                }

                                final prov = context.read<GerarEtiquetaLocalProvider>();

                                final TipoEtiquetaModel? tipoParaSalvar = tipoAtual;
                                if (tipoParaSalvar == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Selecione o tipo de etiqueta."),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  if (isEditing) {
                                    await prov.salvarEdicao(
                                      uid: uid,
                                      tipoAtual: tipoParaSalvar,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EtiquetaPreviewScreen(
                                          uid: uid,
                                          etiquetaId: widget.editarEtiquetaId!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    final id = await prov.salvarEtiqueta(
                                      uid: uid,
                                      tipoAtual: tipoParaSalvar,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EtiquetaPreviewScreen(
                                          uid: uid,
                                          etiquetaId: id,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll("Exception: ", ""),
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: gerar.saving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: onBrand,
                                ),
                              )
                            : Icon(
                                isEditing
                                    ? Icons.save_outlined
                                    : Icons.local_offer_outlined,
                                color: onBrand,
                              ),
                        label: Text(
                          gerar.saving
                              ? "Salvando..."
                              : (isEditing ? "Salvar alterações" : "Gerar etiqueta"),
                        ),
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
                    const SizedBox(height: 18),
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

  Widget _buildCampoDinamico(
    BuildContext context,
    GerarEtiquetaLocalProvider gerar,
    CampoCustomModel campo,
  ) {
    final label = campo.obrigatorio ? "${campo.label} *" : campo.label;

    switch (campo.tipo) {
      case CampoTipo.multiline: {
        final ctrl = gerar.ctrlFor(
          campo.key,
          initial: (gerar.camposValores[campo.key]?["value"] ?? "").toString(),
        );

        return TextFormField(
          controller: ctrl,
          maxLines: 3,
          decoration: appInputDecoration(label),
          validator: (v) {
            if (campo.obrigatorio && (v ?? "").trim().isEmpty) return "Campo obrigatório.";
            return null;
          },
          onChanged: (v) => context.read<GerarEtiquetaLocalProvider>().setCampoValor(
            key: campo.key, label: campo.label, value: v,
          ),
        );
      }

      case CampoTipo.number: {
        final raw = gerar.camposValores[campo.key]?["value"];
        final ctrl = gerar.ctrlFor(
          campo.key,
          initial: raw == null ? "" : raw.toString(),
        );

        return TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: appInputDecoration(label),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), 
          ],
          validator: (v) {
            if (campo.obrigatorio && (v ?? "").trim().isEmpty) return "Campo obrigatório.";
            final s = (v ?? "").trim();
            if (s.isNotEmpty && int.tryParse(s) == null) return "Número inválido.";
            return null;
          },
          onChanged: (v) => context.read<GerarEtiquetaLocalProvider>().setCampoValor(
            key: campo.key, label: campo.label, value: int.tryParse(v),
          ),
        );
      }

      case CampoTipo.boolType:
        final obj = gerar.camposValores[campo.key];
        final bool boolVal = (obj?["value"] as bool?) ?? false;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.12)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: boolVal,
            activeColor: const Color(0xFF428e2e),
            checkColor: Colors.white,
            title: Text(label),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) => context.read<GerarEtiquetaLocalProvider>().setCampoValor(
              key: campo.key,
              label: campo.label,
              value: v ?? false,
            ),
          ),
        );

      case CampoTipo.date:
        final val = gerar.camposValores[campo.key]?["value"];
        DateTime? dt;
        if (val is DateTime) dt = val;
        if (val is int) dt = DateTime.fromMillisecondsSinceEpoch(val);

        return DateField(
          label: label,
          value: dt,
          onPick: (d) => context.read<GerarEtiquetaLocalProvider>().setCampoValor(
            key: campo.key,
            label: campo.label,
            value: d.millisecondsSinceEpoch,
          ),
        );

      case CampoTipo.text: {
        final ctrl = gerar.ctrlFor(
          campo.key,
          initial: (gerar.camposValores[campo.key]?["value"] ?? "").toString(),
        );

        return TextFormField(
          controller: ctrl,
          decoration: appInputDecoration(label),
          inputFormatters: [
            TitleCaseFormatter(allowed: RegExp(r"[0-9A-Za-zÀ-ÿçÇ]"), maxLen: 40),
          ],
          validator: (v) {
            if (campo.obrigatorio && (v ?? "").trim().isEmpty) return "Campo obrigatório.";
            final s = (v ?? "").trim();
            if (s.isNotEmpty && !_allowedBasic.hasMatch(s)) {
              return "Use apenas letras, números, espaços, acentos e ç.";
            }
            if (s.length > 40) return "Máximo de 40 caracteres.";
            return null;
          },
          onChanged: (v) => context.read<GerarEtiquetaLocalProvider>().setCampoValor(
            key: campo.key, label: campo.label, value: v,
          ),
        );
      }
    }
  }
}

