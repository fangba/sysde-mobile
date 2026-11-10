import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';

/// Une diapositive : photo (dans assets/images/carousel/) et legende.
class CarouselSlide {
  const CarouselSlide({this.asset, required this.caption, required this.icon});

  /// Chemin de l'image ; null = fond degrade avec icone.
  final String? asset;
  final String caption;
  final IconData icon;
}

const defaultCarouselSlides = [
  CarouselSlide(
    asset: 'assets/images/carousel/formation_saignee.jpg',
    caption: S.carouselTraining,
    icon: Icons.school_outlined,
  ),
  CarouselSlide(
    asset: 'assets/images/carousel/visite_plantation.jpg',
    caption: S.carouselVisit,
    icon: Icons.park_outlined,
  ),
  CarouselSlide(
    asset: 'assets/images/carousel/rencontre_technique.jpg',
    caption: S.carouselMeeting,
    icon: Icons.groups_outlined,
  ),
];

/// Carrousel d'images : defile seul toutes les 5 s, se commande au doigt,
/// pastilles en bas. Une photo absente est remplacee par un fond vert avec
/// l'icone de la legende, l'ecran reste utilisable sans les images.
class ActivityCarousel extends StatefulWidget {
  const ActivityCarousel({
    super.key,
    this.slides = defaultCarouselSlides,
    this.height,
    this.autoplay = true,
  });

  final List<CarouselSlide> slides;
  /// Hauteur fixe ; sinon calculee d'apres le ratio des images (largeur / 2,25 ; images recadrees a ce ratio).
  final double? height;
  final bool autoplay;

  @override
  State<ActivityCarousel> createState() => _ActivityCarouselState();
}

class _ActivityCarouselState extends State<ActivityCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoplay && widget.slides.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _next());
    }
  }

  void _next() {
    if (!_controller.hasClients) return;
    final target = (_page + 1) % widget.slides.length;
    unawaited(
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final height = widget.height ?? (c.maxWidth / 2.25).clamp(130.0, 230.0);
        return _buildCarousel(height);
      },
    );
  }

  Widget _buildCarousel(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _Slide(slide: widget.slides[i]),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page ? Colors.white : const Color(0x80FFFFFF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final CarouselSlide slide;

  @override
  Widget build(BuildContext context) {
    if (slide.asset == null) return _SlideFallback(slide: slide);
    // L'image porte deja son sous-titre : aucun texte n'est ajoute par l'application.
    return Semantics(
      image: true,
      label: slide.caption,
      child: Image.asset(
        slide.asset!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stack) => _SlideFallback(slide: slide),
      ),
    );
  }
}

class _SlideFallback extends StatelessWidget {
  const _SlideFallback({required this.slide});

  final CarouselSlide slide;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: brandGradient(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: Icon(slide.icon, size: 56, color: const Color(0x66FFFFFF))),
          Positioned(
            left: 16,
            right: 16,
            bottom: 28,
            child: ExcludeSemantics(
              child: Text(
                slide.caption,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(blurRadius: 4, color: context.tokens.deep)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
