import 'package:flutter_test/flutter_test.dart';
import 'package:tag_valida/models/etiqueta_model.dart';

void main() {
  group('Status de estoque da etiqueta', () {
    test('deve retornar ativo quando ainda houver quantidade restante', () {
      final status = EtiquetaModel.calcStatusEstoque(
        restante: 5,
        current: 'ativo',
      );

      expect(status, 'ativo');
    });

    test('deve retornar vendido quando quantidade restante for zero', () {
      final status = EtiquetaModel.calcStatusEstoque(
        restante: 0,
        current: 'ativo',
      );

      expect(status, 'vendido');
    });

    test('deve retornar vendido quando quantidade restante for negativa', () {
      final status = EtiquetaModel.calcStatusEstoque(
        restante: -1,
        current: 'ativo',
      );

      expect(status, 'vendido');
    });

    test('deve manter cancelado mesmo com quantidade restante', () {
      final status = EtiquetaModel.calcStatusEstoque(
        restante: 10,
        current: 'cancelado',
      );

      expect(status, 'cancelado');
    });

    test('deve manter vendido quando status atual for vendido', () {
      final status = EtiquetaModel.calcStatusEstoque(
        restante: 10,
        current: 'vendido',
      );

      expect(status, 'vendido');
    });

    test('deve ignorar espaços e letras maiúsculas no status atual', () {
      final status = EtiquetaModel.calcStatusEstoque(
        restante: 10,
        current: '  CANCELADO  ',
      );

      expect(status, 'cancelado');
    });
  });
}