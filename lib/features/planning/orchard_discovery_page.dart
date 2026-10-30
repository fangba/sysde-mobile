import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../domain/visit_type.dart';
import 'photo_sheet_page.dart';
import 'visit_labels.dart';

/// Decouverte du verger : pas de liste, un grand bouton pour declarer une
/// nouvelle plantation.
class OrchardDiscoveryPage extends StatelessWidget {
  const OrchardDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PhotoSheetPage(
      title: VisitType.orchard.label,
      fallbackIcon: VisitType.orchard.icon,
      backPath: '/activite/visite',
      children: [
        const SizedBox(height: 8),
        _NewPlantationCard(
          onTap: () => context.go('/plantation/nouvelle'),
        ),
      ],
    );
  }
}

class _NewPlantationCard extends StatelessWidget {
  const _NewPlantationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      label: S.newPlantation,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: brandGradient(context, radius: radius),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: const ExcludeSemantics(
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.park_outlined, size: 56, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      S.newPlantation,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
