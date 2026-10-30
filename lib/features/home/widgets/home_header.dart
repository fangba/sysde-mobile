import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/format.dart';
import '../../../core/strings.dart';
import '../../../core/theme/tokens.dart';

/// En-tete de l'accueil : date du jour, salutation et profil.
class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Rafraichit la date chaque minute (passage de minuit).
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    final muted = TextStyle(fontSize: 13, color: context.tokens.inkMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatFullDate(now), style: muted),
        const SizedBox(height: 4),
        Text(
          S.hello,
          style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text('Contrôleur de saignée · SAPH-00348', style: muted),
      ],
    );
  }
}
