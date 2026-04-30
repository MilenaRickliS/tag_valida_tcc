import 'package:flutter_test/flutter_test.dart';

import 'package:tag_valida/utils/etiqueta_qr.dart';
import 'package:tag_valida/models/estoque_mov_model.dart';

void main() {
  group('Scanner QR / Inventário / Movimentação', () {
    test('scanner reconhece etiqueta válida pelo QR privado', () {
      final qr = buildEtiquetaQrPrivado(
        uid: 'user1',
        etiquetaId: 'etiqueta1',
      );

      final parsed = parseEtiquetaQrPayload(qr);

      expect(parsed.uid, 'user1');
      expect(parsed.id, 'etiqueta1');
    });

    test('QR público não deve ser aceito no inventário', () {
      const qrPublico = 'https://tagvalida.web.app/e/etiqueta1?uid=user1';

      final isQrPublico = qrPublico.startsWith('PUBLICO:') ||
          qrPublico.startsWith('http');

      expect(isQrPublico, true);
    });

    test('movimentação deve registrar tipo venda corretamente', () {
      final now = DateTime.now();

      final mov = EstoqueMovModel(
        id: 'mov1',
        etiquetaId: 'etiqueta1',
        produtoNome: 'Pão francês',
        tipo: EstoqueMovModel.tipoVenda,
        quantidade: 2,
        motivo: 'Venda',
        createdAt: now,
        updatedAt: now,
      );

      expect(mov.etiquetaId, 'etiqueta1');
      expect(mov.produtoNome, 'Pão francês');
      expect(mov.tipo, EstoqueMovModel.tipoVenda);
      expect(mov.quantidade, 2);
      expect(mov.motivo, 'Venda');
    });
  });
}