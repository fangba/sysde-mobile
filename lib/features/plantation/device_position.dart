import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
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

/// Position suivie en continu : precision (metres) et cap (degres, 0 = nord)
/// quand l'appareil se deplace ; cap null a l'arret.
typedef LivePosition = ({GeoPoint point, double accuracy, double? heading});

final livePositionProvider = StreamProvider.autoDispose<LivePosition?>((ref) async* {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      yield null;
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      yield null;
      return;
    }
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).map<LivePosition?>((p) => (
          point: (lat: p.latitude, lng: p.longitude),
          accuracy: p.accuracy,
          // Le cap GPS n'a de sens qu'en mouvement.
          heading: p.heading >= 0 && p.speed > 0.5 ? p.heading : null,
        ));
  } catch (_) {
    yield null;
  }
});

/// Cap de la boussole du telephone (degres, 0 = nord), meme a l'arret.
/// Null si le capteur est absent ou indisponible (emulateur, test).
final compassHeadingProvider = StreamProvider.autoDispose<double?>((ref) async* {
  try {
    final events = FlutterCompass.events;
    if (events == null) {
      yield null;
      return;
    }
    double? last;
    await for (final e in events) {
      final h = e.heading;
      if (h == null) continue;
      // Evite de redessiner la carte pour des micro-variations du capteur.
      if (last != null) {
        final d = (h - last).abs();
        if (math.min(d, 360 - d) < 3) continue;
      }
      last = h;
      yield (h + 360) % 360;
    }
  } catch (_) {
    yield null;
  }
});
