import 'package:flutter/material.dart';
import '../../../models/tabela_nutricional_model.dart';

String getImagemRotulagem({
  required bool acucar,
  required bool gordura,
  required bool sodio,
}) {
  if (acucar && gordura && sodio) {
    return 'assets/rotulagem/3_todos.png';
  }

  if (acucar && gordura) {
    return 'assets/rotulagem/2_acucar_gordura.png';
  }

  if (acucar && sodio) {
    return 'assets/rotulagem/2_acucar_sodio.png';
  }

  if (gordura && sodio) {
    return 'assets/rotulagem/2_gordura_sodio.png';
  }

  if (acucar) {
    return 'assets/rotulagem/1_acucar.png';
  }

  if (gordura) {
    return 'assets/rotulagem/1_gordura.png';
  }

  if (sodio) {
    return 'assets/rotulagem/1_sodio.png';
  }

  return '';
}

class RotulagemFrontalImagem extends StatelessWidget {
  final TabelaNutricionalModel tabela;

  const RotulagemFrontalImagem({
    super.key,
    required this.tabela,
  });

  double _porcaoBase() {
    final raw = tabela.porcao.replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  double _por100(double v) {
    final base = _porcaoBase();
    if (base <= 0) return 0;
    return (v / base) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final acucar = _por100(tabela.acucaresAdicionados) >= 15;
    final gordura = _por100(tabela.gordurasSaturadas) >= 6;
    final sodio = _por100(tabela.sodio) >= 600;

    final path = getImagemRotulagem(
      acucar: acucar,
      gordura: gordura,
      sodio: sodio,
    );

    if (path.isEmpty) return const SizedBox.shrink();

   return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Image.asset(
          path,
          height: 58,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}