import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/back_circle_button.dart';
import '../../core/widgets/sys_widgets.dart';
import 'section_card.dart';

/// Une entree du menu d'un groupe (type de formation, type de visite...).
class GroupEntry {
  const GroupEntry({
    required this.icon,
    required this.title,
    required this.description,
    required this.path,
  });

  final IconData icon;
  final String title;
  final String description;
  final String path;
}

/// Page d'un groupe d'activites : bandeau vert (retour, titre, consigne)
/// avec une carte de bilan a cheval dessus, puis une carte par entree.
class ActivityGroupPage extends StatelessWidget {
  const ActivityGroupPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pending,
    required this.done,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int pending;
  final int done;
  final List<GroupEntry> entries;

  static const _maxWidth = 720.0;
  static const _overlap = 40.0;

  @override
  Widget build(BuildContext context) {
    final wide = !context.isCompact;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _Header(title: title, subtitle: subtitle),
              Positioned(
                left: 16,
                right: 16,
                bottom: -_overlap,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: _SummaryCard(icon: icon, pending: pending, done: done),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _overlap),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 16, wide ? 32 : 16, 16),
                  children: [
                    for (final e in entries) ...[
                      SectionCard(
                        icon: e.icon,
                        title: e.title,
                        uppercase: false,
                        description: e.description,
                        onTap: () => context.go(e.path),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: brandGradient(
        context,
        radius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 64),
          child: Column(
            children: [
              // Le bouton reste colle au bord gauche de l'ecran, meme sur tablette.
              Align(
                alignment: Alignment.centerLeft,
                child: BackCircleButton(onPressed: () => context.go('/activite')),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: ActivityGroupPage._maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bilan du groupe : nombre d'activites, en attente / terminees, taux.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.pending, required this.done});

  final IconData icon;
  final int pending;
  final int done;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final total = pending + done;
    final percent = total == 0 ? 0 : (done / total * 100).round();
    return Semantics(
      container: true,
      label:
          '${S.activitiesCount(total)}, ${S.pendingAndDone(pending, done)}, $percent % effectuées',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x1F0E1A14), blurRadius: 20, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: t.okBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: context.scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.activitiesCount(total),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.pendingAndDone(pending, done),
                      style: TextStyle(fontSize: 13, color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: '$percent %', background: t.okBg, foreground: t.okFg),
            ],
          ),
        ),
      ),
    );
  }
}
