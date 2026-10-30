import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../domain/activity.dart';

extension ActivityCategoryX on ActivityCategory {
  String get label => switch (this) {
        ActivityCategory.visit => S.catVisit,
        ActivityCategory.training => S.catTraining,
        ActivityCategory.meeting => S.catMeeting,
      };

  Color color(SysdeTokens t) => switch (this) {
        ActivityCategory.visit => t.visit,
        ActivityCategory.training => t.training,
        ActivityCategory.meeting => t.meeting,
      };
}

extension ActivityStatusX on ActivityStatus {
  String get label => switch (this) {
        ActivityStatus.todo => S.statusTodo,
        ActivityStatus.inProgress => S.statusInProgress,
        ActivityStatus.done => S.statusDone,
      };
}

class ActivityStatusPill extends StatelessWidget {
  const ActivityStatusPill({super.key, required this.status});

  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (bg, fg) = switch (status) {
      ActivityStatus.todo => (t.neutralBg, t.neutralFg),
      ActivityStatus.inProgress => (t.warnBg, t.warnFg),
      ActivityStatus.done => (t.okBg, t.okFg),
    };
    return StatusPill(label: status.label, background: bg, foreground: fg);
  }
}
