// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PreverValidadeFab extends StatelessWidget {
  final bool isDark;
  final bool loading;

  final Color brand;
  final Color fabBg;
  final Color fabFg;
  final Color fabBorder;

  final VoidCallback onPressed;

  const PreverValidadeFab({
    super.key,
    required this.isDark,
    required this.loading,
    required this.brand,
    required this.fabBg,
    required this.fabFg,
    required this.fabBorder,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: fabBg,
        foregroundColor: fabFg,
        elevation: 0,
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(fabFg),
                ),
              )
            : Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: isDark ? Colors.black : Colors.white,
                  size: 20,
                ),
              ),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            loading ? "Analisando..." : "Tirar foto",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: fabFg,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: fabBorder),
        ),
      ),
    );
  }
}