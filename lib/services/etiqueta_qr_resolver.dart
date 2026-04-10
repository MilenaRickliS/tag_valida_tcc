import '../models/etiqueta_model.dart';
import '../models/tipo_etiqueta_model.dart';
import '../utils/etiqueta_qr.dart';

class EtiquetaQrResolver {
  static String resolve({
    required EtiquetaModel etiqueta,
    required TipoEtiquetaModel tipoEtiqueta,
    required String uid,
  }) {
    return buildEtiquetaQrData(
      etiqueta: etiqueta,
      tipoQr: tipoEtiqueta.tipoQr,
      uid: uid,
    );
  }
}