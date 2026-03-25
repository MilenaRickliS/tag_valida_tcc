// ignore_for_file: deprecated_member_use
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../resultado_previsao/resultado_previsao_screen.dart';
import '../../widgets/menu.dart';
import './widgets/example_image_card.dart';
import './widgets/hero_card.dart';
import './widgets/info_box.dart';
import './widgets/info_card.dart';
import './widgets/outros_metodos_card.dart';
import './widgets/prever_validade_fab.dart';
import './widgets/tip_card.dart';

class PreverValidadeScreen extends StatefulWidget {
  const PreverValidadeScreen({super.key});

  @override
  State<PreverValidadeScreen> createState() => _PreverValidadeScreenState();
}

class _PreverValidadeScreenState extends State<PreverValidadeScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;

  Future<void> enviarParaApi(File file) async {
    setState(() => _loading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.5:8000/analisar'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = {};

        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          data = {
            'mensagem': 'Análise concluída com sucesso',
            'raw': response.body,
          };
        }

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultadoPrevisaoScreen(
              imagemPath: file.path,
              resultado: data,
            ),
          ),
        );
      } else {
        _mostrarErro(
          'Erro na análise (${response.statusCode}).\n${response.body}',
        );
      }
    } catch (e) {
      _mostrarErro('Erro ao enviar imagem: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _abrirCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    final file = File(image.path);
    await enviarParaApi(file);
  }

  Future<void> _abrirGaleria() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final file = File(image.path);
    await enviarParaApi(file);
  }

  void _abrirOpcoes() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tirar foto"),
                onTap: () {
                  Navigator.pop(context);
                  _abrirCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Escolher da galeria"),
                onTap: () {
                  Navigator.pop(context);
                  _abrirGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final brand = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final text = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final muted =
        isDark ? const Color(0xFFD6D6D6) : Colors.black.withOpacity(0.60);
    final fabBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final fabFg = isDark ? const Color(0xFFD4AF37) : const Color(0xFF428E2E);
    final fabBorder = isDark
        ? const Color(0xFFD4AF37).withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

    final w = MediaQuery.of(context).size.width;
    final compact = w < 835;
    final mobile = w < 640;

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
      floatingActionButton: PreverValidadeFab(
        isDark: isDark,
        loading: _loading,
        brand: brand,
        fabBg: fabBg,
        fabFg: fabFg,
        fabBorder: fabBorder,
        onPressed: _abrirOpcoes,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroCard(compact: compact),
                const SizedBox(height: 18),

                if (mobile)
                  Column(
                    children: const [
                      InfoStatCard(
                        icon: Icons.photo_camera_outlined,
                        title: "1. Tire a foto",
                        subtitle: "Capture uma imagem nítida do produto.",
                      ),
                      SizedBox(height: 12),
                      InfoStatCard(
                        icon: Icons.psychology_alt_outlined,
                        title: "2. IA analisa",
                        subtitle: "O sistema avalia o estado visual do alimento.",
                      ),
                      SizedBox(height: 12),
                      InfoStatCard(
                        icon: Icons.fact_check_outlined,
                        title: "3. Veja o resultado",
                        subtitle: "Receba o status: bom, alerta ou vencido.",
                      ),
                    ],
                  )
                else
                  Row(
                    children: const [
                      Expanded(
                        child: InfoStatCard(
                          icon: Icons.photo_camera_outlined,
                          title: "1. Tire a foto",
                          subtitle: "Capture uma imagem nítida do produto.",
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: InfoStatCard(
                          icon: Icons.psychology_alt_outlined,
                          title: "2. IA analisa",
                          subtitle: "O sistema avalia o estado visual do alimento.",
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: InfoStatCard(
                          icon: Icons.fact_check_outlined,
                          title: "3. Veja o resultado",
                          subtitle: "Receba o status: bom, alerta ou vencido.",
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                Text(
                  "Orientações para tirar a foto",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Siga estas recomendações para melhorar a precisão da análise da validade.",
                  style: TextStyle(
                    color: muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 850;

                    if (isSmall) {
                      return Column(
                        children: const [
                          TipCard(
                            icon: Icons.wb_sunny_outlined,
                            title: "Boa iluminação",
                            description:
                                "Tire a foto em um local bem iluminado para destacar textura, cor e possíveis sinais de deterioração.",
                          ),
                          SizedBox(height: 12),
                          TipCard(
                            icon: Icons.center_focus_strong_outlined,
                            title: "Enquadre o produto",
                            description:
                                "Centralize o alimento na imagem e evite cortar partes importantes.",
                          ),
                          SizedBox(height: 12),
                          TipCard(
                            icon: Icons.cleaning_services_outlined,
                            title: "Fundo limpo",
                            description:
                                "Prefira um fundo neutro e sem objetos excessivos para evitar confusão na análise.",
                          ),
                          SizedBox(height: 12),
                          TipCard(
                            icon: Icons.no_photography_outlined,
                            title: "Evite borrões",
                            description:
                                "Mantenha a câmera firme e não use fotos tremidas, escuras ou muito distantes.",
                          ),
                        ],
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        TipCard(
                          icon: Icons.wb_sunny_outlined,
                          title: "Boa iluminação",
                          description:
                              "Tire a foto em um local bem iluminado para destacar textura, cor e possíveis sinais de deterioração.",
                        ),
                        TipCard(
                          icon: Icons.center_focus_strong_outlined,
                          title: "Enquadre o produto",
                          description:
                              "Centralize o alimento na imagem e evite cortar partes importantes.",
                        ),
                        TipCard(
                          icon: Icons.cleaning_services_outlined,
                          title: "Fundo limpo",
                          description:
                              "Prefira um fundo neutro e sem objetos excessivos para evitar confusão na análise.",
                        ),
                        TipCard(
                          icon: Icons.no_photography_outlined,
                          title: "Evite borrões",
                          description:
                              "Mantenha a câmera firme e não use fotos tremidas, escuras ou muito distantes.",
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                Text(
                  "Exemplos de fotos",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Abaixo estão exemplos visuais de como a foto deve ser tirada.",
                  style: TextStyle(
                    color: muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 900) crossAxisCount = 2;
                    if (constraints.maxWidth < 560) crossAxisCount = 1;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        ExampleImageCard(
                          title: "Exemplo correto",
                          subtitle: "Produto centralizado e bem iluminado",
                          assetPath: 'assets/exemplo_bom_1.jpg',
                          isGood: true,
                        ),
                        ExampleImageCard(
                          title: "Exemplo correto",
                          subtitle: "Boa nitidez e fundo limpo",
                          assetPath: 'assets/exemplo_bom_2.jpg',
                          isGood: true,
                        ),
                        ExampleImageCard(
                          title: "Evite este tipo",
                          subtitle: "Imagem escura ou desfocada",
                          assetPath: 'assets/exemplo_ruim_1.png',
                          isGood: false,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),
                InfoBox(),

                const SizedBox(height: 18),
                OutrosMetodosCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
