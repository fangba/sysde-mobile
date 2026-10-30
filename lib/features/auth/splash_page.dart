import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import 'login_page.dart';

/// Accueil et connexion sur un seul ecran : un filigrane d'hevea sur un vert
/// tamise, et une feuille blanche qui monte quand on glisse vers le haut
/// (ou qu'on touche) pour decouvrir le formulaire de connexion.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, this.startOpen = false, this.loopAnimations = true});

  /// Feuille deja montee (route /connexion, deconnexion).
  final bool startOpen;

  /// Mouvements en boucle (respiration de l'image, fleches). A couper en test.
  final bool loopAnimations;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  static const _peek = 40.0; // hauteur de la feuille a l'etat ferme
  static const _asset = 'assets/images/auth/saignee.png';

  late final AnimationController _sheet;
  late final AnimationController _intro;
  late final AnimationController _breath;
  late final AnimationController _chevrons;

  @override
  void initState() {
    super.initState();
    _sheet = AnimationController(vsync: this, value: widget.startOpen ? 1 : 0);
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _breath = AnimationController(vsync: this, duration: const Duration(seconds: 9));
    _chevrons = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    if (widget.loopAnimations) {
      _intro.forward();
      _breath.repeat(reverse: true);
      _chevrons.repeat();
    } else {
      _intro.value = 1;
    }
  }

  @override
  void dispose() {
    _sheet.dispose();
    _intro.dispose();
    _breath.dispose();
    _chevrons.dispose();
    super.dispose();
  }

  void _settle(double target) =>
      _sheet.animateTo(target, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);

  void _drag(DragUpdateDetails d, double travel) {
    _sheet.value = (_sheet.value - d.delta.dy / travel).clamp(0.0, 1.0);
  }

  void _dragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    _settle(v < -300 ? 1 : (v > 300 ? 0 : (_sheet.value > 0.5 ? 1 : 0)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = context.scheme;
    final top = Color.lerp(t.actionFrom, Colors.white, 0.3)!;
    final bottom = Color.lerp(scheme.primary, t.deep, 0.2)!;

    return Scaffold(
      backgroundColor: bottom,
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final wide = w >= 600;
          final columnW = wide ? 560.0 : w;
          final sheetH = math.min(math.max(h * 0.56, 460.0), h - 110);
          final travel = sheetH - _peek;
          final side = (w - columnW) / 2 + 28;
          final imageSize = math.min(math.max(w * 1.1, 380.0), h * 0.58);

          return AnimatedBuilder(
            animation: Listenable.merge([_sheet, _intro, _breath, _chevrons]),
            builder: (context, _) {
              final p = _sheet.value;
              final intro = Curves.easeOutCubic.transform(_intro.value);
              final sheetTop = h - _peek - travel * p;
              final breath = Curves.easeInOut.transform(_breath.value);
              final imageScale = (1 + 0.05 * breath) * (1 + 0.12 * p);
              // Image haute : le tronc et le godet restent visibles au-dessus du texte.
              final imageTop = math.max(0.0, (h * 0.6 - imageSize) / 2) - p * h * 0.3;
              final splashOpacity = (1 - p * 2.2).clamp(0.0, 1.0);
              final helloOpacity = ((p - 0.45) / 0.45).clamp(0.0, 1.0);

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [top, bottom],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (w - imageSize) / 2,
                    top: imageTop,
                    width: imageSize,
                    height: imageSize,
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: 0.34 * intro,
                        child: Transform.scale(
                          scale: imageScale,
                          child: Image.asset(
                            _asset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Nom de l'application.
                  Positioned(
                    left: side,
                    top: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Opacity(
                          opacity: (1 - p * 2.2).clamp(0.0, 1.0) * intro,
                          child: Text(
                            S.appName,
                            style: TextStyle(
                              color: t.deep,
                              fontSize: wide ? 28 : 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Zone de glisse : tout l'ecran sous la feuille.
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (d) => _drag(d, travel),
                      onVerticalDragEnd: _dragEnd,
                      onTap: () => _settle(p < 0.5 ? 1 : p),
                    ),
                  ),
                  // Texte d'accueil (etat ferme).
                  Positioned(
                    left: side,
                    right: side,
                    bottom: _peek + 128 - 28 * (1 - intro),
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: splashOpacity * intro,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: S.welcomeSwipe, style: TextStyle(color: t.deep)),
                              const TextSpan(
                                text: S.welcomeRest,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: wide ? 30 : 24,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Fleches animees.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _peek + 28,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: (1 - p * 3).clamp(0.0, 1.0) * intro,
                        child: _Chevrons(phase: _chevrons.value),
                      ),
                    ),
                  ),
                  // Titre de connexion (etat ouvert).
                  Positioned(
                    left: side,
                    right: side,
                    bottom: h - sheetTop + 24,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: helloOpacity,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - helloOpacity)),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${S.loginGreeting}\n',
                                  style: TextStyle(color: t.deep),
                                ),
                                const TextSpan(
                                  text: S.loginWelcomeBack,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: wide ? 38 : 32,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Feuille blanche.
                  Positioned(
                    left: (w - columnW) / 2,
                    width: columnW,
                    top: sheetTop,
                    height: sheetH,
                    child: Material(
                      color: scheme.surface,
                      elevation: 6,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Semantics(
                            button: true,
                            label: p < 0.5 ? S.swipeUp : S.closeSheet,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onVerticalDragUpdate: (d) => _drag(d, travel),
                              onVerticalDragEnd: _dragEnd,
                              onTap: () => _settle(p < 0.5 ? 1 : 0),
                              child: SizedBox(
                                height: _peek,
                                width: double.infinity,
                                child: Center(
                                  child: Opacity(
                                    opacity: ((p - 0.2) / 0.4).clamp(0.0, 1.0),
                                    child: Container(
                                      width: 44,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: scheme.onSurface,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: IgnorePointer(
                              ignoring: p < 0.6,
                              child: ExcludeSemantics(
                                excluding: p < 0.6,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                  child: LoginForm(reveal: ((p - 0.45) / 0.55).clamp(0.0, 1.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Trois chevrons qui s'allument l'un apres l'autre, de bas en haut.
class _Chevrons extends StatelessWidget {
  const _Chevrons({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: S.swipeUp,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Positioned(
                  bottom: 6.0 + i * 12,
                  child: Opacity(
                    opacity: 0.2 + 0.8 * _pulse(phase - i * 0.16),
                    child: const Icon(Icons.keyboard_arrow_up, size: 34, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static double _pulse(double v) => 0.5 + 0.5 * math.cos(2 * math.pi * (v - 0.5));
}
