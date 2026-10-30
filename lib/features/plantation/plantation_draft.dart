import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/geo.dart';

/// Contour releve d'une nouvelle plantation, en attente de synchronisation.
class PlantationDraft {
  const PlantationDraft({required this.points, required this.areaHectares});

  final List<GeoPoint> points;
  final double areaHectares;
}

/// Brouillons enregistres sur l'appareil. Provisoire (memoire) : sera remplace
/// par la base locale + file d'envoi.
class PlantationDraftsNotifier extends Notifier<List<PlantationDraft>> {
  @override
  List<PlantationDraft> build() => const [];

  void add(PlantationDraft draft) => state = [...state, draft];
}

final plantationDraftsProvider =
    NotifierProvider<PlantationDraftsNotifier, List<PlantationDraft>>(
  PlantationDraftsNotifier.new,
);
