import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import 'photo_sheet_page.dart';
import 'subject_labels.dart';

/// Ce qui s'ouvre quand on touche une date dans une liste par sujet
/// (visite, session de formation, animation de groupe) : meme style que la
/// page precedente, avec deux grandes cartes Controle et Rapport.
class VisitActionsPage extends ConsumerWidget {
  const VisitActionsPage({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(activitiesProvider).where((a) => a.id == activityId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text(S.noActivitySelected)),
      );
    }
    final a = matches.first;
    final (labels, backPath) = _context(a);
    final rank = a.rank ?? 1;
    final subject = a.subjectName == null
        ? a.title
        : '${labels.prefix} ${a.subjectName!.toUpperCase()}'.trim();
    final section = a.section;
    final end = a.lastDay;
    final muted = TextStyle(fontSize: 13, color: context.tokens.inkMuted);

    return PhotoSheetPage(
      title: subject,
      titleColor: context.scheme.primary,
      fallbackIcon: switch (a.category) {
        ActivityCategory.visit => Icons.eco_outlined,
        ActivityCategory.training => Icons.school_outlined,
        ActivityCategory.meeting => Icons.groups_outlined,
      },
      backPath: backPath,
      children: [
        if (section != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.place_outlined, size: 18, color: context.scheme.primary),
              const SizedBox(width: 4),
              Text(
                '${S.sectionField} $section',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        const SizedBox(height: 14),
        Text(
          labels.item(rank),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${S.plannedOn} ${formatLongDate(a.date)}',
          textAlign: TextAlign.center,
          style: muted,
        ),
        if (end != null)
          Text(
            '${S.endDate} : ${formatLongDate(end)}',
            textAlign: TextAlign.center,
            style: muted,
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.school,
                label: S.actionControl,
                onTap: () => context.push('/action/${a.id}/controle'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.assignment_outlined,
                label: S.actionReport,
                onTap: () => _soon(context, S.actionReport),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static (SubjectLabels, String) _context(Activity a) {
    if (a.visitType != null) {
      return (visitLabels, '/activite/visite/${a.visitType!.slug}');
    }
    if (a.trainingType != null) {
      return (trainingLabels, '/activite/formation/${a.trainingType!.slug}');
    }
    if (a.meetingType != null) {
      return (meetingLabels, '/activite/rencontre/${a.meetingType!.slug}');
    }
    return (visitLabels, '/activite');
  }

  static void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what : ${S.screenToDefine}')));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return AspectRatio(
      aspectRatio: 1,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          elevation: 2,
          borderRadius: radius,
          child: Ink(
            decoration: brandGradient(context, radius: radius),
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 56, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
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
