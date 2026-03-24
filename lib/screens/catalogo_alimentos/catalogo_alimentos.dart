// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../widgets/menu.dart';
import '../../models/alimento_catalogo_model.dart';
import '../catalogo_alimentos/widgets/alimento_card.dart';
import '../catalogo_alimentos/widgets/catalogo_hero_card.dart';

class CatalogoAlimentosScreen extends StatefulWidget {
  const CatalogoAlimentosScreen({super.key});

  @override
  State<CatalogoAlimentosScreen> createState() => _CatalogoAlimentosScreenState();
}

class _CatalogoAlimentosScreenState extends State<CatalogoAlimentosScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  String _busca = '';
  String _categoriaSelecionada = 'Todos';

  final List<String> categorias = const [
    'Todos',
    'Panificados',
    'Laticínios',
    'Carnes',
    'Frutas',
    'Hortaliças',
    'Congelados',
  ];

  final List<AlimentoCatalogo> alimentos = [
    AlimentoCatalogo(
      id: '1',
      nome: 'Pão francês',
      categoria: 'Panificados',
      descricao: 'Produto assado de consumo rápido, sensível à umidade e mofo.',
      sinaisBom: [
        'Casca dourada e uniforme',
        'Miolo macio sem manchas',
        'Cheiro característico de pão fresco',
      ],
      sinaisAlerta: [
        'Umidade excessiva',
        'Cheiro diferente do habitual',
        'Textura muito borrachuda',
      ],
      sinaisRuim: [
        'Presença de mofo',
        'Manchas esverdeadas ou escuras',
        'Odor azedo ou desagradável',
      ],
      cheiro: [
        'Suave e característico quando bom',
        'Azedo ou estranho quando deteriorado',
      ],
      textura: [
        'Leve crocância por fora e macio por dentro quando bom',
        'Muito duro, úmido demais ou pegajoso quando alterado',
      ],
      cor: [
        'Dourado natural quando bom',
        'Pontos escuros, verdes ou brancos podem indicar mofo',
      ],
      imagemAsset: 'assets/alimentos/pao.jpg',
    ),
    AlimentoCatalogo(
      id: '2',
      nome: 'Queijo mussarela',
      categoria: 'Laticínios',
      descricao: 'Derivado lácteo refrigerado com risco de mofo e alteração de odor.',
      sinaisBom: [
        'Cor uniforme',
        'Cheiro suave',
        'Superfície firme e íntegra',
      ],
      sinaisAlerta: [
        'Suor excessivo',
        'Odor mais intenso',
        'Textura muito mole',
      ],
      sinaisRuim: [
        'Mofo visível',
        'Viscosidade',
        'Cheiro azedo forte',
      ],
      cheiro: [
        'Suave e lácteo quando bom',
        'Azedo ou fermentado quando impróprio',
      ],
      textura: [
        'Firme e elástica quando boa',
        'Pegajosa ou viscosa quando alterada',
      ],
      cor: [
        'Branco-amarelado uniforme',
        'Manchas verdes, pretas ou rosadas indicam deterioração',
      ],
      imagemAsset: 'assets/alimentos/queijo.jpg',
    ),
    AlimentoCatalogo(
      id: '3',
      nome: 'Maçã',
      categoria: 'Frutas',
      descricao: 'Fruta sensível a amassados, fermentação e apodrecimento.',
      sinaisBom: [
        'Casca firme',
        'Cor viva',
        'Cheiro suave e fresco',
      ],
      sinaisAlerta: [
        'Pequenas áreas amassadas',
        'Casca enrugada',
        'Perda de firmeza',
      ],
      sinaisRuim: [
        'Partes escuras profundas',
        'Mofo',
        'Cheiro fermentado',
      ],
      cheiro: [
        'Fresco e suave quando boa',
        'Fermentado quando deteriorada',
      ],
      textura: [
        'Firme quando boa',
        'Mole e úmida demais quando alterada',
      ],
      cor: [
        'Coloração natural uniforme',
        'Escurecimento intenso pode indicar apodrecimento',
      ],
      imagemAsset: 'assets/alimentos/maca.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted = isDark
        ? const Color(0xFFD6D6D6)
        : Colors.black.withOpacity(0.65);

    final borderColor = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.16)
        : Colors.black.withOpacity(0.05);

    final filtrados = alimentos.where((a) {
      final matchBusca = a.nome.toLowerCase().contains(_busca.toLowerCase());
      final matchCategoria = _categoriaSelecionada == 'Todos' ||
          a.categoria == _categoriaSelecionada;
      return matchBusca && matchCategoria;
    }).toList();

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;
    final mobile = w < 650;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: compact ? 160 : 100,
        centerTitle: true,
        title: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo6.png', height: 78),
                  const SizedBox(height: 10),
                  const TopMenu(),
                ],
              )
            : Row(
                children: [
                  Image.asset('assets/logo6.png', height: 92),
                  const Spacer(),
                  const TopMenu(),
                ],
              ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatalogoHeroCard(brand: brand, text: text, isDark: isDark),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.24 : 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _busca = v),
                        decoration: InputDecoration(
                          hintText: 'Buscar alimento...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF151515)
                              : const Color(0xFFF7F3EA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categorias.map((cat) {
                            final selected = cat == _categoriaSelecionada;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => _categoriaSelecionada = cat);
                              },
                              selectedColor: brand.withOpacity(0.18),
                              labelStyle: TextStyle(
                                color: selected ? brand : text,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? brand.withOpacity(0.35)
                                    : borderColor,
                              ),
                              backgroundColor: isDark
                                  ? const Color(0xFF151515)
                                  : const Color(0xFFF8F7F3),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Alimentos cadastrados',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Consulte os principais sinais visuais e sensoriais para apoiar sua decisão.',
                  style: TextStyle(
                    fontSize: 15,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 16),

                if (filtrados.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'Nenhum alimento encontrado para essa busca.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 15,
                      ),
                    ),
                  )
                else if (mobile)
                  Column(
                    children: filtrados
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AlimentoCard(
                                item: item,
                                brand: brand,
                                text: text,
                                muted: muted,
                                isDark: isDark,
                              ),
                            ))
                        .toList(),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtrados.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: w > 1000 ? 3 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.02,
                    ),
                    itemBuilder: (_, index) {
                      return AlimentoCard(
                        item: filtrados[index],
                        brand: brand,
                        text: text,
                        muted: muted,
                        isDark: isDark,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

