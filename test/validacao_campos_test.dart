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

  TipoEtiquetaModel tipoPadrao() {
    return TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta Padrão',
      camposCustom: const [],
      usarRegraValidadeCategoria: false,
      controlaLote: false,
      permiteTabelaNutricional: false,
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

    provider.fabricacao = DateTime.now();
    provider.validade = DateTime.now().add(const Duration(days: 3));
  }

  setUp(() {
    provider = GerarEtiquetaProvider(
      firestore: MockFirebaseFirestore(),
      repo: MockEtiquetaRepo(),
      mov: MockMovProvider(),
      templateRepo: MockTemplateRepo(),
    );
  });

  group('Validação da etiqueta', () {
    test('deve aceitar dados válidos', () {
      preencherDadosValidos();

      final erro = provider.validar(tipoPadrao());

      expect(erro, null);
    });

    test('deve exigir tipo de etiqueta', () {
      preencherDadosValidos();

      final erro = provider.validar(null);

      expect(erro, 'Selecione o tipo de etiqueta.');
    });

    test('deve exigir nome do produto', () {
      preencherDadosValidos();
      provider.produtoCtrl.text = '';

      final erro = provider.validar(tipoPadrao());

      expect(erro, 'Informe o nome do produto.');
    });

    test('deve exigir categoria', () {
      preencherDadosValidos();
      provider.categoria = null;

      final erro = provider.validar(tipoPadrao());

      expect(erro, 'Selecione a categoria.');
    });

    test('deve exigir setor', () {
      preencherDadosValidos();
      provider.setor = null;

      final erro = provider.validar(tipoPadrao());

      expect(erro, 'Selecione o setor/responsável.');
    });

    test('deve exigir data de fabricação', () {
      preencherDadosValidos();
      provider.fabricacao = null;

      final erro = provider.validar(tipoPadrao());

      expect(erro, 'Selecione a data de fabricação.');
    });

    test('deve exigir data de validade', () {
      preencherDadosValidos();
      provider.validade = null;

      final erro = provider.validar(tipoPadrao());

      expect(erro, 'Selecione a data de validade.');
    });

    test('deve exigir quantidade válida', () {
      preencherDadosValidos();
      provider.quantidadeCtrl.text = '0';

      final erro = provider.validar(tipoPadrao());

      expect(erro, 'Informe uma quantidade válida.');
    });
  });
}