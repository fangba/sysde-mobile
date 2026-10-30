import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/meeting_type.dart';
import 'activity_section.dart';
import 'group_page.dart';
import 'meeting_labels.dart';
import 'training_hub_page.dart';

/// Rencontre technique : une carte par type de rencontre.
class MeetingHubPage extends ConsumerWidget {
  const MeetingHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = [
      for (final a in ref.watch(activitiesProvider))
        if (a.category == ActivityCategory.meeting) a,
    ];
    final count = countActivities(meetings);
    return ActivityGroupPage(
      title: S.sectionMeeting,
      subtitle: S.chooseMeetingType,
      icon: ActivitySection.meeting.icon,
      pending: count.pending,
      done: count.done,
      entries: [
        for (final type in MeetingType.values)
          GroupEntry(
            icon: type.icon,
            title: type.label,
            description: describeActivities(meetings.where((a) => a.meetingType == type)),
            path: '/activite/rencontre/${type.slug}',
          ),
      ],
    );
  }
}
