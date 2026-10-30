import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../domain/visit_type.dart';

extension VisitTypeX on VisitType {
  String get label => switch (this) {
        VisitType.plantation => S.visitPlantation,
        VisitType.intervention => S.visitIntervention,
        VisitType.conformity => S.visitConformity,
        VisitType.orchard => S.visitOrchard,
      };

  IconData get icon => switch (this) {
        VisitType.plantation => Icons.park_outlined,
        VisitType.intervention => Icons.build_outlined,
        VisitType.conformity => Icons.assignment_turned_in_outlined,
        VisitType.orchard => Icons.travel_explore_outlined,
      };
}
