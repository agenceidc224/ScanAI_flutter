// pages/auth_page.dart
// Version adaptée pour mobile et desktop avec thème sombre/clair
import 'package:clinimage_ai/models/signup.dart';
import 'package:clinimage_ai/services/api/login.dart';
import 'package:clinimage_ai/services/network_connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../providers/plateforme_provider.dart';
import '../utils/couleurs.dart';
import '../widgets/custom_button.dart';

// ============ SECTION GAUCHE AVEC CARROUSEL D'IMAGES ============
/*class LeftAnimatedSection extends StatefulWidget {
  const LeftAnimatedSection({super.key});

  @override
  State<LeftAnimatedSection> createState() => _LeftAnimatedSectionState();
}

class _LeftAnimatedSectionState extends State<LeftAnimatedSection>
    with TickerProviderStateMixin {
  late final AnimationController _floatingController;
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<String> _images = [
    'assets/image1.webp',
    'assets/image2.jpg',
    'assets/image3.png',
  ];

  final List<Map<String, String>> _content = [
    {
      'title': 'Diagnostic Précis',
      'description':
          'Notre IA analyse les images médicales avec une précision de 98%',
      'icon': '🎯',
      'subtitle': 'Reconnue par l\'Académie de Médecine',
    },
    {
      'title': 'Analyse Rapide',
      'description': 'Obtenez des résultats en quelques secondes seulement',
      'icon': '⚡',
      'subtitle': 'Traitement en temps réel',
    },
    {
      'title': 'Collaboration Facile',
      'description':
          'Partagez facilement les résultats avec votre équipe médicale',
      'icon': '🤝',
      'subtitle': 'Travail d\'équipe simplifié',
    },
  ];

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.medicalDarkBlue,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 1.0, end: 1.1),
                duration: const Duration(seconds: 20),
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_images[index]),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            AppColors.black.withAlpha((0.5 * 255).toInt()),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 5 * _floatingController.value),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.white.withAlpha((0.3 * 255).toInt()),
                                AppColors.white.withAlpha((0.1 * 255).toInt()),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.white.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 35,
                            color: AppColors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          'IA Médicale Avancée',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ClinImage AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Plateforme d\'imagerie médicale assistée par IA',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Container(
                      key: ValueKey(_currentPage),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withAlpha((0.2 * 255).toInt()),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.white.withAlpha(
                                    (0.3 * 255).toInt(),
                                  ),
                                  AppColors.white.withAlpha(
                                    (0.1 * 255).toInt(),
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _content[_currentPage]['icon'] ?? '🏥',
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _content[_currentPage]['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _content[_currentPage]['subtitle']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.white.withAlpha(
                                (0.8 * 255).toInt(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _content[_currentPage]['description']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white.withAlpha(
                                (0.95 * 255).toInt(),
                              ),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: _currentPage == index
                              ? LinearGradient(
                                  colors: [
                                    AppColors.white,
                                    AppColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ],
                                )
                              : null,
                          color: _currentPage == index
                              ? null
                              : AppColors.white.withAlpha((0.3 * 255).toInt()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModernStatItem('5000+', 'Patients', Icons.people),
                      _buildModernStatItem('98%', 'Précision', Icons.science),
                      _buildModernStatItem(
                        '24/7',
                        'Support',
                        Icons.support_agent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.white),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: AppColors.white.withAlpha((0.8 * 255).toInt()),
          ),
        ),
      ],
    );
  }
}
*/
// ============ SECTION GAUCHE AVEC CARROUSEL D'IMAGES ============
/*class LeftAnimatedSection extends StatefulWidget {
  const LeftAnimatedSection({super.key});

  @override
  State<LeftAnimatedSection> createState() => _LeftAnimatedSectionState();
}

class _LeftAnimatedSectionState extends State<LeftAnimatedSection>
    with TickerProviderStateMixin {
  late final AnimationController _floatingController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<String> _images = [
    'assets/image1.webp',
    'assets/image2.jpg',
    'assets/image3.png',
  ];

  final List<Map<String, String>> _content = [
    {
      'title': 'Diagnostic Précis',
      'description':
          'Notre IA analyse les images médicales avec une précision de 98%',
      'icon': '🎯',
      'subtitle': 'Reconnue par l\'Académie de Médecine',
    },
    {
      'title': 'Analyse Rapide',
      'description': 'Obtenez des résultats en quelques secondes seulement',
      'icon': '⚡',
      'subtitle': 'Traitement en temps réel',
    },
    {
      'title': 'Collaboration Facile',
      'description':
          'Partagez facilement les résultats avec votre équipe médicale',
      'icon': '🤝',
      'subtitle': 'Travail d\'équipe simplifié',
    },
  ];

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, // ← dégradé bas → haut
          end: Alignment.topCenter,
          colors: [
            AppColors.medicalDarkBlue,
            AppColors.secondary,
            AppColors.primary,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // ── Images en mosaïque 3 colonnes ─────────────────
          _buildMosaicImages(),

          // ── Dégradé de superposition bas → haut ───────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.medicalDarkBlue.withAlpha(240),
                    AppColors.secondary.withAlpha(180),
                    AppColors.primary.withAlpha(100),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Particules flottantes décoratives ─────────────
          ..._buildFloatingParticles(),

          // ── Contenu principal ──────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo flottant
                  _buildFloatingLogo(),
                  const SizedBox(height: 24),

                  // Badge
                  _buildBadge(),
                  const SizedBox(height: 16),

                  // Titre
                  _buildTitle(),
                  const SizedBox(height: 10),

                  // Sous-titre
                  _buildSubtitle(),

                  const Spacer(),

                  // Carte de contenu animée
                  _buildContentCard(),
                  const SizedBox(height: 24),

                  // Indicateurs de page
                  _buildPageIndicators(),
                  const SizedBox(height: 24),

                  // Stats
                  _buildStats(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mosaïque : 3 colonnes qui défilent à vitesses différentes ──
  Widget _buildMosaicImages() {
    return Positioned.fill(
      child: Row(
        children: List.generate(3, (colIndex) {
          // Décalage vertical différent par colonne pour l'effet mosaïque
          final offsets = [0.0, -60.0, -120.0];
          return Expanded(
            child: Transform.translate(
              offset: Offset(0, offsets[colIndex]),
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  // Chaque colonne défile à une vitesse légèrement différente
                  final speed = (colIndex + 1) * 0.3;
                  return Transform.translate(
                    offset: Offset(0, _shimmerController.value * 40 * speed),
                    child: child,
                  );
                },
                child: Column(
                  children: List.generate(_images.length, (rowIndex) {
                    final imgIndex = (colIndex + rowIndex) % _images.length;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(_images[imgIndex]),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Particules flottantes ──────────────────────────────────────
  List<Widget> _buildFloatingParticles() {
    final positions = [
      const Offset(0.15, 0.2),
      const Offset(0.75, 0.15),
      const Offset(0.85, 0.5),
      const Offset(0.1, 0.7),
      const Offset(0.6, 0.08),
    ];
    final sizes = [6.0, 4.0, 8.0, 5.0, 3.0];
    final delays = [0.0, 0.3, 0.6, 0.1, 0.8];

    return List.generate(positions.length, (i) {
      return Positioned(
        left: MediaQuery.of(context).size.width * 0.5 * positions[i].dx,
        top: MediaQuery.of(context).size.height * positions[i].dy,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final t = (_pulseController.value + delays[i]) % 1.0;
            return Opacity(
              opacity: (0.3 + 0.5 * t).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, -8 * t),
                child: Container(
                  width: sizes[i],
                  height: sizes[i],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withAlpha((0.6 * 255).toInt()),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withAlpha((0.4 * 255).toInt()),
                        blurRadius: sizes[i] * 2,
                        spreadRadius: sizes[i] * 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── Logo flottant ──────────────────────────────────────────────
  Widget _buildFloatingLogo() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 6 * _floatingController.value),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white.withAlpha((0.35 * 255).toInt()),
                  AppColors.white.withAlpha((0.1 * 255).toInt()),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.white.withAlpha((0.4 * 255).toInt()),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha((0.4 * 255).toInt()),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              size: 34,
              color: AppColors.white,
            ),
          ),
        );
      },
    );
  }

  // ── Badge ──────────────────────────────────────────────────────
  Widget _buildBadge() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white.withAlpha((0.25 * 255).toInt()),
                AppColors.white.withAlpha((0.1 * 255).toInt()),
                AppColors.white.withAlpha((0.25 * 255).toInt()),
              ],
              stops: [0.0, _shimmerController.value.clamp(0.0, 1.0), 1.0],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.white.withAlpha((0.35 * 255).toInt()),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 13, color: Colors.amber),
              SizedBox(width: 7),
              Text(
                'IA Médicale Avancée',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Titre ──────────────────────────────────────────────────────
  Widget _buildTitle() {
    return const Text(
      'ClinImage AI',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        height: 1.1,
        letterSpacing: -0.5,
        shadows: [
          Shadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
    );
  }

  // ── Sous-titre ─────────────────────────────────────────────────
  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withAlpha((0.15 * 255).toInt()),
        ),
      ),
      child: Text(
        'Plateforme d\'imagerie médicale assistée par IA',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.white.withAlpha((0.92 * 255).toInt()),
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ── Carte de contenu animée ────────────────────────────────────
  Widget _buildContentCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentPage),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white.withAlpha((0.18 * 255).toInt()),
              AppColors.white.withAlpha((0.08 * 255).toInt()),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.white.withAlpha((0.25 * 255).toInt()),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha((0.15 * 255).toInt()),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône avec fond glassmorphism
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.white.withAlpha((0.3 * 255).toInt()),
                    AppColors.white.withAlpha((0.1 * 255).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.white.withAlpha((0.3 * 255).toInt()),
                ),
              ),
              child: Center(
                child: Text(
                  _content[_currentPage]['icon'] ?? '🏥',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _content[_currentPage]['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _content[_currentPage]['subtitle']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.white.withAlpha((0.7 * 255).toInt()),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _content[_currentPage]['description']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withAlpha((0.9 * 255).toInt()),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Indicateurs de page ────────────────────────────────────────
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_images.length, (index) {
        final isActive = _currentPage == index;
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? AppColors.white
                  : AppColors.white.withAlpha((0.35 * 255).toInt()),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.white.withAlpha((0.5 * 255).toInt()),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────
  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('5000+', 'Patients', Icons.people_alt_rounded),
        _buildStatDivider(),
        _buildStatItem('98%', 'Précision', Icons.track_changes_rounded),
        _buildStatDivider(),
        _buildStatItem('24/7', 'Support', Icons.headset_mic_rounded),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.white.withAlpha((0.2 * 255).toInt()),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -2 * _pulseController.value),
          child: child,
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha((0.15 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.white.withAlpha((0.2 * 255).toInt()),
              ),
            ),
            child: Icon(icon, size: 18, color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: -0.3,
              shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.white.withAlpha((0.75 * 255).toInt()),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
*/
class LeftAnimatedSection extends StatefulWidget {
  const LeftAnimatedSection({super.key});

