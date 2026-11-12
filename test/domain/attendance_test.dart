import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/data/demo_data.dart';

void main() {
  test('participants : groupe de vulgarisation, visite, formation', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(participantsProvider('a3')).length, 6); // Groupe Espoir
    expect(c.read(participantsProvider('a5')).length, 3); // visite de plantation
    expect(c.read(participantsProvider('a6')).length, 8); // formation : saigneurs convoques
  });
}
