import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'back_circle_button.dart';
import 'sys_widgets.dart';

/// Bandeau vert des ecrans secondaires : retour, grosse icone dans un rond
/// (avec un anneau qui tourne si [loading]), titre et sous-titre.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backPath,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String backPath;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: brandGradient(context),
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 54),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackCircleButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go(backPath),
                  ),
                ),
                const SizedBox(height: 2),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (loading)
                      const SizedBox(
                        width: 112,
                        height: 112,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                          backgroundColor: Color(0x33FFFFFF),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(icon),
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(icon, size: 46, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
