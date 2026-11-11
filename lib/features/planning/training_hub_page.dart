import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/strings.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/report_rules.dart';
import '../../domain/training_type.dart';
import 'activity_section.dart';
import 'group_page.dart';
import 'training_labels.dart';

/// Formation a la saignee : une carte par type de formation.
class TrainingHubPage extends ConsumerWidget {
  const TrainingHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(clockProvider)();
    final trainings = [
      for (final a in ref.watch(activitiesProvider))
        if (a.category == ActivityCategory.training) a,
    ];
    final count = countActivities(trainings, today);
    return ActivityGroupPage(
      lightCards: true,
      title: S.sectionTraining,
      subtitle: S.chooseTrainingType,
      icon: ActivitySection.training.icon,
      pending: count.pending,
      late: count.late,
      done: count.done,
      entries: [
        for (final type in TrainingType.values)
          GroupEntry(
            icon: type.icon,
            title: type.label,
            description: describeActivities(trainings.where((a) => a.trainingType == type), today),
            path: '/activite/formation/${type.slug}',
          ),
      ],
    );
  }
}

/// Nombre d'activites en attente (date pas encore arrivee), en retard (date
/// passee, non realisees) et terminees.
({int pending, int late, int done}) countActivities(Iterable<Activity> list, DateTime today) {
  var done = 0, late = 0, pending = 0;
  for (final a in list) {
    if (a.status == ActivityStatus.done) {
      done++;
    } else if (isLate(done: false, plannedOn: a.date, today: today)) {
      late++;
    } else {
      pending++;
    }
  }
  return (pending: pending, late: late, done: done);
}

/// "N en attente · L en retard · M terminees" pour un ensemble d'activites.
String describeActivities(Iterable<Activity> list, DateTime today) {
  final c = countActivities(list, today);
  return S.pendingAndDone(c.pending, c.done, late: c.late);
}
