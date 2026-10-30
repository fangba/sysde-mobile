import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/back_circle_button.dart';
import '../../core/widgets/sys_widgets.dart';

/// Page a photo : image en haut, feuille blanche aux coins arrondis par-dessus
/// (titre centre puis `children`), bouton retour rond en haut a gauche.
class PhotoSheetPage extends StatelessWidget {
  const PhotoSheetPage({
    super.key,
    required this.title,
    required this.fallbackIcon,
    required this.backPath,
    required this.children,
    this.titleColor,
  });

  final String title;

  /// Icone affichee sur fond vert tant que la photo est absente.
  final IconData fallbackIcon;
  final String backPath;
  final List<Widget> children;

  /// Couleur du titre (par defaut celle du texte), pour le mettre en exergue.
  final Color? titleColor;

  static const _photo = 'assets/images/carousel/plantation.jpg';
  static const _photoHeight = 230.0;
  static const _sheetTop = 196.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _photoHeight,
            child: Image.asset(
              _photo,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stack) => DecoratedBox(
                decoration: brandGradient(context),
                child: Center(
                  child: Icon(fallbackIcon, size: 72, color: const Color(0x66FFFFFF)),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: _sheetTop,
            child: Material(
              color: context.scheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: BackCircleButton(
                  // Retour fluide : on depile la page quand c'est possible
                  // (l'ecran precedent garde sa section et sa page).
                  onPressed: () => context.canPop() ? context.pop() : context.go(backPath),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
