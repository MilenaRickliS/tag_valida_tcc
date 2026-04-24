import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadCampoImagem({
    required String uid,
    required String etiquetaId,
    required String campoKey,
    required File file,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final ref = storage.ref().child(
      'usuarios/$uid/etiquetas/$etiquetaId/campos/$campoKey.$ext',
    );

    final metadata = SettableMetadata(
      contentType: _contentTypeFromExt(ext),
    );

    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }

  String _contentTypeFromExt(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}