import 'dart:convert';
import '../models/tipo_etiqueta_model.dart';
import '../models/etiqueta_model.dart';

String buildEtiquetaQrPrivado({
  required String uid,
  required String etiquetaId,
}) {
  final json = jsonEncode({
    "app": "tagvalida",
    "v": 1,
    "uid": uid,
    "id": etiquetaId,
    "type": "etiqueta",
    "mode": "privado",
  });

  return base64Url.encode(utf8.encode(json));
}

String buildEtiquetaQrPublico({
  required String uid,
  required String etiquetaId,
}) {
  // return 'https://seudominio.com/e/$etiquetaId?uid=$uid';
  return 'PUBLICO:$uid:$etiquetaId';
}

String buildEtiquetaQrData({
  required TipoQrEtiqueta tipoQr,
  required EtiquetaModel etiqueta,
  required String uid,
}) {
  switch (tipoQr) {
    case TipoQrEtiqueta.publico:
      return buildEtiquetaQrPublico(
        uid: uid,
        etiquetaId: etiqueta.id,
      );

    case TipoQrEtiqueta.privado:
      return buildEtiquetaQrPrivado(
        uid: uid,
        etiquetaId: etiqueta.id,
      );
  }
}

class EtiquetaQrParsed {
  final String uid;
  final String id;
  final String type;
  final int version;

  EtiquetaQrParsed({
    required this.uid,
    required this.id,
    required this.type,
    required this.version,
  });
}

EtiquetaQrParsed parseEtiquetaQrPayload(String raw) {
  final decodedJson = utf8.decode(base64Url.decode(raw.trim()));
  final obj = jsonDecode(decodedJson) as Map<String, dynamic>;

  if (obj["app"] != "tagvalida") {
    throw const FormatException("QR não pertence ao TagValida");
  }

  final type = (obj["type"] ?? "etiqueta").toString();
  if (type != "etiqueta") {
    throw const FormatException("QR não é de etiqueta");
  }

  return EtiquetaQrParsed(
    uid: obj["uid"].toString(),
    id: obj["id"].toString(),
    type: type,
    version: (obj["v"] is int)
        ? obj["v"] as int
        : int.tryParse(obj["v"].toString()) ?? 1,
  );
}