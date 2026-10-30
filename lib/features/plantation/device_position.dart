import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/geo.dart';

/// Position GPS de l'appareil avec sa precision (metres).
typedef DevicePosition = ({GeoPoint point, double accuracy});

/// Lit la position. Renvoie null si le GPS est coupe, refuse ou indisponible
/// (emulateur, test) : la carte reste utilisable en pointant a la main.
final devicePositionProvider = FutureProvider.autoDispose<DevicePosition?>((ref) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).timeout(const Duration(seconds: 15));
    return (point: (lat: p.latitude, lng: p.longitude), accuracy: p.accuracy);
  } catch (_) {
    return null;
  }
});
