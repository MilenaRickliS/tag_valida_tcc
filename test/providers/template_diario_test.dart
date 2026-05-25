import 'package:flutter_test/flutter_test.dart';
import 'package:tag_valida/providers/gerar_etiqueta_local_provider.dart';
import 'package:tag_valida/models/tipo_etiqueta_model.dart';
import 'package:tag_valida/models/categoria_model.dart';
import 'package:tag_valida/models/setor_model.dart';
import 'package:tag_valida/models/etiqueta_template_model.dart';
import 'package:tag_valida/data/local/repos/etiquetas_local_repo.dart';
import 'package:tag_valida/data/local/repos/etiqueta_template_local_repo.dart';
import 'package:tag_valida/providers/estoque_mov_local_provider.dart';

class FakeEtiquetaRepo implements EtiquetasLocalRepo {
  @override
  Future<void> upsert(String uid, dynamic etiqueta) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTemplateRepo implements EtiquetasTemplatesLocalRepo {
  final List<dynamic> templates = [];

  @override
  Future<void> upsert(String uid, dynamic template) async {
    templates.add(template);
  }

  @override
  Future<EtiquetaTemplateModel?> findByKey({
    required String uid,
    required String produtoNome,
    required String categoriaId,
    required String setorId,
  }) async {
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMovRepo implements EstoqueMovLocalProvider {
  @override
  Future<void> registrarEntrada({
    required String uid,
    required String etiquetaId,
    required num quantidade,
    required unidadeMedida,
    String? produtoNome,
    String? motivo,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Template diário', () {
    test('deve salvar template automaticamente ao criar etiqueta', () async {
     
      final fakeRepo = FakeEtiquetaRepo();
      final fakeTemplateRepo = FakeTemplateRepo();
      final fakeMov = FakeMovRepo();

      final provider = GerarEtiquetaLocalProvider(
        repo: fakeRepo,
        templateRepo: fakeTemplateRepo,
        mov: fakeMov,
      );

      final tipo = TipoEtiquetaModel(
        id: 'tipo1',
        nome: 'Etiqueta Padrão',
        camposCustom: [],
        usarRegraValidadeCategoria: false,
        controlaLote: false,
        permiteTabelaNutricional: false,
      );

      final categoria = CategoriaModel(
        id: 'cat1',
        nome: 'Pães',
        diasVencimento: 3,
        ativo: true,
      );

      final setor = SetorModel(
        id: 'set1',
        nome: 'Produção',
        ativo: true,
      );

      provider.tipoId = tipo.id;
      provider.categoria = categoria;
      provider.setor = setor;

      provider.produtoCtrl.text = "Pão francês";
      provider.quantidadeCtrl.text = "10";
      provider.unidadeMedida = 'un';

      provider.fabricacao = DateTime.now();
      provider.validade = DateTime.now().add(Duration(days: 2));

     
      await provider.salvarEtiqueta(
        uid: "user123",
        tipoAtual: tipo,
      );

      
      expect(fakeTemplateRepo.templates.length, 1);

      final template = fakeTemplateRepo.templates.first;

      expect(template.produtoNome, "Pão francês");
      expect(template.quantidadePadrao, 10);
      expect(template.unidadeMedidaPadrao, 'un');
      expect(template.categoriaId, categoria.id);
      expect(template.setorId, setor.id);
    });
  });
}

