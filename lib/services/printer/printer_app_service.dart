import 'dart:async';

import '../../data/local/repos/design_etiqueta_local_repo.dart';
import '../../models/etiqueta_model.dart';
import '../../models/printer_config_model.dart';
import '../../models/user_model.dart';
import 'elgin_l42_network_service.dart';
import '../../models/design_limite_model.dart';

class PrinterAppService {
  final DesignEtiquetaLocalRepo designRepo;

  PrinterAppService({
    required this.designRepo,
  });

  Future<void> imprimirEtiquetaComDesign({
    required PrinterConfigModel printer,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    int copias = 1,
  }) async {
    if (!printer.isValida) {
      throw Exception('Configuração da impressora inválida.');
    }

    if (!printer.isNetwork) {
      throw Exception('Tipo de conexão ainda não suportado.');
    }

    if (printer.modelo.trim().toLowerCase() != 'elgin l42 pro') {
      throw Exception('Modelo de impressora não suportado ainda.');
    }

    if (copias <= 0) {
      throw Exception('A quantidade de etiquetas deve ser maior que zero.');
    }

    final design = await designRepo.loadSavedByTipoId(etiqueta.tipoId);

    if (design == null) {
      throw Exception(
        'Nenhum design salvo foi encontrado para o tipo "${etiqueta.tipoNome}".',
      );
    }

    final validacao = DesignEtiquetaLimiter.validate(design);
    if (!validacao.ok) {
      throw Exception(
        validacao.message ?? 'O design salvo é inválido para impressão.',
      );
    }

    final service = ElginL42NetworkService(
      ip: printer.ip,
      port: printer.porta,
    );

    final connected = await service.testConnection();
    if (!connected) {
      throw Exception(
        'Não foi possível conectar na impressora ${printer.ip}:${printer.porta}',
      );
    }

    final is100x80 = _isEtiqueta100x80(
      larguraMm: design.larguraMm,
      alturaMm: design.alturaMm,
    );

    final usarTabelaNutricional =
        is100x80 &&
        etiqueta.incluirTabelaNutricional &&
        etiqueta.tabelaNutricional != null;

    if (usarTabelaNutricional) {
      await service.printEtiqueta100x80ComTabelaNutricional(
        design: design,
        etiqueta: etiqueta,
        usuario: usuario,
        qrData: qrData,
        copias: copias,
      );
      return;
    }

    await service.printEtiquetaComDesign(
      design: design,
      etiqueta: etiqueta,
      usuario: usuario,
      qrData: qrData,
      copias: copias,
    );
  }

  bool _isEtiqueta100x80({
    required double larguraMm,
    required double alturaMm,
  }) {
    return larguraMm >= 99 &&
        larguraMm <= 101 &&
        alturaMm >= 79 &&
        alturaMm <= 81;
  }
}