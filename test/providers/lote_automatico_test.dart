import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tag_valida/providers/gerar_etiqueta_provider.dart';
import 'package:tag_valida/providers/estoque_mov_provider.dart';
import 'package:tag_valida/data/local/repos/etiquetas_local_repo.dart';
import 'package:tag_valida/data/local/repos/etiqueta_template_local_repo.dart';
import 'package:tag_valida/models/tipo_etiqueta_model.dart';

class MockEtiquetaRepo extends Mock implements EtiquetasLocalRepo {}
class MockTemplateRepo extends Mock implements EtiquetasTemplatesLocalRepo {}
class MockMovProvider extends Mock implements EstoqueMovProvider {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late GerarEtiquetaProvider provider;

  setUp(() {
    provider = GerarEtiquetaProvider(
      firestore: MockFirebaseFirestore(),
      repo: MockEtiquetaRepo(),
      mov: MockMovProvider(),
      templateRepo: MockTemplateRepo(),
    );
  });

  test('deve gerar lote automático quando o tipo controla lote', () {
    final tipo = TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta com lote',
      camposCustom: const [],
      usarRegraValidadeCategoria: false,
      controlaLote: true,
      permiteTabelaNutricional: false,
    );

    provider.ensureLoteAuto(tipoAtual: tipo);

    final lote = provider.camposValores['lote']?['value']?.toString();

    expect(lote, isNotNull);
    expect(lote, isNotEmpty);
    expect(lote, startsWith('PV-'));
  });

  test('não deve gerar lote quando o tipo não controla lote', () {
    final tipo = TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta sem lote',
      camposCustom: const [],
      usarRegraValidadeCategoria: false,
      controlaLote: false,
      permiteTabelaNutricional: false,
    );

    provider.ensureLoteAuto(tipoAtual: tipo);

    expect(provider.camposValores.containsKey('lote'), false);
  });

  test('não deve substituir lote já existente', () {
    final tipo = TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta com lote',
      camposCustom: const [],
      usarRegraValidadeCategoria: false,
      controlaLote: true,
      permiteTabelaNutricional: false,
    );

    provider.camposValores['lote'] = {
      'label': 'Lote',
      'tipo': 'text',
      'value': 'PV-260430-001',
    };

    provider.ensureLoteAuto(tipoAtual: tipo);

    expect(provider.camposValores['lote']?['value'], 'PV-260430-001');
  });
}