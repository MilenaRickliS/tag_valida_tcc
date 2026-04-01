import './tabela_nutricional_model.dart';

class EtiquetaTemplateModel {
  final String id;
  final String tipoId;
  final String tipoNome;

  final String produtoNome;

  final String categoriaId;
  final String categoriaNome;

  final String setorId;
  final String setorNome;

  final Map<String, dynamic> camposCustomValores;

  final bool incluirTabelaNutricional;
  final TabelaNutricionalModel? tabelaNutricional;

  final num quantidadePadrao;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  EtiquetaTemplateModel({
    required this.id,
    required this.tipoId,
    required this.tipoNome,
    required this.produtoNome,
    required this.categoriaId,
    required this.categoriaNome,
    required this.setorId,
    required this.setorNome,
    required this.camposCustomValores,
    required this.quantidadePadrao,
    required this.incluirTabelaNutricional,
    this.tabelaNutricional,
    this.createdAt,
    this.updatedAt,
  });
}