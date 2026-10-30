import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/training_type.dart';
import 'activity_section.dart';
import 'group_page.dart';
import 'training_labels.dart';

/// Formation a la saignee : une carte par type de formation.
class TrainingHubPage extends ConsumerWidget {
  const TrainingHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainings = [
      for (final a in ref.watch(activitiesProvider))
        if (a.category == ActivityCategory.training) a,
    ];
    return ActivityGroupPage(
      title: S.sectionTraining,
      subtitle: S.chooseTrainingType,
      icon: ActivitySection.training.icon,
      pending: countActivities(trainings).pending,
      done: countActivities(trainings).done,
      entries: [
        for (final type in TrainingType.values)
          GroupEntry(
            icon: type.icon,
            title: type.label,
            description: describeActivities(trainings.where((a) => a.trainingType == type)),
            path: '/activite/formation/${type.slug}',
          ),
      ],
    );
  }
}

/// Nombre d'activites en attente et terminees.
({int pending, int done}) countActivities(Iterable<Activity> list) {
  final done = list.where((a) => a.status == ActivityStatus.done).length;
  return (pending: list.length - done, done: done);
}

/// "N en attente · M terminees" pour un ensemble d'activites.
String describeActivities(Iterable<Activity> list) {
  final c = countActivities(list);
  return S.pendingAndDone(c.pending, c.done);
}
