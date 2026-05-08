import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/design_etiqueta_v2_model.dart';
import '../../models/etiqueta_model.dart';
import '../../models/user_model.dart';

import 'layouts_v2/etiqueta_60x40_layout_v2.dart';
import 'layouts_v2/etiqueta_100x80_layout_v2.dart';
import 'layouts_v2/etiqueta_100x80_tabela_layout_v2.dart';

class ElginL42NetworkServiceV2 {
  final String ip;
  final int port;
  final Duration timeout;

  ElginL42NetworkServiceV2({
    required this.ip,
    this.port = 9100,
    this.timeout = const Duration(seconds: 5),
  });

  Future<void> sendRaw(String command) async {
    Socket? socket;

    try {
      debugPrint('================ TSPL V2 DEBUG ================');
      debugPrint(command);
      debugPrint('==============================================');

      socket = await Socket.connect(ip, port, timeout: timeout);

      final normalized = '${command
              .replaceAll('\r\n', '\n')
              .replaceAll('\r', '\n')
              .split('\n')
              .map((line) => line.trimRight())
              .where((line) => line.isNotEmpty)
              .join('\r\n')}\r\n';

      debugPrint('================ TSPL V2 NORMALIZED ================');
      debugPrint(normalized);
      debugPrint('====================================================');

      socket.add(ascii.encode(normalized));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e, stack) {
      debugPrint('❌ ERRO AO ENVIAR PARA IMPRESSORA V2');
      debugPrint('Erro: $e');
      debugPrint('Stack: $stack');
      rethrow;
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

  Future<void> avancarEtiquetaV2() async {
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

  Future<void> printTesteV2() async {
    const tspl = '''
SIZE 60 mm,40 mm
GAP 2 mm,0 mm
DIRECTION 1
REFERENCE 0,0
CLS
TEXT 20,30,"3",0,1,1,"TESTE TAGVALIDA V2"
TEXT 20,70,"2",0,1,1,"ELGIN L42 PRO OK"
PRINT 1,1
''';

    await sendRaw(tspl);
  }

  Future<void> printEtiqueta60x40V2({
    required DesignEtiquetaV2Model design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    final command = Etiqueta60x40LayoutV2().build(
      design: design,
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: copias,
    );

    await sendRaw(command);
  }

  Future<void> printEtiqueta100x80V2({
    required DesignEtiquetaV2Model design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    final command = Etiqueta100x80LayoutV2().build(
      design: design,
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: copias,
    );

    await sendRaw(command);
  }

  Future<void> printEtiqueta100x80ComTabelaNutricionalV2({
    required DesignEtiquetaV2Model design,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    final command = Etiqueta100x80TabelaLayoutV2().build(
      design: design,
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: copias,
    );

    await sendRaw(command);
  }
}