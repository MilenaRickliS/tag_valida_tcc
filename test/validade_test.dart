import 'package:flutter_test/flutter_test.dart';

bool isVencida(DateTime val) {
  final hoje = DateTime.now();
  final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
  return val.isBefore(hojeSemHora);
}

bool isAlerta(DateTime val) {
  final hoje = DateTime.now();
  final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

  return !val.isBefore(hojeSemHora) &&
      val.difference(hojeSemHora).inDays <= 3;
}

void main() {
  group('Validade da etiqueta', () {
    test('deve ser vencida quando data for anterior a hoje', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));

      expect(isVencida(ontem), true);
    });

    test('deve ser alerta quando faltar até 3 dias', () {
      final em2dias = DateTime.now().add(const Duration(days: 2));

      expect(isAlerta(em2dias), true);
    });

    test('não deve ser alerta quando faltar mais de 3 dias', () {
      final em5dias = DateTime.now().add(const Duration(days: 5));

      expect(isAlerta(em5dias), false);
    });
  });
}