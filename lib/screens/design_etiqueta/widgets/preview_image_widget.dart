// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../models/design_etiqueta_model.dart';
import './etiqueta_preview_design.dart';

class EtiquetaPreviewImageWidget extends StatefulWidget {
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
  State<EtiquetaPreviewImageWidget> createState() =>
      _EtiquetaPreviewImageWidgetState();
}

class _EtiquetaPreviewImageWidgetState
    extends State<EtiquetaPreviewImageWidget> {
  final GlobalKey _previewKey = GlobalKey();

  Uint8List? _imageBytes;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _scheduleGenerate();
  }

  @override
  void didUpdateWidget(covariant EtiquetaPreviewImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final changed =
        oldWidget.config != widget.config ||
        oldWidget.isInvalid != widget.isInvalid ||
        oldWidget.errorMessage != widget.errorMessage ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height;

    if (changed) {
      _imageBytes = null;
      _scheduleGenerate();
    }
  }

  void _scheduleGenerate() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _generateImage();
    });
  }

  Future<void> _generateImage() async {
    if (!mounted || _isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 120));

      final renderObject = _previewKey.currentContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
        return;
      }

      final image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (!mounted) return;

      setState(() {
        _imageBytes = byteData?.buffer.asUint8List();
        _isGenerating = false;
      });
    } catch (e, s) {
      debugPrint('Erro ao gerar imagem da etiqueta: $e');
      debugPrint('$s');

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget _buildSourcePreview() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Material(
          color: Colors.white,
          child: buildEtiquetaPreview(
            widget.config,
            isInvalid: widget.isInvalid,
            errorMessage: widget.errorMessage,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              key: _previewKey,
              child: _buildSourcePreview(),
            ),
            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            if (_isGenerating && _imageBytes == null)
              Container(
                color: Colors.white.withOpacity(0.30),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}