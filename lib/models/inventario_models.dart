class InventarioItemLido {
  final String etiquetaId;
  final String produtoNome;
  final String setorNome;
  final String categoriaNome;
  final num quantidade;

  const InventarioItemLido({
    required this.etiquetaId,
    required this.produtoNome,
    required this.setorNome,
    required this.categoriaNome,
    required this.quantidade,
  });
}

class InventarioResumo {
  final int etiquetasLidas;
  final num totalItens;
  final Map<String, num> totalPorSetor;
  final Map<String, num> totalPorCategoria;
  final List<InventarioItemLido> itens;

  const InventarioResumo({
    required this.etiquetasLidas,
    required this.totalItens,
    required this.totalPorSetor,
    required this.totalPorCategoria,
    required this.itens,
  });
}