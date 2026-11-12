import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import 'control_provider.dart';
import 'photo_sheet_page.dart';
import 'subject_labels.dart';
import 'visit_steps.dart';

/// Ce qui s'ouvre quand on touche une date dans une liste par sujet
/// (visite, session de formation, animation de groupe) : les trois etapes
/// Liste de presence, Controle et Rapport, chacune grisee tant que la
/// precedente n'est pas faite.
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
    // Activites regroupees en cartes de session : le titre reprend le texte de
    // la carte (« FORMATION SEPTEMBRE », « RECYCLAGE », « CONFÉRENCE »...).
    final subject = activityHeading(a);
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
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.tokens.okBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.scheme.primary.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place, size: 20, color: context.scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${labels.sectionField} $section',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: context.scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          labels.item(rank),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
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
        VisitSteps(
          progress: ref.watch(visitProgressProvider(a.id)),
          onAttendance: () => context.push('/action/${a.id}/presence'),
          onControl: () => context.push('/action/${a.id}/controle'),
          onReport: () => _soon(context, S.actionReport),
          onLocked: (reason) => _notice(context, reason),
        ),
      ],
    );
  }

  static (SubjectLabels, String) _context(Activity a) {
    if (a.visitType != null) {
      return (visitLabels, '/activite/visite/${a.visitType!.slug}');
    }
    if (a.trainingType != null) {
      return (trainingLabelsFor(a.trainingType!), '/activite/formation/${a.trainingType!.slug}');
    }
    if (a.meetingType != null) {
      return (meetingLabelsFor(a.meetingType!), '/activite/rencontre/${a.meetingType!.slug}');
    }
    return (visitLabels, '/activite');
  }

  static void _notice(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  static void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what : ${S.screenToDefine}')));
  }
}

/// Intitule en majuscules d'une activite : le texte de sa carte pour une
/// session (« FORMATION SEPTEMBRE », « RECYCLAGE »...), sinon le sujet
/// (« PLANTATION YAO KOUASSI », « GROUPE ESPOIR »).
String activityHeading(Activity a) {
  final (labels, _) = VisitActionsPage._context(a);
  if (labels.sessionCards) {
    return (labels.yearlySessionName ?? formatSessionName(a.date, word: labels.monthCardWord))
        .toUpperCase();
  }
  return a.subjectName == null
      ? a.title
      : '${labels.prefix} ${a.subjectName!.toUpperCase()}'.trim();
}
