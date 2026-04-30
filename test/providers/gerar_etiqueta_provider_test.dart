import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tag_valida/providers/gerar_etiqueta_provider.dart';
import 'package:tag_valida/data/local/repos/etiquetas_local_repo.dart';
import 'package:tag_valida/data/local/repos/etiqueta_template_local_repo.dart';
import 'package:tag_valida/providers/estoque_mov_provider.dart';
import 'package:tag_valida/models/tipo_etiqueta_model.dart';
import 'package:tag_valida/models/categoria_model.dart';
import 'package:tag_valida/models/setor_model.dart';
import 'package:tag_valida/models/etiqueta_model.dart';
import 'package:tag_valida/models/etiqueta_template_model.dart';

class MockEtiquetaRepo extends Mock implements EtiquetasLocalRepo {}
class MockTemplateRepo extends Mock implements EtiquetasTemplatesLocalRepo {}
class MockMovProvider extends Mock implements EstoqueMovProvider {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class FakeEtiqueta extends Fake implements EtiquetaModel {}
class FakeEtiquetaTemplate extends Fake implements EtiquetaTemplateModel {}
void main() {
  late MockEtiquetaRepo repo;
  late MockTemplateRepo templateRepo;
  late MockMovProvider mov;
  late MockFirebaseFirestore firestore;
  late GerarEtiquetaProvider provider;

  setUpAll(() {
    registerFallbackValue(FakeEtiqueta());
    registerFallbackValue(FakeEtiquetaTemplate());
  });

  setUp(() {
    repo = MockEtiquetaRepo();
    templateRepo = MockTemplateRepo();
    mov = MockMovProvider();
    firestore = MockFirebaseFirestore();

    provider = GerarEtiquetaProvider(
      firestore: firestore,
      repo: repo,
      mov: mov,
      templateRepo: templateRepo,
    );

    when(() => repo.upsert(any(), any())).thenAnswer((_) async {});
    when(() => templateRepo.upsert(any(), any())).thenAnswer((_) async {});
    when(() => templateRepo.findByKey(
          uid: any(named: 'uid'),
          produtoNome: any(named: 'produtoNome'),
          categoriaId: any(named: 'categoriaId'),
          setorId: any(named: 'setorId'),
        )).thenAnswer((_) async => null);

    when(() => mov.registrarEntrada(
          uid: any(named: 'uid'),
          etiquetaId: any(named: 'etiquetaId'),
          quantidade: any(named: 'quantidade'),
          produtoNome: any(named: 'produtoNome'),
          motivo: any(named: 'motivo'),
        )).thenAnswer((_) async {});
  });

  test('deve criar etiqueta com sucesso', () async {
    // ARRANGE (preparar dados)
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

    final tipo = TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta Padrão',
      camposCustom: [],
      usarRegraValidadeCategoria: false,
      controlaLote: false,
      permiteTabelaNutricional: false,
    );

    // ACT
    final id = await provider.salvarEtiqueta(
      uid: 'user1',
      tipoAtual: tipo,
    );

    // ASSERT
    expect(id, isNotEmpty);

    verify(() => repo.upsert('user1', any())).called(1);
    verify(() => templateRepo.upsert('user1', any())).called(1);

    verify(() => mov.registrarEntrada(
          uid: 'user1',
          etiquetaId: any(named: 'etiquetaId'),
          quantidade: 10,
          produtoNome: 'Pão francês',
          motivo: 'Criação da etiqueta',
        )).called(1);
  });
}