// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/etiqueta_qr.dart';
import '../../services/etiqueta_open_flow.dart';
import '../etiqueta_qr_publico/etiqueta_qr_publico_screen.dart';

class ScannerEtiquetaScreen extends StatefulWidget {
  const ScannerEtiquetaScreen({super.key});

  @override
  State<ScannerEtiquetaScreen> createState() => _ScannerEtiquetaScreenState();
}

class _ScannerEtiquetaScreenState extends State<ScannerEtiquetaScreen> {
  bool _handled = false;

  Future<void> _abrirLinkPublico(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      throw const FormatException('Link inválido');
    }

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      throw const FormatException('Não foi possível abrir o link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ler QR da etiqueta")),
      body: MobileScanner(
        onDetect: (capture) async {
            if (_handled) return;

            final barcode = capture.barcodes.firstOrNull;
            final raw = barcode?.rawValue?.trim();

            if (raw == null || raw.isEmpty) return;

            _handled = true;

            try {
              final parsed = parseEtiquetaQrPayload(raw);

              await openEtiquetaPdfFlow(
                context,
                uid: parsed.uid,
                etiquetaId: parsed.id,
              );

              if (context.mounted) Navigator.pop(context);
            } catch (_) {
              try {
              
                if (raw.startsWith('PUBLICO:')) {
                  final parts = raw.split(':');
                  final uid = parts[1];
                  final id = parts[2];

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EtiquetaPublicaScreen(
                        uid: uid,
                        etiquetaId: id,
                      ),
                    ),
                  );

                  if (context.mounted) Navigator.pop(context);
                  return;
                }

               
                if (raw.startsWith('http')) {
                  await _abrirLinkPublico(raw);

                  if (context.mounted) Navigator.pop(context);
                  return;
                }

                throw const FormatException('QR não reconhecido');
              } catch (e) {
                _handled = false;

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("QR inválido: $raw")),
                );
              }
            }
          },
      ),
    );
  }
}