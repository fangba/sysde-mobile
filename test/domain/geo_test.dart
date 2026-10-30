import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/domain/geo.dart';

void main() {
  test('moins de 3 points : surface nulle', () {
    expect(polygonAreaHectares(const []), 0);
    expect(polygonAreaHectares(const [(lat: 5.0, lng: -4.0), (lat: 5.1, lng: -4.0)]), 0);
  });

  test('carre de 0,001 degre a l\'equateur = environ 1,23 ha', () {
    final ha = polygonAreaHectares(const [
      (lat: 0.0, lng: 0.0),
      (lat: 0.0, lng: 0.001),
      (lat: 0.001, lng: 0.001),
      (lat: 0.001, lng: 0.0),
    ]);
    expect(ha, closeTo(1.23, 0.03));
  });

  test('le sens de parcours ne change pas la surface', () {
    const pts = [
      (lat: 5.0, lng: -4.0),
      (lat: 5.0, lng: -3.999),
      (lat: 5.001, lng: -3.999),
    ];
    expect(polygonAreaHectares(pts), closeTo(polygonAreaHectares(pts.reversed.toList()), 1e-4));
  });
}
