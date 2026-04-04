// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_valida/providers/theme_provider.dart';
import './widgets/audience_card.dart';
import './widgets/contact_card.dart';
import './widgets/feature_card.dart';
import './widgets/login_card.dart';
import './widgets/section_title.dart';
import './widgets/tech_card.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoFade;

  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  final PageController _pageController = PageController(viewportFraction: 0.88);
  Timer? _sliderTimer;
  int _currentPage = 0;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final logoCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(logoCurve);

    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(logoCurve);

    final cardCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(cardCurve);

    _cardFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(cardCurve);

    _controller.forward();
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;

      _currentPage++;
      if (_currentPage >= features.length) {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    const brandGreen = Color(0xFF54A73B);
    const brandYellow = Color(0xFFF8CB39);
    const brandOrange = Color(0xFFD38900);

    final bg = theme.scaffoldBackgroundColor;
    final sectionAlt = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.55);
    final textColor = colorScheme.onSurface;
    final mutedText = colorScheme.onSurface.withOpacity(0.78);
    final footerColor = isDark ? const Color(0xFF111111) : const Color(0xFF2B2B2B);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _cardFade,
                                    child: SlideTransition(
                                      position: _cardSlide,
                                      child: buildLoginCard(
                                        context,
                                        brandYellow,
                                        brandOrange,
                                        brandGreen,
                                        isDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                FadeTransition(
                                  opacity: _logoFade,
                                  child: SlideTransition(
                                    position: _logoSlide,
                                    child: Image.asset(
                                      'assets/logo3.png',
                                      height: 180,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'TagVálida',
                                  textAlign: TextAlign.center,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Mais que etiquetas. Gestão, rastreabilidade e tecnologia.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: mutedText,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                FadeTransition(
                                  opacity: _cardFade,
                                  child: SlideTransition(
                                    position: _cardSlide,
                                    child: buildLoginCard(
                                      context,
                                      brandYellow,
                                      brandOrange,
                                      brandGreen,
                                      isDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                buildSectionContainer(
                  child: buildSectionTitle(
                    context,
                    'Sobre o projeto',
                    'O TagVálida é um sistema inteligente criado para auxiliar pequenas empresas alimentícias no controle de etiquetas, validade, estoque e rastreabilidade de produtos. A proposta une organização, agilidade e tecnologia em uma solução moderna e prática para o dia a dia.',
                  ),
                ),
                buildSectionContainer(
                  color: sectionAlt,
                  child: Column(
                    children: [
                      buildSectionTitle(
                        context,
                        'Funcionalidades do app',
                        'Principais recursos do TagVálida apresentados em destaque.',
                        center: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: features.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            final item = features[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: FeatureCard(item: item, isDark: isDark),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: List.generate(
                          features.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: _currentPage == index ? 24 : 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? brandGreen
                                  : theme.dividerColor.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                buildSectionContainer(
                  child: Column(
                    children: [
                      buildSectionTitle(
                        context,
                        'Público-alvo',
                        'O sistema foi pensado especialmente para panificadoras, restaurantes, cozinhas de produção, pequenos mercados e outras pequenas empresas alimentícias que precisam controlar melhor seus produtos, reduzir perdas e padronizar processos.',
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 800;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              buildAudienceCard(
                                context: context,
                                icon: Icons.bakery_dining_rounded,
                                title: 'Panificadoras',
                                text:
                                    'Controle de produção, freezer, lotes e etiquetas de validade.',
                                width: isSmall ? constraints.maxWidth : 250,
                              ),
                              buildAudienceCard(
                                context: context,
                                icon: Icons.cake_rounded,
                                title: 'Restaurantes',
                                text:
                                    'Organização de produtos prontos, personalizados e perecíveis.',
                                width: isSmall ? constraints.maxWidth : 250,
                              ),
                              buildAudienceCard(
                                context: context,
                                icon: Icons.storefront_rounded,
                                title: 'Pequenos comércios',
                                text:
                                    'Mais rastreabilidade, controle interno e apoio à gestão.',
                                width: isSmall ? constraints.maxWidth : 250,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                buildSectionContainer(
                  color: sectionAlt,
                  child: Column(
                    children: [
                      buildSectionTitle(
                        context,
                        'Tecnologias usadas',
                        'Ferramentas, equipamentos e recursos que fazem parte do ecossistema do projeto.',
                        center: true,
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 1000
                              ? 4
                              : constraints.maxWidth > 700
                                  ? 3
                                  : 2;

                          return GridView.builder(
                            itemCount: techs.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.05,
                            ),
                            itemBuilder: (context, index) {
                              final tech = techs[index];
                              return TechCard(item: tech, isDark: isDark);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                buildSectionContainer(
                  child: Column(
                    children: [
                      buildSectionTitle(
                        context,
                        'Contato',
                        'Entre em contato para conhecer melhor o projeto, solicitar apresentação ou tirar dúvidas.',
                        center: true,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          ContactCard(
                            icon: Icons.email_rounded,
                            title: 'E-mail',
                            subtitle: 'milena.silverio2506@gmail.com',
                          ),
                          ContactCard(
                            icon: Icons.phone_rounded,
                            title: 'Telefone',
                            subtitle: '(42) 99952-1562',
                          ),
                          ContactCard(
                            icon: Icons.language_rounded,
                            title: 'Projeto',
                            subtitle: 'TagVálida',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                  color: footerColor,
                  child: const Text(
                    '© 2026 TagVálida — Todos os direitos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 18),
                child: Consumer<ThemeProvider>(
                  builder: (context, controller, _) {
                    final isDark = controller.isDarkMode;

                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: controller.toggleTheme,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            key: ValueKey(isDark),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionContainer({
    required Widget child,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }
}
 