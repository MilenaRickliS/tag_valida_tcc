class TabelaNutricionalModel {
  final int porcoesPorEmbalagem;
  final String porcao;
  final String medidaCaseira;
  final double valorEnergetico;
  final double carboidratos;
  final double acucaresTotais;
  final double acucaresAdicionados;
  final double proteinas;
  final double gordurasTotais;
  final double gordurasSaturadas;
  final double gordurasTrans;
  final double fibraAlimentar;
  final double sodio;

  const TabelaNutricionalModel({
    required this.porcoesPorEmbalagem,
    required this.porcao,
    required this.medidaCaseira,
    required this.valorEnergetico,
    required this.carboidratos,
    required this.acucaresTotais,
    required this.acucaresAdicionados,
    required this.proteinas,
    required this.gordurasTotais,
    required this.gordurasSaturadas,
    required this.gordurasTrans,
    required this.fibraAlimentar,
    required this.sodio,
  });

  Map<String, dynamic> toMap() => {
        "porcoesPorEmbalagem": porcoesPorEmbalagem,
        "porcao": porcao,
        "medidaCaseira": medidaCaseira,
        "valorEnergetico": valorEnergetico,
        "carboidratos": carboidratos,
        "acucaresTotais": acucaresTotais,
        "acucaresAdicionados": acucaresAdicionados,
        "proteinas": proteinas,
        "gordurasTotais": gordurasTotais,
        "gordurasSaturadas": gordurasSaturadas,
        "gordurasTrans": gordurasTrans,
        "fibraAlimentar": fibraAlimentar,
        "sodio": sodio,
      };

  factory TabelaNutricionalModel.fromMap(Map<String, dynamic> m) {
    double asDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(",", ".")) ?? 0;
    }

    return TabelaNutricionalModel(
      porcoesPorEmbalagem: (m["porcoesPorEmbalagem"] ?? 1) is int
      ? m["porcoesPorEmbalagem"]
      : int.tryParse(m["porcoesPorEmbalagem"].toString()) ?? 1,
      porcao: (m["porcao"] ?? "").toString(),
      medidaCaseira: (m["medidaCaseira"] ?? "").toString(),
      valorEnergetico: asDouble(m["valorEnergetico"]),
      carboidratos: asDouble(m["carboidratos"]),
      acucaresTotais: asDouble(m["acucaresTotais"]),
      acucaresAdicionados: asDouble(m["acucaresAdicionados"]),
      proteinas: asDouble(m["proteinas"]),
      gordurasTotais: asDouble(m["gordurasTotais"]),
      gordurasSaturadas: asDouble(m["gordurasSaturadas"]),
      gordurasTrans: asDouble(m["gordurasTrans"]),
      fibraAlimentar: asDouble(m["fibraAlimentar"]),
      sodio: asDouble(m["sodio"]),
    );
  }
}