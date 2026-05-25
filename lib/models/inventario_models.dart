class InventarioItemLido {
  final String etiquetaId;
  final String produtoNome;
  final String setorNome;
  final String categoriaNome;
  final num quantidade;
  final String unidadeMedida;

  const InventarioItemLido({
    required this.etiquetaId,
    required this.produtoNome,
    required this.setorNome,
    required this.categoriaNome,
    required this.quantidade,
    this.unidadeMedida = 'un',
  });
}

class InventarioResumo {
  final int etiquetasLidas;

  final num totalUnidades;
  final num totalKg;

  final Map<String, num> totalUnPorSetor;
  final Map<String, num> totalKgPorSetor;

  final Map<String, num> totalUnPorCategoria;
  final Map<String, num> totalKgPorCategoria;

  final List<InventarioItemLido> itens;

  const InventarioResumo({
    required this.etiquetasLidas,
    required this.totalUnidades,
    required this.totalKg,
    required this.totalUnPorSetor,
    required this.totalKgPorSetor,
    required this.totalUnPorCategoria,
    required this.totalKgPorCategoria,
    required this.itens,
  });
}