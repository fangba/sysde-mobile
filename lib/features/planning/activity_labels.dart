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

  /// Meme icone que sur l'accueil (Formations, Rencontres, Visites).
  IconData get icon => switch (this) {
        ActivityCategory.training => Icons.school_outlined,
        ActivityCategory.meeting => Icons.groups_outlined,
        ActivityCategory.visit => Icons.assignment_outlined,
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
        ActivityStatus.inProgress => S.statusTodo,
        ActivityStatus.done => S.statusDone,
      };
}

class ActivityStatusPill extends StatelessWidget {
  const ActivityStatusPill({super.key, required this.status, this.late = false});

  final ActivityStatus status;

  /// Non realisee et prevue avant aujourd'hui : « En retard ».
  final bool late;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (label, bg, fg) = switch (status) {
      ActivityStatus.done => (status.label, t.okBg, t.okFg),
      _ when late => (S.lateLabel, t.dangerBg, t.dangerFg),
      _ => (S.statusTodo, t.neutralBg, t.neutralFg),
    };
    return StatusPill(label: label, background: bg, foreground: fg);
  }
}
