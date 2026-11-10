import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../domain/control.dart';

extension CriterionX on Criterion {
  String get label => switch (this) {
        Criterion.consumption => S.critConsumption,
        Criterion.depth => S.critDepth,
        Criterion.slope => S.critSlope,
        Criterion.wounds => S.critWounds,
        Criterion.cleanliness => S.critCleanliness,
      };
}

extension CriterionIconX on Criterion {
  IconData get icon => switch (this) {
        Criterion.consumption => Icons.straighten,
        Criterion.depth => Icons.vertical_align_bottom,
        Criterion.slope => Icons.trending_down,
        Criterion.wounds => Icons.healing_outlined,
        Criterion.cleanliness => Icons.cleaning_services_outlined,
      };
}

extension RatingX on Rating {
  IconData get icon => switch (this) {
        Rating.good => Icons.sentiment_satisfied_alt_outlined,
        Rating.average => Icons.sentiment_neutral_outlined,
        Rating.poor => Icons.sentiment_dissatisfied_outlined,
      };

  String get label => switch (this) {
        Rating.good => S.ratingGood,
        Rating.average => S.ratingAverage,
        Rating.poor => S.ratingPoor,
      };
}
