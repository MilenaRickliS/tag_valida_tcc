import 'dart:async';

import '../../data/local/repos/design_etiqueta_v2_local_repo.dart';
import '../../models/etiqueta_model.dart';
import '../../models/printer_config_model.dart';
import '../../models/user_model.dart';
import '../../models/etiqueta_layout_preset.dart';
import '../../models/design_etiqueta_v2_limiter.dart';

import 'elgin_l42_network_service_v2.dart';

class PrinterAppServiceV2 {
  final DesignEtiquetaV2LocalRepo designRepo;

  PrinterAppServiceV2({
    required this.designRepo,
  });

  Future<void> imprimirEtiquetaComDesignV2({
    required String uid,
    required PrinterConfigModel printer,
    required EtiquetaModel etiqueta,
    required UserModel usuario,
    required String qrData,
    required EtiquetaLayoutPreset preset,
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

    final design = await designRepo.loadSavedByTipoId(
      etiqueta.tipoId,
      uid: uid,
      preset: preset,
    );

    if (design == null) {
      throw Exception(
        'Nenhum design V2 salvo foi encontrado para "${etiqueta.tipoNome}" no tamanho ${preset.label}.',
      );
    }

    final validacao = DesignEtiquetaV2Limiter.validate(design);

    if (!validacao.ok) {
      throw Exception(
        validacao.message ?? 'O design V2 salvo é inválido para impressão.',
      );
    }

    final service = ElginL42NetworkServiceV2(
      ip: printer.ip,
      port: printer.porta,
    );

    final connected = await service.testConnection();

    if (!connected) {
      throw Exception(
        'Não foi possível conectar na impressora ${printer.ip}:${printer.porta}',
      );
    }

    final usarTabelaNutricional =
        preset == EtiquetaLayoutPreset.mm100x80 &&
        etiqueta.incluirTabelaNutricional &&
        etiqueta.tabelaNutricional != null;

    if (usarTabelaNutricional) {
      await service.printEtiqueta100x80ComTabelaNutricionalV2(
        design: design,
        etiqueta: etiqueta,
        usuario: usuario,
        qrData: qrData,
        copias: copias,
      );
      return;
    }

    switch (preset) {
      case EtiquetaLayoutPreset.mm60x40:
        await service.printEtiqueta60x40V2(
          design: design,
          etiqueta: etiqueta,
          usuario: usuario,
          qrData: qrData,
          copias: copias,
        );
        return;

      case EtiquetaLayoutPreset.mm100x80:
        await service.printEtiqueta100x80V2(
          design: design,
          etiqueta: etiqueta,
          usuario: usuario,
          qrData: qrData,
          copias: copias,
        );
        return;
    }
  }
}