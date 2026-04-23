import 'dart:typed_data';

Future<dynamic> savePdfTempFile(Uint8List bytes, String filename) {
  throw UnsupportedError('Salvar arquivo temporário não disponível nesta plataforma.');
}

Future<Uint8List?> readLocalFileBytes(String path) async {
  return null;
}