  @override
  State<LeftAnimatedSection> createState() => _LeftAnimatedSectionState();
}

class _LeftAnimatedSectionState extends State<LeftAnimatedSection>
    with TickerProviderStateMixin {
  late final AnimationController _floatingController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<String> _images = [
    'assets/image1.webp',
    'assets/image2.jpg',
    'assets/image3.png',
    'assets/image4.jpg',
  ];

  final List<Map<String, String>> _content = [
    {
      'title': 'Diagnostic Précis',
      'description':
          'Notre IA analyse les images médicales avec une précision de 98%',
      'icon': '🎯',
      'subtitle': 'Reconnue par l\'Académie de Médecine',
    },
    {
      'title': 'Analyse Rapide',
      'description': 'Obtenez des résultats en quelques secondes seulement',
      'icon': '⚡',
      'subtitle': 'Traitement en temps réel',
    },
    {
      'title': 'Collaboration Facile',
      'description':
          'Partagez facilement les résultats avec votre équipe médicale',
      'icon': '🤝',
      'subtitle': 'Travail d\'équipe simplifié',
    },
    {
      'title': 'Une solution nationale Guinée ',
      'description':
          'ClinImage AI est une solution d\'imagerie médicale assistée par IA développée en Guinée, conçue pour répondre aux besoins spécifiques du système de santé guinéen.',
      'icon': '🇬🇳',
      'subtitle': 'Solution locale pour un impact global',
    },
  ];

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _pageController.hasClients) {
        _fadeController.reset();
        _fadeController.forward();
        _pageController.animateToPage(
          (_currentPage + 1) % _images.length,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        children: [
          // ── Carrousel d'images avec effet zoom ──────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _fadeController.reset();
                _fadeController.forward();
              },
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.08),
                  duration: const Duration(seconds: 6),
                  curve: Curves.easeInOut,
                  builder: (context, scale, _) {
                    return Transform.scale(
                      scale: scale,
                      child: Image.asset(
                        _images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Dégradé bas → haut (couleur → transparent) ──────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.45, 0.75, 1.0],
                  colors: [
                    AppColors.medicalDarkBlue.withAlpha((0.98 * 255).toInt()),
                    AppColors.primary.withAlpha((0.85 * 255).toInt()),
                    AppColors.primary.withAlpha((0.3 * 255).toInt()),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Légère teinte sombre sur le haut ─────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    AppColors.black.withAlpha((0.35 * 255).toInt()),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu ───────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo flottant
                  AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, 6 * _floatingController.value),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.white.withAlpha(
                                  (0.15 * 255).toInt(),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.white.withAlpha(
                                    (0.35 * 255).toInt(),
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                size: 28,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ClinImage AI',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                // Badge animé
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, _) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withAlpha(
                                          ((0.15 +
                                                      0.1 *
                                                          _pulseController
                                                              .value) *
                                                  255)
                                              .toInt(),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.amber.withAlpha(
                                            ((0.4 +
                                                        0.2 *
                                                            _pulseController
                                                                .value) *
                                                    255)
                                                .toInt(),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 10,
                                            color: Colors.amber.withAlpha(
                                              ((0.8 +
                                                          0.2 *
                                                              _pulseController
                                                                  .value) *
                                                      255)
                                                  .toInt(),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'IA Médicale Avancée',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.amber,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // ── Carte de contenu animée ──────────────────
                  FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _fadeController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          key: ValueKey(_currentPage),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white.withAlpha(
                              (0.1 * 255).toInt(),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.white.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withAlpha(
                                  (0.15 * 255).toInt(),
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icône
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withAlpha(
                                    (0.15 * 255).toInt(),
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    _content[_currentPage]['icon'] ?? '🏥',
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Textes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _content[_currentPage]['title']!,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white.withAlpha(
                                          (0.12 * 255).toInt(),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _content[_currentPage]['subtitle']!,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.white.withAlpha(
                                            (0.85 * 255).toInt(),
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _content[_currentPage]['description']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.white.withAlpha(
                                          (0.9 * 255).toInt(),
                                        ),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Indicateurs + stats ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Points de navigation
                      Row(
                        children: List.generate(
                          _images.length,
                          (index) => GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: _currentPage == index ? 28 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentPage == index
                                    ? AppColors.white
                                    : AppColors.white.withAlpha(
                                        (0.35 * 255).toInt(),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Compteur de page
                      Text(
                        '${_currentPage + 1} / ${_images.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.white.withAlpha((0.6 * 255).toInt()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Stats ────────────────────────────────────
                  Row(
                    children: [
                      _buildStatItem('5000+', 'Patients', Icons.people_rounded),
                      _buildDivider(),
                      _buildStatItem(
                        '98%',
                        'Précision',
                        Icons.track_changes_rounded,
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        '24/7',
                        'Support',
                        Icons.headset_mic_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.white.withAlpha((0.2 * 255).toInt()),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.white.withAlpha((0.8 * 255).toInt()),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.white.withAlpha((0.65 * 255).toInt()),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ EN-TÊTE MOBILE ============
class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.medicalDarkBlue,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha((0.2 * 255).toInt()),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.white.withAlpha((0.3 * 255).toInt()),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 26,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ClinImage AI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'IA Médicale Avancée',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white.withAlpha((0.85 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Plateforme d\'imagerie médicale assistée par IA',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withAlpha((0.9 * 255).toInt()),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildStatChip('5000+', 'Patients', Icons.people),
              const SizedBox(width: 12),
              _buildStatChip('98%', 'Précision', Icons.science),
              const SizedBox(width: 12),
              _buildStatChip('24/7', 'Support', Icons.support_agent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.15 * 255).toInt()),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.white.withAlpha((0.25 * 255).toInt()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.white),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.white.withAlpha((0.8 * 255).toInt()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ PAGE PRINCIPALE AUTH ============
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool _isLoginMode = true;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformService = context.watch<PlatformService>();
    final isMobile = platformService.isMobile;

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const _MobileHeader(),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: RightWrapper(
                  isLoginMode: _isLoginMode,
                  onToggleMode: (isLogin) {
                    setState(() => _isLoginMode = isLogin);
                  },
                  isMobile: isMobile,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 1, child: LeftAnimatedSection()),
          Expanded(
            flex: 1,
            child: SlideTransition(
              position: _slideAnimation,
              child: RightWrapper(
                isLoginMode: _isLoginMode,
                isMobile: isMobile,
                onToggleMode: (isLogin) {
                  setState(() => _isLoginMode = isLogin);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ WRAPPER DROIT AVEC THÈME ============
class RightWrapper extends StatefulWidget {
  final bool isLoginMode;
  final Function(bool)? onToggleMode;
  final bool isMobile;

  const RightWrapper({
    super.key,
    required this.isLoginMode,
    this.onToggleMode,
    required this.isMobile,
  });

  @override
  State<RightWrapper> createState() => _RightWrapperState();
}

class _RightWrapperState extends State<RightWrapper> {
  late bool _isLoginMode;
  late NetworkConnectivityService _connectivityService;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.isLoginMode;
    _connectivityService = NetworkConnectivityService();
    _connectivityService.init();
    _isOnline = _connectivityService.isConnected;
    _connectivityService.addListener(_onConnectivityChanged);
    _connectivityService.checkConnectionManually().then((connected) {
      if (mounted) setState(() => _isOnline = connected);
    });
  }

  void _onConnectivityChanged() {
    setState(() => _isOnline = _connectivityService.isConnected);
    // if (_isOnline) _syncHistoryWithServer();
  }

  @override
  void didUpdateWidget(RightWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoginMode != oldWidget.isLoginMode) {
      setState(() => _isLoginMode = widget.isLoginMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBgColor = isDark ? AppColors.darkCard : AppColors.white;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: widget.isMobile
                ? const EdgeInsets.symmetric(horizontal: 35.0, vertical: 30)
                : const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withAlpha((0.05 * 255).toInt()),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildModernTabButton(
                        title: 'Connexion',
                        isActive: _isLoginMode,
                        onTap: () {
                          setState(() => _isLoginMode = true);
                          widget.onToggleMode?.call(true);
                        },
                      ),
                      _buildModernTabButton(
                        title: 'Inscription',
                        isActive: !_isLoginMode,
                        onTap: () {
                          setState(() => _isLoginMode = false);
                          widget.onToggleMode?.call(false);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.2, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                  child: _isLoginMode
                      ? ModernLoginForm(
                          key: const ValueKey('login'),
                          isDark: isDark,
                          isConnected: _isOnline,
                        )
                      : ModernSignUpForm(
                          key: const ValueKey('signup'),
                          isDark: isDark,
                          isConnected: _isOnline, // ← ajout
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  )
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? AppColors.white : inactiveColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ============ FORMULAIRE DE CONNEXION AVEC THÈME ============
class ModernLoginForm extends StatefulWidget {
  final bool isDark;
  final bool isConnected; // Simule la connectivité pour l'instant
  const ModernLoginForm({
    super.key,
    required this.isDark,
    required this.isConnected,
  });

  @override
  State<ModernLoginForm> createState() => _ModernLoginFormState();
}

class _ModernLoginFormState extends State<ModernLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
      widget.isConnected,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/analysis');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.white),
              SizedBox(width: 12),
              Text('Connexion réussie !'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final errorMessage = result.message.isNotEmpty
          ? result.message
          : result.statusCode == 0
          ? 'Impossible de joindre le serveur.'
          : 'Erreur ${result.statusCode} : ${result.message}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final inputBgColor = widget.isDark
        ? AppColors.darkSurface
        : AppColors.white;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.login,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Connectez-vous à votre compte',
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: textColor),
            decoration: _buildInputDecoration(
              'Email',
              'exemple@email.com',
              Icons.email_outlined,
              inputBgColor,
              textColor,
              secondaryTextColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
              prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: secondaryTextColor,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: inputBgColor,
              labelStyle: TextStyle(color: secondaryTextColor),
              hintStyle: TextStyle(
                color: secondaryTextColor.withAlpha((0.6 * 255).toInt()),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mot de passe requis';
              if (value.length < 6) return '6 caractères minimum';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) =>
                          setState(() => _rememberMe = value ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Se souvenir de moi',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                ],
              ),
              CustomTextButton(
                text: 'Mot de passe oublié ?',
                onPressed: () {},
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Se connecter',
            onPressed: _handleLogin,
            isLoading: _isLoading,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    IconData icon,
    Color bgColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: secondaryTextColor),
      filled: true,
      fillColor: bgColor,
      labelStyle: TextStyle(color: secondaryTextColor),
      hintStyle: TextStyle(
        color: secondaryTextColor.withAlpha((0.6 * 255).toInt()),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

// ============ FORMULAIRE D'INSCRIPTION AVEC THÈME ============
class ModernSignUpForm extends StatefulWidget {
  final bool isDark;
  final bool isConnected;
  const ModernSignUpForm({
    super.key,
    required this.isDark,
    required this.isConnected,
  });

  @override
  State<ModernSignUpForm> createState() => _ModernSignUpFormState();
}

class _ModernSignUpFormState extends State<ModernSignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _posteController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _anneeServiceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _fullPhoneNumber = '';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  bool _isNomValid = false;
  bool _isPrenomValid = false;
  bool _isPosteValid = false;
  bool _isTelephoneValid = false;
  bool _isEmailValid = false;
  bool _isAnneeServiceValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  final List<String> _postes = [
    'Radiologue',
    'Médecin généraliste',
    'Cardiologue',
    'Neurologue',
    'Pédiatre',
    'Gynécologue',
    'Chirurgien',
    'Infirmier',
    'Technicien en imagerie',
    'Autre',
  ];

  bool get _isNextEnabled {
    switch (_currentStep) {
      case 0:
        return _nomController.text.isNotEmpty &&
            _prenomController.text.isNotEmpty &&
            _posteController.text.isNotEmpty;
      case 1:
        return _fullPhoneNumber.isNotEmpty &&
            _fullPhoneNumber.length >= 10 &&
            _emailController.text.isNotEmpty &&
            _emailController.text.contains('@') &&
            _anneeServiceController.text.isNotEmpty &&
            int.tryParse(_anneeServiceController.text) != null;
      case 2:
        return _passwordController.text.isNotEmpty &&
            _passwordController.text.length >= 6 &&
            _confirmPasswordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
      default:
        return false;
    }
  }

  bool get _isSignUpEnabled {
    return _nomController.text.isNotEmpty &&
        _prenomController.text.isNotEmpty &&
        _posteController.text.isNotEmpty &&
        _fullPhoneNumber.isNotEmpty &&
        _fullPhoneNumber.length >= 10 &&
        _emailController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _anneeServiceController.text.isNotEmpty &&
        int.tryParse(_anneeServiceController.text) != null &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 6 &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _posteController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _anneeServiceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateValidations() {
    setState(() {
      _isNomValid = _nomController.text.isNotEmpty;
      _isPrenomValid = _prenomController.text.isNotEmpty;
      _isPosteValid = _posteController.text.isNotEmpty;
      _isTelephoneValid =
          _fullPhoneNumber.isNotEmpty && _fullPhoneNumber.length >= 10;
      _isEmailValid =
          _emailController.text.isNotEmpty &&
          _emailController.text.contains('@');
      _isAnneeServiceValid =
          _anneeServiceController.text.isNotEmpty &&
          int.tryParse(_anneeServiceController.text) != null;
      _isPasswordValid =
          _passwordController.text.isNotEmpty &&
          _passwordController.text.length >= 6;
      _isConfirmPasswordValid =
          _confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text;
    });
  }

  // _handleSignUp — remplacer l'appel AuthService.signUp
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate() && _isSignUpEnabled) {
      setState(() => _isLoading = true);

      final result = await AuthService.signUp(
        SignUpData(
          id: DateTime.now().toString(),
          nom: _nomController.text,
          prenom: _prenomController.text,
          poste: _posteController.text,
          telephone: _fullPhoneNumber,
          email: _emailController.text,
          anneeService: _anneeServiceController.text,
          password: _passwordController.text,
        ),
        widget.isConnected, // ← ajout
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        Navigator.pushReplacementNamed(context, '/analysis');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.white),
                const SizedBox(width: 12),
                const Text('Inscription réussie !'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(result.message)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final inputBgColor = widget.isDark
        ? AppColors.darkSurface
        : AppColors.white;
    final cardBgColor = widget.isDark ? AppColors.darkCard : AppColors.white;

    return Form(
      key: _formKey,
      onChanged: _updateValidations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Rejoignez notre communauté',
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index <= _currentStep
                        ? AppColors.primary
                        : (widget.isDark
                              ? AppColors.darkDivider
                              : AppColors.grey.withAlpha((0.3 * 255).toInt())),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          if (_currentStep == 0) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nomController,
                        style: TextStyle(color: textColor),
                        decoration: _buildInputDecoration(
                          'Nom',
                          'Votre nom',
                          Icons.person_outline,
                          inputBgColor,
                          textColor,
                          secondaryTextColor,
                        ),
                        onChanged: (_) => _updateValidations(),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nom requis' : null,
                      ),
                      if (_isNomValid && _nomController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Nom valide',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _prenomController,
                        style: TextStyle(color: textColor),
                        decoration: _buildInputDecoration(
                          'Prénom',
                          'Votre prénom',
                          Icons.person_outline,
                          inputBgColor,
                          textColor,
                          secondaryTextColor,
                        ),
                        onChanged: (_) => _updateValidations(),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Prénom requis' : null,
                      ),
                      if (_isPrenomValid && _prenomController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Prénom valide',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _posteController.text.isEmpty
                      ? null
                      : _posteController.text,
                  dropdownColor: cardBgColor,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    'Poste / Spécialité',
                    'Sélectionnez votre poste',
                    Icons.work_outline,
                    inputBgColor,
                    textColor,
                    secondaryTextColor,
                  ),
                  items: _postes
                      .map(
                        (poste) => DropdownMenuItem(
                          value: poste,
                          child: Text(
                            poste,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _posteController.text = value ?? '');
                    _updateValidations();
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Poste requis' : null,
                ),
                if (_isPosteValid && _posteController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Poste sélectionné',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (_currentStep == 1) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntlPhoneField(
                  controller: _telephoneController,
                  style: TextStyle(color: textColor),
                  dropdownTextStyle: TextStyle(color: textColor),
                  dropdownIcon: Icon(
                    Icons.arrow_drop_down,
                    color: secondaryTextColor,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    hintText: '620 00 00 00',
                    filled: true,
                    fillColor: inputBgColor,
                    labelStyle: TextStyle(color: secondaryTextColor),
                    hintStyle: TextStyle(
                      color: secondaryTextColor.withAlpha((0.6 * 255).toInt()),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                  ),
                  initialCountryCode: 'GN', // Guinée par défaut, à adapter
                  invalidNumberMessage: 'Numéro invalide',
                  onChanged: (phone) {
                    _fullPhoneNumber =
                        phone.completeNumber; // ex: +224620000000
                    debugPrint('📞 Téléphone complet : $_fullPhoneNumber');
                    _updateValidations();
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Téléphone requis';
                    }
                    return null; // intl_phone_field valide le format lui-même
                  },
                ),
                if (_isTelephoneValid)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Téléphone valide',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor),
                      decoration: _buildInputDecoration(
                        'Email',
                        'exemple@email.com',
                        Icons.email_outlined,
                        inputBgColor,
                        textColor,
                        secondaryTextColor,
                      ),
                      onChanged: (_) => _updateValidations(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    if (_isEmailValid &&
                        _emailController.text.isNotEmpty &&
                        _emailController.text.contains('@'))
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Email valide',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _anneeServiceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: _buildInputDecoration(
                        'Années de service',
                        'Ex: 5',
                        Icons.calendar_today,
                        inputBgColor,
                        textColor,
                        secondaryTextColor,
                      ),
                      onChanged: (_) => _updateValidations(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Années requises';
                        final years = int.tryParse(v);
                        return (years == null || years < 0)
                            ? 'Valeur invalide'
                            : null;
                      },
                    ),
                    if (_isAnneeServiceValid &&
                        _anneeServiceController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Années valides',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
          if (_currentStep == 2) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor),
                  onChanged: (_) => _updateValidations(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Au moins 6 caractères',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: secondaryTextColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: secondaryTextColor,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: inputBgColor,
                    labelStyle: TextStyle(color: secondaryTextColor),
                    hintStyle: TextStyle(
                      color: secondaryTextColor.withAlpha((0.6 * 255).toInt()),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (v.length < 6) return '6 caractères minimum';
                    return null;
                  },
                ),
                if (_isPasswordValid &&
                    _passwordController.text.isNotEmpty &&
                    _passwordController.text.length >= 6)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Mot de passe valide',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: TextStyle(color: textColor),
                  onChanged: (_) => _updateValidations(),
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Retapez votre mot de passe',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: secondaryTextColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: secondaryTextColor,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    filled: true,
                    fillColor: inputBgColor,
                    labelStyle: TextStyle(color: secondaryTextColor),
                    hintStyle: TextStyle(
                      color: secondaryTextColor.withAlpha((0.6 * 255).toInt()),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirmation requise';
                    }
                    if (v != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }

                    return null;
                  },
                ),
                if (_isConfirmPasswordValid &&
                    _confirmPasswordController.text.isNotEmpty &&
                    _passwordController.text == _confirmPasswordController.text)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Mots de passe identiques',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: SecondaryButton(
                    text: 'Précédent',
                    onPressed: () => setState(() => _currentStep--),
                    icon: Icons.arrow_back,
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: _currentStep < 2
                    ? PrimaryButton(
                        text: 'Suivant',
                        onPressed: _isNextEnabled
                            ? () => setState(() => _currentStep++)
                            : null,
                        icon: Icons.arrow_forward,
                      )
                    : PrimaryButton(
                        text: 'S\'inscrire',
                        onPressed: _isSignUpEnabled ? _handleSignUp : null,
                        isLoading: _isLoading,
                        icon: Icons.check,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    IconData icon,
    Color bgColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: secondaryTextColor),
      filled: true,
      fillColor: bgColor,
      labelStyle: TextStyle(color: secondaryTextColor),
      hintStyle: TextStyle(
        color: secondaryTextColor.withAlpha((0.6 * 255).toInt()),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
