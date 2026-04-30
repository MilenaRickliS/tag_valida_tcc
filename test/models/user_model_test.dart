import 'package:flutter_test/flutter_test.dart';
import 'package:tag_valida/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('deve converter UserModel para Map corretamente', () {
      final user = UserModel(
        uid: 'uid123',
        nome: 'Padaria Modelo',
        razao: 'Padaria Modelo LTDA',
        email: 'teste@gmail.com',
        cnpj: '12345678000199',
        cep: '85000000',
        rua: 'Rua Central',
        numero: '123',
        bairro: 'Centro',
        complemento: '',
        cidade: 'Guarapuava',
        estado: 'PR',
        telefone: '42999999999',
        responsavel: 'Milena',
        logo: '',
      );

      final map = user.toMap();

      expect(map['uid'], 'uid123');
      expect(map['nome'], 'Padaria Modelo');
      expect(map['email'], 'teste@gmail.com');
      expect(map['cnpj'], '12345678000199');
      expect(map['cidade'], 'Guarapuava');
    });

    test('deve criar UserModel a partir de Map', () {
      final map = {
        'uid': 'uid123',
        'nome': 'Padaria Modelo',
        'razao': 'Padaria Modelo LTDA',
        'email': 'teste@gmail.com',
        'cnpj': '12345678000199',
        'cep': '85000000',
        'rua': 'Rua Central',
        'numero': '123',
        'bairro': 'Centro',
        'complemento': '',
        'cidade': 'Guarapuava',
        'estado': 'PR',
        'telefone': '42999999999',
        'responsavel': 'Milena',
        'logo': '',
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'uid123');
      expect(user.nome, 'Padaria Modelo');
      expect(user.email, 'teste@gmail.com');
      expect(user.estado, 'PR');
    });

    test('deve usar logo vazia quando logo vier nula', () {
      final map = {
        'uid': 'uid123',
        'nome': 'Padaria Modelo',
        'razao': 'Padaria Modelo LTDA',
        'email': 'teste@gmail.com',
        'cnpj': '12345678000199',
        'cep': '85000000',
        'rua': 'Rua Central',
        'numero': '123',
        'bairro': 'Centro',
        'complemento': '',
        'cidade': 'Guarapuava',
        'estado': 'PR',
        'telefone': '42999999999',
        'responsavel': 'Milena',
        'logo': null,
      };

      final user = UserModel.fromMap(map);

      expect(user.logo, '');
    });
  });
}