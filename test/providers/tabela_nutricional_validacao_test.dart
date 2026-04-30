import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tag_valida/providers/gerar_etiqueta_provider.dart';
import 'package:tag_valida/providers/estoque_mov_provider.dart';
import 'package:tag_valida/data/local/repos/etiquetas_local_repo.dart';
import 'package:tag_valida/data/local/repos/etiqueta_template_local_repo.dart';

import 'package:tag_valida/models/tipo_etiqueta_model.dart';
import 'package:tag_valida/models/categoria_model.dart';
import 'package:tag_valida/models/setor_model.dart';

class MockEtiquetaRepo extends Mock implements EtiquetasLocalRepo {}
class MockTemplateRepo extends Mock implements EtiquetasTemplatesLocalRepo {}
class MockMovProvider extends Mock implements EstoqueMovProvider {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late GerarEtiquetaProvider provider;

  TipoEtiquetaModel tipoComTabela() {
    return TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta com tabela',
      camposCustom: const [],
      usarRegraValidadeCategoria: false,
      controlaLote: false,
      permiteTabelaNutricional: true,
    );
  }

  void preencherDadosValidos() {
    provider.tipoId = 'tipo1';
    provider.produtoCtrl.text = 'Pão francês';
    provider.quantidadeCtrl.text = '10';

    provider.categoria = CategoriaModel(
      id: 'cat1',
      nome: 'Pães',
      diasVencimento: 3,
      ativo: true,
    );

    provider.setor = SetorModel(
      id: 'set1',
      nome: 'Produção',
      ativo: true,
    );

    provider.fabricacao = DateTime(2026, 4, 27);
    provider.validade = DateTime(2026, 4, 30);
  }

  void preencherTabelaNutricionalValida() {
    provider.porcoesPorEmbalagemCtrl.text = '10';
    provider.porcaoCtrl.text = '50';
    provider.quantidadeMedidaCtrl.text = '1';
    provider.medidaCaseiraCtrl.text = 'Unidade';
    provider.valorEnergeticoCtrl.text = '120';
    provider.carboidratosCtrl.text = '20';
    provider.acucaresTotaisCtrl.text = '2';
    provider.acucaresAdicionadosCtrl.text = '1';
    provider.proteinasCtrl.text = '5';
    provider.gordurasTotaisCtrl.text = '3';
    provider.gordurasSaturadasCtrl.text = '1';
    provider.gordurasTransCtrl.text = '0';
    provider.fibraAlimentarCtrl.text = '2';
    provider.sodioCtrl.text = '150';
  }

  setUp(() {
    provider = GerarEtiquetaProvider(
      firestore: MockFirebaseFirestore(),
      repo: MockEtiquetaRepo(),
      mov: MockMovProvider(),
      templateRepo: MockTemplateRepo(),
    );

    preencherDadosValidos();
  });

  group('Validação da tabela nutricional', () {
    test('deve exigir porções por embalagem quando tabela estiver ativa', () {
      provider.incluirTabelaNutricional = true;

      final erro = provider.validar(tipoComTabela());

      expect(erro, 'Informe as porções por embalagem.');
    });

    test('deve exigir porção quando porções por embalagem estiver preenchida', () {
      provider.incluirTabelaNutricional = true;
      provider.porcoesPorEmbalagemCtrl.text = '10';

      final erro = provider.validar(tipoComTabela());

      expect(erro, 'Informe a porção da tabela nutricional.');
    });

    test('deve exigir medida caseira quando campos anteriores estiverem preenchidos', () {
      provider.incluirTabelaNutricional = true;
      provider.porcoesPorEmbalagemCtrl.text = '10';
      provider.porcaoCtrl.text = '50';
      provider.quantidadeMedidaCtrl.text = '1';

      final erro = provider.validar(tipoComTabela());

      expect(erro, 'Informe a medida caseira da tabela nutricional.');
    });

    test('deve aceitar tabela nutricional preenchida corretamente', () {
      provider.incluirTabelaNutricional = true;
      preencherTabelaNutricionalValida();

      final erro = provider.validar(tipoComTabela());

      expect(erro, null);
    });

    test('não deve exigir tabela quando incluirTabelaNutricional estiver falso', () {
      provider.incluirTabelaNutricional = false;

      final erro = provider.validar(tipoComTabela());

      expect(erro, null);
    });
  });
}