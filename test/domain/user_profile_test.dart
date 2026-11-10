import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/data/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sysde_mobile/features/planning/control_provider.dart';
import 'package:sysde_mobile/domain/control.dart';

void main() {
  test('initiales : premier et dernier mot du nom', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(profileProvider).initials, 'YK');
  });

  test('desactiver le compte efface les controles saisis sur l\'appareil', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(controlsProvider.notifier).setAttendance('a/p1', Attendance.present);
    expect(c.read(controlsProvider), isNotEmpty);
    c.invalidate(controlsProvider);
    expect(c.read(controlsProvider), isEmpty);
  });
}
