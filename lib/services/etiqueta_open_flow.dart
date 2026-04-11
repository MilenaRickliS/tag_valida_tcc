// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local/repos/etiquetas_local_repo.dart';
import '../models/etiqueta_model.dart';
import 'etiqueta_firebase_service.dart';
import '../screens/etiqueta_detalhes/etiqueta_detalhes.dart';

Future<void> openEtiquetaPdfFlow(
  BuildContext context, {
  required String uid,
  required String etiquetaId,
}) async {
  final repo = context.read<EtiquetasLocalRepo>();
  final fb = EtiquetaFirebaseService();

  EtiquetaModel? e = await repo.getById(uid: uid, id: etiquetaId);
  e ??= await fb.getById(uid: uid, id: etiquetaId);

  if (e == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Etiqueta não encontrada (offline e online)."),
      ),
    );
    return;
  }

  if (!context.mounted) return;

  await Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => EtiquetaDetalhesScreen(
        uid: uid,
        etiquetaId: etiquetaId,
      ),
    ),
  );
}