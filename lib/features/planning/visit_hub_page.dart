import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/visit_type.dart';
import 'activity_section.dart';
import 'group_page.dart';
import 'training_hub_page.dart';
import 'visit_labels.dart';

/// Visite de plantation : une carte par type de visite.
class VisitHubPage extends ConsumerWidget {
  const VisitHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = [
      for (final a in ref.watch(activitiesProvider))
        if (a.category == ActivityCategory.visit) a,
    ];
    return ActivityGroupPage(
      title: S.sectionVisit,
      subtitle: S.chooseVisitType,
      icon: ActivitySection.visit.icon,
      pending: countActivities(visits).pending,
      done: countActivities(visits).done,
      entries: [
        for (final type in VisitType.values)
          GroupEntry(
            icon: type.icon,
            title: type.label,
            description: describeActivities(visits.where((a) => a.visitType == type)),
            path: '/activite/visite/${type.slug}',
          ),
      ],
    );
  }
}
