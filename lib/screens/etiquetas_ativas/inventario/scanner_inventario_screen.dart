// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:tag_valida/providers/gerar_etiqueta_provider.dart';

import '../../../models/etiqueta_model.dart';
import '../../../utils/etiqueta_qr.dart';
import 'inventario_resumo_screen.dart';

class InventarioItemLido {
  final String etiquetaId;
  final String produtoNome;
  final String setorNome;
  final String categoriaNome;
  final num quantidade;

  const InventarioItemLido({
    required this.etiquetaId,
    required this.produtoNome,
    required this.setorNome,
    required this.categoriaNome,
    required this.quantidade,
  });
}

class InventarioResumo {
  final int etiquetasLidas;
  final num totalItens;
  final Map<String, num> totalPorSetor;
  final Map<String, num> totalPorCategoria;
  final List<InventarioItemLido> itens;

  const InventarioResumo({
    required this.etiquetasLidas,
    required this.totalItens,
    required this.totalPorSetor,
    required this.totalPorCategoria,
    required this.itens,
  });
}

class ScannerInventarioScreen extends StatefulWidget {
  const ScannerInventarioScreen({super.key});

  @override
  State<ScannerInventarioScreen> createState() => _ScannerInventarioScreenState();
}

class _ScannerInventarioScreenState extends State<ScannerInventarioScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final AudioPlayer _player = AudioPlayer();

  bool _loading = false;
  final Map<String, InventarioItemLido> _lidos = {};

  DateTime? _ultimoToastAt;
  String? _ultimaMensagem;
  String? _ultimoRawLido;
  DateTime? _ultimoRawAt;

  void _mostrarMensagem(
    String mensagem, {
    bool erro = false,
  }) {
    if (!mounted) return;

    final agora = DateTime.now();

    final repetidaRecente = _ultimaMensagem == mensagem &&
        _ultimoToastAt != null &&
        agora.difference(_ultimoToastAt!).inMilliseconds < 1800;

    if (repetidaRecente) return;

    _ultimaMensagem = mensagem;
    _ultimoToastAt = agora;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: erro ? Colors.red : null,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 110,
            left: 16,
            right: 16,
          ),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  Future<EtiquetaModel?> _buscarEtiqueta({
    required BuildContext context,
    required String uid,
    required String etiquetaId,
  }) async {
    final etiquetasProv = context.read<GerarEtiquetaProvider>();

    EtiquetaModel? e = await etiquetasProv.getById(uid: uid, id: etiquetaId);
    return e;
  }

  Future<void> _bip() async {
    try {
      await _player.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {}
  }

  Future<void> _processarQr(String raw) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      if (raw.startsWith('PUBLICO:') || raw.startsWith('http')) {
        throw Exception("Use o QR privado no inventário.");
      }

      final parsed = parseEtiquetaQrPayload(raw);

      final etiqueta = await _buscarEtiqueta(
        context: context,
        uid: parsed.uid,
        etiquetaId: parsed.id,
      );

      if (etiqueta == null) {
        throw Exception("Etiqueta não encontrada.");
      }

      if (etiqueta.status != "ativa") {
        throw Exception("Etiqueta inativa.");
      }

      if (etiqueta.statusEstoque != "ativo") {
        throw Exception("Etiqueta sem estoque disponível.");
      }

      if (_lidos.containsKey(etiqueta.id)) {
       _mostrarMensagem("Essa etiqueta já foi lida neste inventário.");
        return;
      }

      final item = InventarioItemLido(
        etiquetaId: etiqueta.id,
        produtoNome: etiqueta.produtoNome,
        setorNome: etiqueta.setorNome.trim().isEmpty ? "Sem setor" : etiqueta.setorNome,
        categoriaNome: etiqueta.categoriaNome.trim().isEmpty
            ? "Sem categoria"
            : etiqueta.categoriaNome,
        quantidade: etiqueta.quantidadeRestante,
      );

      setState(() {
        _lidos[etiqueta.id] = item;
      });

      await _bip();

     _mostrarMensagem("${item.produtoNome} adicionado (${item.quantidade}).");
    } catch (e) {
        String mensagem = "QR inválido para inventário.";

        final erro = e.toString();

        if (erro.contains("QR privado")) {
          mensagem = "Use o QR privado no inventário.";
        } else if (erro.contains("Etiqueta não encontrada")) {
          mensagem = "Etiqueta não encontrada.";
        } else if (erro.contains("Etiqueta inativa")) {
          mensagem = "Etiqueta inativa.";
        } else if (erro.contains("sem estoque disponível")) {
          mensagem = "Etiqueta sem estoque disponível.";
        }

        _mostrarMensagem(mensagem, erro: true);

      
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  InventarioResumo _gerarResumo() {
    final itens = _lidos.values.toList();

    final Map<String, num> porSetor = {};
    final Map<String, num> porCategoria = {};
    num total = 0;

    for (final item in itens) {
      total += item.quantidade;
      porSetor[item.setorNome] = (porSetor[item.setorNome] ?? 0) + item.quantidade;
      porCategoria[item.categoriaNome] =
          (porCategoria[item.categoriaNome] ?? 0) + item.quantidade;
    }

    return InventarioResumo(
      etiquetasLidas: itens.length,
      totalItens: total,
      totalPorSetor: porSetor,
      totalPorCategoria: porCategoria,
      itens: itens,
    );
  }

  Future<void> _finalizarInventario() async {
    if (_lidos.isEmpty) {
      _mostrarMensagem("Nenhuma etiqueta foi lida ainda.", erro: true);
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    await _controller.stop();

    final resumo = _gerarResumo();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventarioResumoScreen(resumo: resumo),
      ),
    );

    await _controller.start();
  }

  void _limparSessao() {
    setState(() {
      _lidos.clear();
    });


    _mostrarMensagem("Sessão de inventário limpa.");

  }

 @override
  void dispose() {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227);
    final itens = _lidos.values.toList().reversed.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Inventário"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Limpar sessão",
            onPressed: _lidos.isEmpty ? null : _limparSessao,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          IconButton(
            tooltip: "Finalizar",
            onPressed: _finalizarInventario,
            icon: const Icon(Icons.checklist_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
              if (raw == null || raw.isEmpty) return;

              final agora = DateTime.now();
              final repetidoMuitoRapido = _ultimoRawLido == raw &&
                  _ultimoRawAt != null &&
                  agora.difference(_ultimoRawAt!).inMilliseconds < 1200;

              if (repetidoMuitoRapido) return;

              _ultimoRawLido = raw;
              _ultimoRawAt = agora;

              await _processarQr(raw);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: accent, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 160,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.76),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    "Etiquetas lidas: ${_lidos.length}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Escaneie apenas QR privado. A mesma etiqueta não conta duas vezes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 40,
              child: ElevatedButton.icon(
                onPressed: _finalizarInventario,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text("Finalizar inventário"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
         Positioned(
          left: 16,
          right: 16,
          bottom: 240,
          child: SizedBox(
            height: 220,
            child: itens.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.74),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListView.separated(
                      itemCount: itens.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final item = itens[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.produtoNome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${item.setorNome} • ${item.categoriaNome}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.quantidade.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.20),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}