import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../domain/activity.dart';

/// Les quatre entrees du menu Activite, dans l'ordre d'affichage.
enum ActivitySection {
  program(S.sectionProgram, Icons.calendar_month_outlined, null),
  training(S.sectionTraining, Icons.school_outlined, ActivityCategory.training),
  meeting(S.sectionMeeting, Icons.groups_outlined, ActivityCategory.meeting),
  visit(S.sectionVisit, Icons.park_outlined, ActivityCategory.visit);

  const ActivitySection(this.title, this.icon, this.category);

  final String title;
  final IconData icon;

  /// Null pour le programme complet.
  final ActivityCategory? category;

  /// Ecran ouvert par la carte du menu Activite.
  String get path => switch (this) {
        program => '/activite/programme',
        training => '/activite/formation',
        visit => '/activite/visite',
        meeting => '/activite/rencontre',
      };
}
