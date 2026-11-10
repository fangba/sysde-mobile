import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/data/demo_data.dart';

void main() {
  test('groupe de vulgarisation : liste de membres ; visite : participants de la plantation', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(participantsProvider('a3')).length, 6); // Groupe Espoir
    expect(c.read(participantsProvider('a5')).length, 3); // visite de plantation
    expect(c.read(participantsProvider('a6')), isEmpty); // formation
  });
}
