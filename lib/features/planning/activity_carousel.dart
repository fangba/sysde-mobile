import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';

/// Une diapositive : photo (dans assets/images/carousel/) et legende.
class CarouselSlide {
  const CarouselSlide({required this.asset, required this.caption, required this.icon});

  final String asset;
  final String caption;
  final IconData icon;
}

const defaultCarouselSlides = [
  CarouselSlide(
    asset: 'assets/images/carousel/saignee.jpg',
    caption: S.carouselTraining,
    icon: Icons.school_outlined,
  ),
  CarouselSlide(
    asset: 'assets/images/carousel/plantation.jpg',
    caption: S.carouselVisit,
    icon: Icons.park_outlined,
  ),
  CarouselSlide(
    asset: 'assets/images/carousel/rencontre.jpg',
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
    this.height = 210,
    this.autoplay = true,
  });

  final List<CarouselSlide> slides;
  final double height;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: widget.height,
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
    return Semantics(
      image: true,
      label: slide.caption,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            slide.asset,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stack) => DecoratedBox(
              decoration: brandGradient(context),
              child: Center(
                child: Icon(slide.icon, size: 56, color: const Color(0x66FFFFFF)),
              ),
            ),
          ),
          // Voile sombre pour lire la legende sur n'importe quelle photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0x99000000)],
              ),
            ),
          ),
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
