import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/activity.dart';
import 'package:sysde_mobile/domain/meeting_type.dart';
import 'package:sysde_mobile/domain/training_type.dart';
import 'package:sysde_mobile/domain/visit_type.dart';

Activity _a(
  ActivityCategory c, {
  TrainingType? training,
  MeetingType? meeting,
  VisitType? visit,
}) =>
    Activity(
      id: 'x',
      category: c,
      title: 't',
      place: 'p',
      date: DateTime(2026, 10, 27),
      status: ActivityStatus.todo,
      trainingType: training,
      meetingType: meeting,
      visitType: visit,
    );

void main() {
  test('la formation initiale dure 20 jours', () {
    final a = _a(ActivityCategory.training, training: TrainingType.initial);
    expect(a.durationDays, 20);
    expect(a.lastDay, DateTime(2026, 11, 15));
  });

  test('le recyclage des saigneurs dure 3 jours', () {
    final a = _a(ActivityCategory.training, training: TrainingType.recycling);
    expect(a.durationDays, 3);
    expect(a.lastDay, DateTime(2026, 10, 29));
  });

  test('tout le reste se fait en 1 jour : pas de date de fin', () {
    final all = [
      _a(ActivityCategory.training, training: TrainingType.inSitu),
      _a(ActivityCategory.training, training: TrainingType.postControl),
      for (final m in MeetingType.values) _a(ActivityCategory.meeting, meeting: m),
      for (final v in VisitType.values) _a(ActivityCategory.visit, visit: v),
    ];
    for (final a in all) {
      expect(a.durationDays, 1);
      expect(a.lastDay, isNull);
    }
  });
}
