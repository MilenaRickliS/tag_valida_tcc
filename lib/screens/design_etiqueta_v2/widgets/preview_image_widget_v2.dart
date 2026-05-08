import 'package:flutter/material.dart';

import '../../../models/design_etiqueta_v2_model.dart';
import 'etiqueta_preview_v2.dart';

class EtiquetaPreviewImageWidgetV2 extends StatelessWidget {
  final DesignEtiquetaV2Model config;
  final bool isInvalid;
  final String? errorMessage;
  final double width;
  final double height;
  final double borderRadius;

  const EtiquetaPreviewImageWidgetV2({
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
          child: buildEtiquetaPreviewV2(
            config,
            isInvalid: isInvalid,
            errorMessage: errorMessage,
          ),
        ),
      ),
    );
  }
}
