import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<File> savePdfTempFile(Uint8List bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<Uint8List?> readLocalFileBytes(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}