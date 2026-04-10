import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrFullscreenScreen extends StatelessWidget {
  final String data;

  const QrFullscreenScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "QR Code",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: QrImageView(
            data: data,
            size: 300,
          ),
        ),
      ),
    );
  }
}