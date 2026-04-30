import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tag_valida/models/etiqueta_model.dart';
import 'package:tag_valida/models/tipo_etiqueta_model.dart';
import 'package:tag_valida/utils/etiqueta_qr.dart';
import 'package:tag_valida/services/etiqueta_qr_resolver.dart';

void main() {
  EtiquetaModel etiquetaFake() {
    return EtiquetaModel(
      id: 'etiqueta123',
      tipoId: 'tipo1',
      tipoNome: 'Etiqueta Padrão',
      produtoNome: 'Pão francês',
      categoriaId: 'cat1',
      categoriaNome: 'Pães',
      setorId: 'set1',
      setorNome: 'Produção',
      dataFabricacao: DateTime(2026, 4, 27),
      dataValidade: DateTime(2026, 4, 30),
      camposCustomValores: const {},
      status: 'ativa',
      lote: null,
      incluirTabelaNutricional: false,
      quantidade: 10,
      quantidadeRestante: 10,
      statusEstoque: 'ativo',
    );
  }

  TipoEtiquetaModel tipoFake(TipoQrEtiqueta tipoQr) {
    return TipoEtiquetaModel(
      id: 'tipo1',
      nome: 'Etiqueta Padrão',
      camposCustom: const [],
      usarRegraValidadeCategoria: false,
      controlaLote: false,
      permiteTabelaNutricional: false,
      tipoQr: tipoQr,
    );
  }

  group('QR Code da etiqueta', () {
    test('deve gerar QR privado em Base64 com dados corretos', () {
      final qr = buildEtiquetaQrPrivado(
        uid: 'user1',
        etiquetaId: 'etiqueta123',
      );

      final decoded = utf8.decode(base64Url.decode(qr));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      expect(json['app'], 'tagvalida');
      expect(json['v'], 1);
      expect(json['uid'], 'user1');
      expect(json['id'], 'etiqueta123');
      expect(json['type'], 'etiqueta');
      expect(json['mode'], 'privado');
    });

    test('deve interpretar QR privado corretamente', () {
      final qr = buildEtiquetaQrPrivado(
        uid: 'user1',
        etiquetaId: 'etiqueta123',
      );

      final parsed = parseEtiquetaQrPayload(qr);

      expect(parsed.uid, 'user1');
      expect(parsed.id, 'etiqueta123');
      expect(parsed.type, 'etiqueta');
      expect(parsed.version, 1);
    });

    test('deve gerar QR público com link correto', () {
      final qr = buildEtiquetaQrPublico(
        uid: 'user1',
        etiquetaId: 'etiqueta123',
      );

      expect(qr, 'https://tagvalida.web.app/e/etiqueta123?uid=user1');
    });

    test('resolver deve retornar QR privado quando tipo for privado', () {
      final qr = EtiquetaQrResolver.resolve(
        etiqueta: etiquetaFake(),
        tipoEtiqueta: tipoFake(TipoQrEtiqueta.privado),
        uid: 'user1',
      );

      final parsed = parseEtiquetaQrPayload(qr);

      expect(parsed.uid, 'user1');
      expect(parsed.id, 'etiqueta123');
    });

    test('resolver deve retornar QR público quando tipo for público', () {
      final qr = EtiquetaQrResolver.resolve(
        etiqueta: etiquetaFake(),
        tipoEtiqueta: tipoFake(TipoQrEtiqueta.publico),
        uid: 'user1',
      );

      expect(qr, 'https://tagvalida.web.app/e/etiqueta123?uid=user1');
    });
  });
}