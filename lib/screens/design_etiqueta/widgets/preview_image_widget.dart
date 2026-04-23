// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';
import './etiqueta_preview_design.dart';

class EtiquetaPreviewImageWidget extends StatelessWidget {
  final DesignEtiquetaModel config;
  final bool isInvalid;
  final String? errorMessage;
  final double width;
  final double height;
  final double borderRadius;

  const EtiquetaPreviewImageWidget({
    super.key,
    required this.config,
    required this.isInvalid,
    this.errorMessage,
    required this.width,
    required this.height,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.white,
          child: buildEtiquetaPreview(
            config,
            isInvalid: isInvalid,
            errorMessage: errorMessage,
          ),
        ),
      ),
    );
  }
}