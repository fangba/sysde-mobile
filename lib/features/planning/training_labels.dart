import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../domain/training_type.dart';

extension TrainingTypeX on TrainingType {
  String get label => switch (this) {
        TrainingType.initial => S.trainingInitial,
        TrainingType.inSitu => S.trainingInSitu,
        TrainingType.postControl => S.trainingPostControl,
        TrainingType.recycling => S.trainingRecycling,
      };

  IconData get icon => switch (this) {
        TrainingType.initial => Icons.school_outlined,
        TrainingType.inSitu => Icons.menu_book_outlined,
        TrainingType.postControl => Icons.fact_check_outlined,
        TrainingType.recycling => Icons.autorenew,
      };
}
