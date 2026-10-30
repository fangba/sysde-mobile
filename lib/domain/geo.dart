import 'dart:math' as math;

/// Point geographique (latitude, longitude) en degres.
typedef GeoPoint = ({double lat, double lng});

/// Surface d'un polygone en hectares (projection locale, assez precise pour
/// une parcelle). Moins de 3 points : 0.
double polygonAreaHectares(List<GeoPoint> points) {
  if (points.length < 3) return 0;
  final lat0 = points.first.lat * math.pi / 180;
  const mPerDegLat = 110540.0;
  final mPerDegLng = 111320.0 * math.cos(lat0);
  final lng0 = points.first.lng;
  final lat0Deg = points.first.lat;
  var sum = 0.0;
  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    final ax = (a.lng - lng0) * mPerDegLng;
    final ay = (a.lat - lat0Deg) * mPerDegLat;
    final bx = (b.lng - lng0) * mPerDegLng;
    final by = (b.lat - lat0Deg) * mPerDegLat;
    sum += ax * by - bx * ay;
  }
  return sum.abs() / 2 / 10000;
}
