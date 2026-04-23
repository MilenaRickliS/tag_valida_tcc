// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../models/etiqueta_model.dart';
import '../../../utils/etiqueta_qr.dart';
import '../../../providers/gerar_etiqueta_provider.dart';
import '../../../providers/estoque_mov_provider.dart';
import 'movimentar_estoque_modal.dart';
import 'estoque_mov_service.dart';

class ScannerMovimentacaoScreen extends StatefulWidget {
  const ScannerMovimentacaoScreen({super.key});

  @override
  State<ScannerMovimentacaoScreen> createState() =>
      _ScannerMovimentacaoScreenState();
}

class _ScannerMovimentacaoScreenState extends State<ScannerMovimentacaoScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _loading = false;

  Future<EtiquetaModel?> _buscarEtiqueta({
    required BuildContext context,
    required String uid,
    required String etiquetaId,
  }) async {
    final repo = context.read<GerarEtiquetaProvider>();

    EtiquetaModel? e = await repo.getById(uid: uid, id: etiquetaId);
    return e;
  }

 Future<void> _processarQr(String raw) async {
    if (_handled || _loading) return;

    setState(() {
      _handled = true;
      _loading = true;
    });

    try {
      await _controller.stop();

      
      if (raw.startsWith('PUBLICO:') || raw.startsWith('http')) {
        throw Exception("Este é um QR público. Use o QR privado para movimentar estoque.");
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
        throw Exception("Etiqueta não está ativa.");
      }

      if (etiqueta.statusEstoque != "ativo") {
        throw Exception("Etiqueta sem estoque disponível.");
      }

      final result = await showModalBottomSheet<MovimentacaoEstoqueData>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MovimentarEstoqueModal(
          etiqueta: etiqueta,
        ),
      );

      if (result != null) {
        final etiquetasProv = context.read<GerarEtiquetaProvider>();
        final movProv = context.read<EstoqueMovProvider>();

        final service = EstoqueMovService(
          etiquetasRepo: etiquetasProv,
          movRepo: movProv,
        );

        await service.salvarMovimentacao(
          uid: parsed.uid,
          etiqueta: etiqueta,
          data: result,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Movimentação salva com sucesso."),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
        return;
      }

      _handled = false;
      _loading = false;
      await _controller.start();
      if (mounted) setState(() {});
    } catch (e) {
      _handled = false;
      _loading = false;

      await _controller.start();

      if (!mounted) return;

      String mensagem = "QR inválido para movimentação.";

      final erro = e.toString();

      if (erro.contains("QR público") || erro.contains("público")) {
        mensagem = "Este é um QR público. Use o QR privado para movimentar estoque.";
      } else if (erro.contains("Etiqueta não encontrada")) {
        mensagem = "Etiqueta não encontrada.";
      } else if (erro.contains("não está ativa")) {
        mensagem = "Etiqueta não está ativa.";
      } else if (erro.contains("sem estoque disponível")) {
        mensagem = "Etiqueta sem estoque disponível.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFD4AF37) : const Color(0xFFED7227);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Movimentar estoque"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
              if (raw == null || raw.isEmpty) return;
              await _processarQr(raw);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: accent, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "Escaneie apenas o QR privado da etiqueta.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.30),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}