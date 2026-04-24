import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/design_etiqueta_model.dart';
import '../../models/etiqueta_model.dart';
import '../../models/user_model.dart';

import 'layouts/etiqueta_100x80_layout.dart';
import 'layouts/etiqueta_design_layout.dart';
import 'tspl_text_utils.dart';

class ElginL42NetworkService {
  final String ip;
  final int port;
  final Duration timeout;

  ElginL42NetworkService({
    required this.ip,
    this.port = 9100,
    this.timeout = const Duration(seconds: 5),
  });

  Future<void> sendRaw(String command) async {
    Socket? socket;

    try {
      debugPrint('================ TSPL DEBUG ================');
      debugPrint(command);
      debugPrint('===========================================');

      socket = await Socket.connect(ip, port, timeout: timeout);

      final normalized = '${command
              .replaceAll('\r\n', '\n')
              .replaceAll('\r', '\n')
              .split('\n')
              .map((line) => line.trimRight())
              .where((line) => line.isNotEmpty)
              .join('\r\n')}\r\n';

      debugPrint('================ TSPL NORMALIZED ================');
      debugPrint(normalized);
      debugPrint('=================================================');

      socket.add(ascii.encode(normalized));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e, stack) {
      debugPrint('❌ ERRO AO ENVIAR PARA IMPRESSORA');
      debugPrint('Erro: $e');
      debugPrint('Stack: $stack');
    } finally {
      try {
        await socket?.flush();
      } catch (_) {}

      try {
        await socket?.close();
      } catch (_) {}

      socket?.destroy();
    }
  }

  Future<bool> testConnection() async {
    Socket? socket;

    try {
      socket = await Socket.connect(ip, port, timeout: timeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      await socket?.close();
      socket?.destroy();
    }
  }

  Future<void> avancarEtiqueta() async {
    const tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
PRINT 1,1
''';

    await sendRaw(tspl);
  }

  Future<void> printTeste() async {
    const tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
TEXT 20,30,"3",0,1,1,"TESTE TAGVALIDA"
TEXT 20,70,"2",0,1,1,"ELGIN L42 PRO OK"
PRINT 1,1
''';

    await sendRaw(tspl);
  }

  Future<void> printEtiqueta60x40Compacta({
    required String produto,
    required String validade,
    required String lote,
    required String quantidade,
    required String qrData,
    int copias = 1,
  }) async {
    final safeProduto = cleanTsplText(produto, max: 22);
    final safeValidade = cleanTsplText(validade, max: 18);
    final safeLote = cleanTsplText(lote, max: 18);
    final safeQuantidade = cleanTsplText(quantidade, max: 10);
    final safeQr = cleanQr(qrData);

    final qtdCopias = copias <= 0 ? 1 : copias;

    final tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
TEXT 32,18,"3",0,1,1,"$safeProduto"
TEXT 32,95,"2",0,1,1,"Val: $safeValidade"
TEXT 32,120,"2",0,1,1,"Lote: $safeLote"
TEXT 32,145,"2",0,1,1,"Qtd: $safeQuantidade"
QRCODE 320,22,L,3,A,0,"$safeQr"
PRINT $qtdCopias,1
''';

    await sendRaw(tspl);
  }

  Future<void> printEtiquetaComDesign({
    required DesignEtiquetaModel design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    final command = EtiquetaDesignLayout().build(
      design: design,
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: copias,
    );

    await sendRaw(command);
  }

  Future<void> printEtiqueta100x80ComTabelaNutricional({
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    final command = Etiqueta100x80Layout().build(
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: copias,
    );

    await sendRaw(command);
  }
}