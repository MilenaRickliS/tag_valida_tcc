// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../providers/tipos_etiqueta_local_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/tipo_etiqueta_model.dart';
import '../../widgets/menu.dart';
import './widgets/tipos_etiqueta_list.dart';
import './widgets/novo_tipo_fab.dart';
import './widgets/campo_custom_section.dart';

final _nomeDeny = FilteringTextInputFormatter.deny(
  RegExp(r"[^0-9A-Za-zÀ-ÖØ-öø-ÿÇç ]"),
);

final _keyDeny = FilteringTextInputFormatter.deny(
  RegExp(r"[^a-zA-Z0-9_]"),
);

class TitleCaseEachWordFormatter extends TextInputFormatter {
  const TitleCaseEachWordFormatter();

  bool _isLetter(String ch) => RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿÇç]").hasMatch(ch);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;

    final lower = t.toLowerCase();
    final chars = lower.split('');

    bool capNext = true;

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];

      if (ch == ' ') {
        capNext = true;
        continue;
      }

      if (capNext && _isLetter(ch)) {
        chars[i] = ch.toUpperCase();
        capNext = false;
      } else {
        capNext = false;
      }
    }

    final formatted = chars.join();

    final sel = newValue.selection;
    final clampedBase = sel.baseOffset.clamp(0, formatted.length);
    final clampedExtent = sel.extentOffset.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection(baseOffset: clampedBase, extentOffset: clampedExtent),
      composing: TextRange.empty,
    );
  }
}

class TiposEtiquetaScreen extends StatefulWidget {
  const TiposEtiquetaScreen({super.key});

  @override
  State<TiposEtiquetaScreen> createState() => _TiposEtiquetaScreenState();
}

