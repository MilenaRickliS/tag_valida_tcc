import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:tag_valida/models/etiqueta_model.dart';
import 'package:tag_valida/services/etiqueta_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PDF da etiqueta deve gerar sem erro', () async {
    final etiqueta = EtiquetaModel(
      id: 'etiqueta1',
      tipoId: 'tipo1',
      tipoNome: 'Etiqueta 60x40',
      produtoNome: 'Pão francês',
      categoriaId: 'cat1',
      categoriaNome: 'Pães',
      setorId: 'set1',
      setorNome: 'Produção',
      dataFabricacao: DateTime(2026, 4, 30),
      dataValidade: DateTime(2026, 5, 3),
      camposCustomValores: {
        'lote': {
          'label': 'Lote',
          'value': 'L001',
        },
      },
      status: 'ativo',
      lote: 'L001',
      incluirTabelaNutricional: false,
      tabelaNutricional: null,
      quantidade: 10,
      quantidadeRestante: 10,
      statusEstoque: 'ativo',
      createdAt: DateTime(2026, 4, 30),
    );

    final bytes = await EtiquetaPdfService.generateBytes(
      etiqueta,
      qrData: 'https://tagvalida.web.app/e/etiqueta1?uid=user1',
    );

    expect(bytes, isA<Uint8List>());
    expect(bytes.isNotEmpty, true);
  });
}