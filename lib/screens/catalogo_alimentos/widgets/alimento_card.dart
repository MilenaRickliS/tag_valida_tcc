// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/alimento_catalogo_model.dart';
import '../detalhe_alimento_screen.dart';

class AlimentoCard extends StatelessWidget {
  final AlimentoCatalogo item;
  final Color brand;
  final Color text;
  final Color muted;
  final bool isDark;

  const AlimentoCard({
    super.key,
    required this.item,
    required this.brand,
    required this.text,
    required this.muted,
    required this.isDark,
  });

  IconData _iconeCategoria(String categoria) {
    switch (categoria) {
      case 'Panificados':
        return Icons.bakery_dining_rounded;
      case 'Laticínios':
        return Icons.local_drink_rounded;
      case 'Carnes':
        return Icons.set_meal_rounded;
      case 'Frutas':
        return Icons.apple_rounded;
      case 'Hortaliças':
        return Icons.eco_rounded;
      case 'Congelados':
        return Icons.ac_unit_rounded;
      default:
        return Icons.food_bank_rounded;
    }
  }

  Color _corCategoria(String categoria) {
    switch (categoria) {
      case 'Panificados':
        return const Color(0xFFE59A2F);
      case 'Laticínios':
        return const Color(0xFF4A90E2);
      case 'Carnes':
        return const Color(0xFFD64545);
      case 'Frutas':
        return const Color(0xFF34A853);
      case 'Hortaliças':
        return const Color(0xFF2E7D32);
      case 'Congelados':
        return const Color(0xFF00ACC1);
      default:
        return brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final categoriaCor = _corCategoria(item.categoria);
    final categoriaIcone = _iconeCategoria(item.categoria);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalheAlimentoScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.22 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      item.imagemAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? const Color(0xFF151515) : const Color(0xFFF4F1EA),
                        child: Center(
                          child: Icon(
                            categoriaIcone,
                            size: 46,
                            color: categoriaCor,
                          ),
                        ),
                      ),
                    ),
                  ),

                 
                  if (item.veioDaIA)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF121212).withOpacity(0.92)
                              : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: brand.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: brand,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Detectado pela IA',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: brand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: categoriaCor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoriaIcone,
                          size: 16,
                          color: categoriaCor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.categoria,
                          style: TextStyle(
                            color: categoriaCor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    item.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    item.descricao,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: muted,
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 18,
                        color: brand,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ver detalhes',
                        style: TextStyle(
                          color: brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}