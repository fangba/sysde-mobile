import 'geo.dart';

enum MapZoneKind { sector, lot }

/// Contour d'un secteur ou d'un lot, affiche sur la carte.
class MapZone {
  const MapZone({required this.name, required this.kind, required this.points});

  final String name;
  final MapZoneKind kind;
  final List<GeoPoint> points;
}
