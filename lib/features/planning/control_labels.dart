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

extension RatingX on Rating {
  String get label => switch (this) {
        Rating.good => S.ratingGood,
        Rating.average => S.ratingAverage,
        Rating.poor => S.ratingPoor,
      };
}