class _TiposEtiquetaScreenState extends State<TiposEtiquetaScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      context.read<TiposEtiquetaLocalProvider>().fetch(uid);
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);

    final fabBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final fabFg = brand;
    final fabBorder = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

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

    final prov = context.watch<TiposEtiquetaLocalProvider>();

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
      floatingActionButton: NovoTipoFab(
        isDark: isDark,
        brand: brand,
        backgroundColor: fabBg,
        foregroundColor: fabFg,
        borderColor: fabBorder,
        onPressed: () => _openTipoDialog(context, uid),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tipos de etiqueta",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Crie modelos com campos personalizados para gerar etiquetas rapidamente.",
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 16),
                TiposEtiquetaList(
                  loading: prov.loading,
                  items: prov.items,
                  mutedColor: muted,
                  onEdit: (t) => _openTipoDialog(context, uid, tipo: t),
                  onDelete: (t) => _confirmDelete(context, uid, t),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String uid, TipoEtiquetaModel t) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);

    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.18)),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Excluir tipo?",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: text,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("O tipo:", style: TextStyle(color: muted)),
            const SizedBox(height: 4),
            Text(
              "“${t.nome}”",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Será removido da sua lista de tipos.",
              style: TextStyle(color: muted, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFFD4AF37) : const Color(0xFF2B2B2B),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB00020),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              "Excluir",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<TiposEtiquetaLocalProvider>().delete(uid, t.id);
    }
  }

  Future<void> _openTipoDialog(BuildContext rootContext, String uid, {TipoEtiquetaModel? tipo}) async {
    final isEdit = tipo != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final sectionBg = isDark ? const Color(0xFF181818) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF7F1);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final border = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.08);
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final onBrand = isDark ? Colors.black : Colors.white;

    final nomeCtrl = TextEditingController(text: tipo?.nome ?? "");
    final descCtrl = TextEditingController(text: tipo?.descricao ?? "");
    bool usarRegra = tipo?.usarRegraValidadeCategoria ?? true;
    bool controlaLote = tipo?.controlaLote ?? false;
    bool permiteTabelaNutricional = tipo?.permiteTabelaNutricional ?? false;
    TipoQrEtiqueta tipoQrSelecionado = tipo?.tipoQr ?? TipoQrEtiqueta.privado;
    
    final List<CampoCustomModel> campos = [
      ...(tipo?.camposCustom ?? []),
    ];

    String? erro;

    await showDialog(
      context: rootContext,
      barrierColor: Colors.black.withOpacity(0.35),
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setLocal) {
          return AlertDialog(
            backgroundColor: dialogBg,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: brand.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Icon(Icons.layers_outlined, color: brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEdit ? "Editar tipo" : "Novo tipo",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: text,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (erro != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                        ),
                        child: Text(
                          erro!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: nomeCtrl,
                      style: TextStyle(color: text),
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [
                        const TitleCaseEachWordFormatter(),
                        _nomeDeny,
                        LengthLimitingTextInputFormatter(40),
                      ],
                      decoration: _inputDecoration(
                        isDark: isDark,
                        text: text,
                        border: border,
                        fill: fieldBg,
                        brand: brand,
                        labelText: "Nome",
                        hintText: "Ex: Etiqueta Freezer",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      style: TextStyle(color: text),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        isDark: isDark,
                        text: text,
                        border: border,
                        fill: fieldBg,
                        brand: brand,
                        labelText: "Descrição (opcional)",
                        hintText: "Ex: Modelo para produtos congelados",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: usarRegra
                              ? brand.withOpacity(0.22)
                              : border,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: usarRegra
                            ? brand.withOpacity(0.10)
                            : fieldBg,
                      ),
                      child: SwitchTheme(
                        data: SwitchThemeData(
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) return brand;
                            return null;
                          }),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return brand.withOpacity(0.35);
                            }
                            return null;
                          }),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            "Usar regra de validade da categoria",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                          subtitle: Text(
                            "Se marcado, a validade será calculada com base na categoria.",
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          value: usarRegra,
                          onChanged: (v) => setLocal(() => usarRegra = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controlaLote
                              ? brand.withOpacity(0.22)
                              : border,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: controlaLote
                            ? brand.withOpacity(0.10)
                            : fieldBg,
                      ),
                      child: SwitchTheme(
                        data: SwitchThemeData(
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) return brand;
                            return null;
                          }),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return brand.withOpacity(0.35);
                            }
                            return null;
                          }),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            "Controlar lote",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                          subtitle: Text(
                            "Se marcado, a etiqueta terá um campo de Lote obrigatório (pode gerar automático).",
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          value: controlaLote,
                          onChanged: (v) => setLocal(() => controlaLote = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: permiteTabelaNutricional
                              ? brand.withOpacity(0.22)
                              : border,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: permiteTabelaNutricional
                            ? brand.withOpacity(0.10)
                            : fieldBg,
                      ),
                      child: SwitchTheme(
                        data: SwitchThemeData(
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) return brand;
                            return null;
                          }),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return brand.withOpacity(0.35);
                            }
                            return null;
                          }),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            "Permitir tabela nutricional",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                          subtitle: Text(
                            "Se marcado, este tipo poderá exibir e imprimir tabela nutricional na criação da etiqueta.",
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          value: permiteTabelaNutricional,
                          onChanged: (v) => setLocal(() => permiteTabelaNutricional = v),
                        ),
                      ),
                    ),
                   const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: tipoQrSelecionado == TipoQrEtiqueta.publico
                              ? brand.withOpacity(0.22)
                              : border,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: tipoQrSelecionado == TipoQrEtiqueta.publico
                            ? brand.withOpacity(0.10)
                            : fieldBg,
                      ),
                      child: SwitchTheme(
                        data: SwitchThemeData(
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) return brand;
                            return null;
                          }),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return brand.withOpacity(0.35);
                            }
                            return null;
                          }),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            "QR Code público",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                          subtitle: Text(
                            tipoQrSelecionado == TipoQrEtiqueta.publico
                                ? "Marcado: qualquer celular pode ler e abrir a página pública da etiqueta."
                                : "Desmarcado: o QR será privado e funcionará somente no app.",
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          value: tipoQrSelecionado == TipoQrEtiqueta.publico,
                          onChanged: (v) {
                            setLocal(() {
                              tipoQrSelecionado =
                                  v ? TipoQrEtiqueta.publico : TipoQrEtiqueta.privado;
                            });
                          },
                        ),
                      ),
                    ),
                   const SizedBox(height: 18),
                    CampoCustomSection(
                      campos: campos,
                      sectionBg: sectionBg,
                      fieldBg: fieldBg,
                      borderColor: border,
                      textColor: text,
                      mutedColor: muted,
                      brandColor: brand,
                      onBrandColor: onBrand,
                      isDark: isDark,
                      onAdd: () async {
                        final novo = await _openCampoDialog(rootContext, campo: null);
                        if (novo != null && dialogContext.mounted) {
                          setLocal(() => campos.add(novo));
                        }
                      },
                      onEdit: (index, campo) async {
                        final editado = await _openCampoDialog(rootContext, campo: campo);
                        if (editado != null && dialogContext.mounted) {
                          setLocal(() => campos[index] = editado);
                        }
                      },
                      onRemove: (index) {
                        if (dialogContext.mounted) {
                          setLocal(() => campos.removeAt(index));
                        }
                      },
                      onReorder: (oldIndex, newIndex) {
                        if (!dialogContext.mounted) return;
                        setLocal(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = campos.removeAt(oldIndex);
                          campos.insert(newIndex, item);
                        });
                      },
                      campoTipoLabel: _campoTipoLabel,
                      campoTipoHint: _campoTipoHint,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? brand : const Color(0xFF2B2B2B),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand,
                  foregroundColor: onBrand,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final rawNome = nomeCtrl.text;
                  final nome = rawNome.trim().replaceAll(RegExp(r"\s+"), " ");
                  final desc = descCtrl.text.trim();

                  final msg = _validarTipo(nome, campos);
                  if (msg != null) {
                    setLocal(() => erro = msg);
                    return;
                  }

                  final novoTipo = TipoEtiquetaModel(
                    id: tipo?.id ?? "",
                    nome: nome,
                    descricao: desc.isEmpty ? null : desc,
                    usarRegraValidadeCategoria: usarRegra,
                    controlaLote: controlaLote,
                    permiteTabelaNutricional: permiteTabelaNutricional,
                    camposCustom: campos,
                    tipoQr: tipoQrSelecionado, 
                  );

                  final prov = context.read<TiposEtiquetaLocalProvider>();

                  if (isEdit) {
                    await prov.update(uid, novoTipo);
                  } else {
                    await prov.create(uid, novoTipo);
                  }

                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: Text(
                  isEdit ? "Salvar" : "Criar",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String? _validarTipo(String nome, List<CampoCustomModel> campos) {
    if (nome.isEmpty) return "Informe o nome do tipo.";

    final nomeOk = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿÇç0-9 ]+$").hasMatch(nome);
    if (!nomeOk) return "Nome inválido. Use apenas letras, números e espaços.";

    if (nome.length > 40) return "O nome deve ter no máximo 40 caracteres.";

    final set = <String>{};
    for (final c in campos) {
      if (c.key.trim().isEmpty) return "Existe um campo com chave vazia.";
      if (c.label.trim().isEmpty) return "Existe um campo com nome (label) vazio.";
      if (set.contains(c.key.trim())) return "Chave duplicada: ${c.key}.";
      set.add(c.key.trim());
    }
    return null;
  }

  String _removeDiacritics(String s) {
    const from = 'áàãâäéèêëíìîïóòõôöúùûüçñÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑ';
    const to   = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
    for (int i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    return s;
  }

  String _makeKeyFromLabel(String label) {
    var s = label.trim().toLowerCase();
    s = _removeDiacritics(s);
    s = s.replaceAll(RegExp(r'[^a-z0-9_\s]'), '');
    s = s.replaceAll(RegExp(r'\s+'), '_');
    s = s.replaceAll(RegExp(r'_+'), '_');
    s = s.replaceAll(RegExp(r'^_+|_+$'), '');
    return s;
  }

 Future<CampoCustomModel?> _openCampoDialog(
  BuildContext context, {
  CampoCustomModel? campo,
}) async {
  final isEdit = campo != null;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final fieldBg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF7F1);
  final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
  final muted =
      isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
  final border = isDark
      ? const Color(0xFFD4AF37).withOpacity(0.16)
      : Colors.black.withOpacity(0.08);
  final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
  final onBrand = isDark ? Colors.black : Colors.white;

  final labelCtrl = TextEditingController(text: campo?.label ?? "");
  final keyCtrl = TextEditingController(text: campo?.key ?? "");

  CampoTipo tipo = campo?.tipo ?? CampoTipo.text;
  bool obrigatorio = campo?.obrigatorio ?? false;

  String unidadeSelecionada = campo?.unidadePadrao ?? '';
  String outroSimbolo = '';
  String? prefixo = campo?.prefixo;
  String? sufixo = campo?.sufixo;
  CampoPosicaoSimbolo posicaoSimbolo =
      campo?.posicaoSimbolo ?? CampoPosicaoSimbolo.none;
  int casasDecimais = campo?.casasDecimais ?? 2;

  final List<String> modosDisponiveisBase = ['kg', 'un', 'cx', 'pct'];
  List<String> opcoesModoPreco = [...(campo?.opcoesModoPreco ?? const [])];
  String modoPrecoPadrao = campo?.modoPrecoPadrao ?? 'kg';

  const unidadesBase = [
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

  String? erro;
  CampoCustomModel? result;

  final bool keyLocked = isEdit;
  bool userEditedKey = isEdit;

  void syncKeyFromLabel() {
    if (keyLocked) return;
    if (userEditedKey) return;

    final generated = _makeKeyFromLabel(labelCtrl.text);
    if (keyCtrl.text != generated) {
      keyCtrl.text = generated;
    }
  }

  void aplicarSimboloConfig() {
    final simbolo = unidadeSelecionada == '__outro__'
        ? outroSimbolo.trim()
        : unidadeSelecionada.trim();

    if (tipo == CampoTipo.priceMode) {
      prefixo = 'R\$ ';
      sufixo = null;
      return;
    }

    if (tipo == CampoTipo.currency) {
      if (posicaoSimbolo == CampoPosicaoSimbolo.prefix) {
        prefixo = simbolo.isEmpty ? 'R\$ ' : '$simbolo ';
        sufixo = null;
      } else if (posicaoSimbolo == CampoPosicaoSimbolo.suffix) {
        prefixo = null;
        sufixo = simbolo.isEmpty ? null : ' $simbolo';
      } else {
        prefixo = 'R\$ ';
        sufixo = null;
      }
      return;
    }

    if (tipo == CampoTipo.integer || tipo == CampoTipo.decimal) {
      if (posicaoSimbolo == CampoPosicaoSimbolo.prefix) {
        prefixo = simbolo.isEmpty ? null : '$simbolo ';
        sufixo = null;
      } else if (posicaoSimbolo == CampoPosicaoSimbolo.suffix) {
        prefixo = null;
        sufixo = simbolo.isEmpty ? null : ' $simbolo';
      } else {
        prefixo = null;
        sufixo = null;
      }
      return;
    }

    prefixo = null;
    sufixo = null;
  }

  String formatarExemploNumero() {
    switch (casasDecimais) {
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

  String buildPreview() {
    final exemploNumero = formatarExemploNumero();

    if (tipo == CampoTipo.priceMode) {
      final modo = opcoesModoPreco.isNotEmpty ? modoPrecoPadrao : 'kg';
      return 'R\$ $exemploNumero/$modo';
    }

    if (tipo == CampoTipo.currency ||
        tipo == CampoTipo.integer ||
        tipo == CampoTipo.decimal) {
      final p = prefixo ?? '';
      final s = sufixo ?? '';
      return '$p$exemploNumero$s'.trim();
    }

    switch (tipo) {
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

  void labelListener() => syncKeyFromLabel();
  labelCtrl.addListener(labelListener);

  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => StatefulBuilder(
      builder: (context, setLocal) {
        final previewKey = _makeKeyFromLabel(labelCtrl.text);

        return AlertDialog(
          backgroundColor: dialogBg,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: brand.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Icon(Icons.tune, color: brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEdit ? "Editar campo" : "Adicionar campo",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (erro != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        erro!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: labelCtrl,
                    style: TextStyle(color: text),
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: const [
                      TitleCaseEachWordFormatter(),
                    ],
                    decoration: _inputDecoration(
                      isDark: isDark,
                      text: text,
                      border: border,
                      fill: fieldBg,
                      brand: brand,
                      labelText: "Nome do campo (Label)",
                      hintText: "Ex: Preço de venda",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Label é o nome que aparece na etiqueta.",
                      style: TextStyle(color: muted, fontSize: 12.5),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: keyCtrl,
                    style: TextStyle(color: text),
                    readOnly: keyLocked,
                    inputFormatters: keyLocked ? null : [_keyDeny],
                    onChanged: (_) {
                      if (!keyLocked && !userEditedKey) {
                        setLocal(() => userEditedKey = true);
                      }
                    },
                    decoration: _inputDecoration(
                      isDark: isDark,
                      text: text,
                      border: border,
                      fill: fieldBg,
                      brand: brand,
                      labelText: "Chave (Key) — sem espaços",
                      hintText: "Ex: preco_venda",
                      helperText: keyLocked
                          ? "A key não pode ser alterada depois de criada."
                          : (userEditedKey
                              ? "Editada manualmente."
                              : "Gerada automaticamente pelo Label."),
                      prefixIcon: Icon(
                        keyLocked ? Icons.lock_outline : Icons.key_outlined,
                        color: keyLocked ? muted : brand,
                      ),
                      suffixIcon: (!keyLocked && userEditedKey)
                          ? IconButton(
                              tooltip: "Voltar a gerar automaticamente",
                              onPressed: () {
                                setLocal(() {
                                  userEditedKey = false;
                                  syncKeyFromLabel();
                                });
                              },
                              icon:
                                  Icon(Icons.auto_fix_high, color: brand),
                            )
                          : IconButton(
                              tooltip: "Copiar key",
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: keyCtrl.text.trim()),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Key copiada."),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.copy_outlined,
                                color: isDark ? brand : null,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Preview da key: $previewKey",
                      style: TextStyle(color: muted, fontSize: 12.5),
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<CampoTipo>(
                    value: tipo,
                    dropdownColor: dialogBg,
                    style: TextStyle(color: text),
                    decoration: _inputDecoration(
                      isDark: isDark,
                      text: text,
                      border: border,
                      fill: fieldBg,
                      brand: brand,
                      labelText: "Tipo do campo",
                    ),
                    items: [
                      DropdownMenuItem(
                        value: CampoTipo.text,
                        child: Text("Texto", style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.integer,
                        child: Text("Número inteiro",
                            style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.decimal,
                        child: Text("Número decimal",
                            style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.currency,
                        child: Text("Moeda", style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.priceMode,
                        child: Text("Preço por modo",
                            style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.multiline,
                        child: Text("Texto grande",
                            style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.date,
                        child: Text("Data", style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.boolType,
                        child: Text("Sim/Não", style: TextStyle(color: text)),
                      ),
                      DropdownMenuItem(
                        value: CampoTipo.image,
                        child: Text("Imagem", style: TextStyle(color: text)),
                      ),
                    ],
                    onChanged: (v) {
                      setLocal(() {
                        tipo = v ?? CampoTipo.text;

                        if (tipo == CampoTipo.currency) {
                          unidadeSelecionada =
                              unidadeSelecionada.isEmpty ? 'R\$' : unidadeSelecionada;
                          posicaoSimbolo = CampoPosicaoSimbolo.prefix;
                        }

                        if (tipo == CampoTipo.priceMode) {
                          if (opcoesModoPreco.isEmpty) {
                            opcoesModoPreco = ['kg', 'un'];
                          }
                          if (!opcoesModoPreco.contains(modoPrecoPadrao)) {
                            modoPrecoPadrao = opcoesModoPreco.first;
                          }
                        }

                        aplicarSimboloConfig();
                      });
                    },
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Como será preenchido: ${_campoTipoHint(tipo)}",
                      style: TextStyle(color: muted, fontSize: 12.5),
                    ),
                  ),

                  if (tipo == CampoTipo.integer ||
                      tipo == CampoTipo.decimal ||
                      tipo == CampoTipo.currency) ...[
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: unidadesBase.contains(unidadeSelecionada)
                          ? unidadeSelecionada
                          : '__outro__',
                      dropdownColor: dialogBg,
                      style: TextStyle(color: text),
                      decoration: _inputDecoration(
                        isDark: isDark,
                        text: text,
                        border: border,
                        fill: fieldBg,
                        brand: brand,
                        labelText: "Unidade / símbolo",
                      ),
                      items: [
                        DropdownMenuItem(
                            value: '',
                            child: Text('Nenhum',
                                style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'R\$',
                            child:
                                Text('R\$', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'kg',
                            child: Text('kg', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'g',
                            child: Text('g', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'mg',
                            child: Text('mg', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'l',
                            child: Text('l', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'ml',
                            child: Text('ml', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'mm',
                            child: Text('mm', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'cm',
                            child: Text('cm', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'm',
                            child: Text('m', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'un',
                            child: Text('un', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'pct',
                            child:
                                Text('pct', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: 'cx',
                            child: Text('cx', style: TextStyle(color: text))),
                        DropdownMenuItem(
                            value: '__outro__',
                            child: Text('Outro',
                                style: TextStyle(color: text))),
                      ],
                      onChanged: (v) {
                        setLocal(() {
                          unidadeSelecionada = v ?? '';
                          if (unidadeSelecionada != '__outro__') {
                            outroSimbolo = '';
                          }
                          aplicarSimboloConfig();
                        });
                      },
                    ),

                    if (unidadeSelecionada == '__outro__') ...[
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(color: text),
                        controller:
                            TextEditingController(text: outroSimbolo)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: outroSimbolo.length),
                              ),
                        onChanged: (v) {
                          setLocal(() {
                            outroSimbolo = v;
                            aplicarSimboloConfig();
                          });
                        },
                        decoration: _inputDecoration(
                          isDark: isDark,
                          text: text,
                          border: border,
                          fill: fieldBg,
                          brand: brand,
                          labelText: "Outro símbolo",
                          hintText: "Ex: /kg, caixa, pacote",
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    DropdownButtonFormField<CampoPosicaoSimbolo>(
                      value: posicaoSimbolo,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: text),
                      decoration: _inputDecoration(
                        isDark: isDark,
                        text: text,
                        border: border,
                        fill: fieldBg,
                        brand: brand,
                        labelText: "Posição",
                      ),
                      items: [
                        DropdownMenuItem(
                          value: CampoPosicaoSimbolo.none,
                          child: Text("Sem símbolo",
                              style: TextStyle(color: text)),
                        ),
                        DropdownMenuItem(
                          value: CampoPosicaoSimbolo.prefix,
                          child:
                              Text("Antes", style: TextStyle(color: text)),
                        ),
                        DropdownMenuItem(
                          value: CampoPosicaoSimbolo.suffix,
                          child:
                              Text("Depois", style: TextStyle(color: text)),
                        ),
                      ],
                      onChanged: (v) {
                        setLocal(() {
                          posicaoSimbolo =
                              v ?? CampoPosicaoSimbolo.none;
                          aplicarSimboloConfig();
                        });
                      },
                    ),

                    if (tipo == CampoTipo.decimal ||
                        tipo == CampoTipo.currency) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: casasDecimais,
                        dropdownColor: dialogBg,
                        style: TextStyle(color: text),
                        decoration: _inputDecoration(
                          isDark: isDark,
                          text: text,
                          border: border,
                          fill: fieldBg,
                          brand: brand,
                          labelText: "Casas decimais",
                        ),
                        items: [0, 1, 2, 3]
                            .map(
                              (n) => DropdownMenuItem(
                                value: n,
                                child:
                                    Text("$n", style: TextStyle(color: text)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setLocal(() {
                            casasDecimais = v ?? 2;
                          });
                        },
                      ),
                    ],
                  ],

                  if (tipo == CampoTipo.priceMode) ...[
                    const SizedBox(height: 12),
                    Container(
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
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: modosDisponiveisBase.map((modo) {
                              final selected =
                                  opcoesModoPreco.contains(modo);
                              return FilterChip(
                                label: Text(modo),
                                selected: selected,
                                onSelected: (value) {
                                  setLocal(() {
                                    if (value) {
                                      if (!opcoesModoPreco.contains(modo)) {
                                        opcoesModoPreco.add(modo);
                                      }
                                    } else {
                                      opcoesModoPreco.remove(modo);
                                    }

                                    if (opcoesModoPreco.isEmpty) {
                                      modoPrecoPadrao = 'kg';
                                    } else if (!opcoesModoPreco
                                        .contains(modoPrecoPadrao)) {
                                      modoPrecoPadrao =
                                          opcoesModoPreco.first;
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: opcoesModoPreco.contains(modoPrecoPadrao)
                          ? modoPrecoPadrao
                          : (opcoesModoPreco.isNotEmpty
                              ? opcoesModoPreco.first
                              : 'kg'),
                      dropdownColor: dialogBg,
                      style: TextStyle(color: text),
                      decoration: _inputDecoration(
                        isDark: isDark,
                        text: text,
                        border: border,
                        fill: fieldBg,
                        brand: brand,
                        labelText: "Modo padrão",
                      ),
                      items: (opcoesModoPreco.isEmpty
                              ? ['kg']
                              : opcoesModoPreco)
                          .map(
                            (modo) => DropdownMenuItem(
                              value: modo,
                              child: Text(modo,
                                  style: TextStyle(color: text)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setLocal(() {
                          modoPrecoPadrao = v ?? 'kg';
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: casasDecimais,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: text),
                      decoration: _inputDecoration(
                        isDark: isDark,
                        text: text,
                        border: border,
                        fill: fieldBg,
                        brand: brand,
                        labelText: "Casas decimais",
                      ),
                      items: [0, 1, 2, 3]
                          .map(
                            (n) => DropdownMenuItem(
                              value: n,
                              child:
                                  Text("$n", style: TextStyle(color: text)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setLocal(() {
                          casasDecimais = v ?? 2;
                        });
                      },
                    ),
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
                          buildPreview(),
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

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: obrigatorio
                            ? brand.withOpacity(0.22)
                            : border,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      color: obrigatorio
                          ? brand.withOpacity(0.10)
                          : fieldBg,
                    ),
                    child: SwitchTheme(
                      data: SwitchThemeData(
                        thumbColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return brand;
                          }
                          return null;
                        }),
                        trackColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return brand.withOpacity(0.35);
                          }
                          return null;
                        }),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          "Campo obrigatório",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        subtitle: Text(
                          "Se ativo, a etiqueta só salva se este campo estiver preenchido.",
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                        value: obrigatorio,
                        onChanged: (v) => setLocal(() => obrigatorio = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? brand : const Color(0xFF2B2B2B),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Cancelar",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brand,
                foregroundColor: onBrand,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                final label = labelCtrl.text.trim();

                if (!keyLocked && !userEditedKey) {
                  final generated = _makeKeyFromLabel(label);
                  keyCtrl.text = generated;
                }

                final key = keyCtrl.text.trim();
                final keyOk = RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(key);

                if (label.isEmpty) {
                  setLocal(() => erro = "Informe o nome do campo (label).");
                  return;
                }
                if (key.isEmpty) {
                  setLocal(() =>
                      erro = "A key ficou vazia. Ajuste o label ou edite a key.");
                  return;
                }
                if (!keyOk) {
                  setLocal(() => erro =
                      "A key deve conter apenas letras, números e _ (sem espaços/acentos).");
                  return;
                }

                if (tipo == CampoTipo.priceMode && opcoesModoPreco.isEmpty) {
                  setLocal(() => erro =
                      "Selecione pelo menos um modo de preço.");
                  return;
                }

                final unidadeFinal = unidadeSelecionada == '__outro__'
                    ? outroSimbolo.trim()
                    : unidadeSelecionada.trim();

                result = CampoCustomModel(
                  key: key,
                  label: label,
                  tipo: tipo,
                  obrigatorio: obrigatorio,
                  prefixo: prefixo,
                  sufixo: sufixo,
                  unidadePadrao:
                      unidadeFinal.isEmpty ? null : unidadeFinal,
                  opcoesUnidade: unidadeFinal.isEmpty
                      ? const []
                      : [unidadeFinal],
                  permitirUnidadeCustom:
                      unidadeSelecionada == '__outro__',
                  posicaoSimbolo: posicaoSimbolo,
                  casasDecimais: casasDecimais,
                  habilitarModoPreco: tipo == CampoTipo.priceMode,
                  opcoesModoPreco:
                      tipo == CampoTipo.priceMode ? opcoesModoPreco : const [],
                  modoPrecoPadrao:
                      tipo == CampoTipo.priceMode ? modoPrecoPadrao : null,
                );

                Navigator.pop(context);
              },
              child: Text(
                isEdit ? "Salvar" : "Adicionar",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    ),
  );

  labelCtrl.removeListener(labelListener);
  labelCtrl.dispose();
  keyCtrl.dispose();

  return result;
}

 String _campoTipoLabel(CampoTipo t) {
  switch (t) {
    case CampoTipo.text:
      return "Texto";
    case CampoTipo.integer:
      return "Número inteiro";
    case CampoTipo.decimal:
      return "Número decimal";
    case CampoTipo.currency:
      return "Moeda";
    case CampoTipo.priceMode:
      return "Preço por modo";
    case CampoTipo.multiline:
      return "Texto grande";
    case CampoTipo.date:
      return "Data";
    case CampoTipo.boolType:
      return "Sim/Não";
    case CampoTipo.image:
      return "Imagem";
  }
}

String _campoTipoHint(CampoTipo t) {
  switch (t) {
    case CampoTipo.text:
      return "Campo simples (ex: Lote, Marca)";
    case CampoTipo.integer:
      return "Somente números inteiros (ex: Quantidade, Unidades)";
    case CampoTipo.decimal:
      return "Números com casas decimais (ex: Peso, Volume)";
    case CampoTipo.currency:
      return "Valor em dinheiro (ex: R\$ 20,00)";
    case CampoTipo.priceMode:
      return "Preço com modo selecionável (ex: R\$ 20,00/kg ou R\$ 20,00/un)";
    case CampoTipo.multiline:
      return "Texto com mais linhas (ex: Observações)";
    case CampoTipo.date:
      return "Selecionador de data";
    case CampoTipo.boolType:
      return "Alternância Sim/Não";
    case CampoTipo.image:
      return "Permite enviar uma imagem.";
  }
}

  InputDecoration _inputDecoration({
    required bool isDark,
    required Color text,
    required Color border,
    required Color fill,
    required Color brand,
    required String labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final labelColor = isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.6);

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      helperStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: labelColor),
      labelStyle: TextStyle(
        color: labelColor,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: brand,
        fontWeight: FontWeight.w800,
      ),
      filled: true,
      fillColor: fill,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: brand, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

