import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';

/// Carte. Emplacement reserve : la carte hors ligne (fonds telecharges a
/// l'avance, secteurs, lots, plantations) n'est pas encore realisee.
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final wide = !context.isCompact;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.mapTitle,
                  style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                SysCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: t.okBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.map_outlined, size: 36, color: context.scheme.primary),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        S.mapOfflineTitle,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.mapOfflineBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.5, color: t.inkMuted),
                      ),
                      const SizedBox(height: 16),
                      StatusPill(label: S.mapSoon, background: t.neutralBg, foreground: t.neutralFg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
