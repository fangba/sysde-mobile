import 'package:flutter/material.dart';

import '../strings.dart';

/// Bouton retour rond, sombre et translucide, lisible sur une photo comme sur
/// un bandeau vert. Zone tactile de 48 dp.
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: S.back,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0x66000000),
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.chevron_left, size: 30),
    );
  }
}
