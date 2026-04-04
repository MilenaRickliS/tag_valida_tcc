// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/design_etiqueta_model.dart';

  const _orange = Color(0xFFED7227);
  const _green = Color(0xFF88BE8E);

Widget buildEmpresaPreviewNovo(
    CampoDesignEtiquetaModel campo,
    DesignEtiquetaModel config,
  ) {
    final textWidget = Align(
      alignment: toAlignment(campo.align),
      child: Text(
        'Panificadora TagValida\nCNPJ: 12.123.456/0001-90\nRua Exemplo, 123',
        textAlign: campo.align,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: campo.fontSize.clamp(8, 13),
          height: 1.2,
          color: Colors.black54,
          fontWeight: campo.isBold ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );

  if (!config.mostrarLogo) return textWidget;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/logo6.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [_orange, _green]),
              ),
              child: const Icon(Icons.local_offer_rounded, color: Colors.white),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: textWidget),
    ],
  );
}

Alignment toAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.left:
      default:
        return Alignment.centerLeft;
    }
  }

  CrossAxisAlignment toCrossAxis(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.left:
      default:
        return CrossAxisAlignment.start;
    }
  }
