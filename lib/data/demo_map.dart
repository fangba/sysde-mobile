import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/map_zone.dart';

GeoRect _rect(double lat, double lng, double dLat, double dLng) => [
      (lat: lat, lng: lng),
      (lat: lat, lng: lng + dLng),
      (lat: lat + dLat, lng: lng + dLng),
      (lat: lat + dLat, lng: lng),
    ];

typedef GeoRect = List<({double lat, double lng})>;

/// Contours de demonstration (secteurs et lots) autour d'Abidjan, en attendant
/// les vraies geometries envoyees par le serveur.
final mapZonesProvider = Provider<List<MapZone>>((ref) => [
      MapZone(name: 'Nord', kind: MapZoneKind.sector, points: _rect(5.40, -4.08, 0.10, 0.12)),
      MapZone(name: 'Sud', kind: MapZoneKind.sector, points: _rect(5.26, -4.08, 0.12, 0.12)),
      MapZone(name: 'Lot 1', kind: MapZoneKind.lot, points: _rect(5.43, -4.05, 0.04, 0.05)),
      MapZone(name: 'Lot 2', kind: MapZoneKind.lot, points: _rect(5.30, -4.05, 0.04, 0.05)),
    ]);
