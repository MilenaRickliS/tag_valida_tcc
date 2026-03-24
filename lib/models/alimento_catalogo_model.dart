class AlimentoCatalogo {
  final String id;
  final String nome;
  final String categoria;
  final String descricao;
  final List<String> sinaisBom;
  final List<String> sinaisAlerta;
  final List<String> sinaisRuim;
  final List<String> cheiro;
  final List<String> textura;
  final List<String> cor;
  final String? imagemAsset;

  AlimentoCatalogo({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.sinaisBom,
    required this.sinaisAlerta,
    required this.sinaisRuim,
    required this.cheiro,
    required this.textura,
    required this.cor,
    this.imagemAsset,
  });
}