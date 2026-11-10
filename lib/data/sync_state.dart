import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import 'demo_data.dart';

/// Date de la derniere synchronisation reussie ; null = jamais.
/// Demonstration : valeur de depart fixe. Avec la base locale, elle sera lue
/// et enregistree sur l'appareil, et mise a jour a la fin de chaque envoi.
class LastSyncNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => DateTime(2026, 10, 27, 17, 42);

  void markSynced(DateTime at) => state = at;
}

final lastSyncProvider = NotifierProvider<LastSyncNotifier, DateTime?>(LastSyncNotifier.new);

/// Date de la derniere mise a jour du planning depuis le serveur.
/// Demonstration : valeur de depart fixe, a lire dans la base locale ensuite.
class LastPlanningUpdateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => DateTime(2026, 10, 27, 8, 15);

  void markUpdated(DateTime at) => state = at;
}

final lastPlanningUpdateProvider =
    NotifierProvider<LastPlanningUpdateNotifier, DateTime?>(LastPlanningUpdateNotifier.new);

/// Identifiants des activites deja envoyees au serveur. Demonstration : en
/// memoire ; avec la base locale, ce sera l'etat de la file d'envoi.
class SentActivitiesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void markSent(Iterable<String> ids) => state = {...state, ...ids};
}

final sentActivitiesProvider =
    NotifierProvider<SentActivitiesNotifier, Set<String>>(SentActivitiesNotifier.new);

/// Activites terminees pas encore envoyees, de la plus ancienne a la plus recente.
final pendingUploadsProvider = Provider<List<Activity>>((ref) {
  final sent = ref.watch(sentActivitiesProvider);
  return [
    for (final a in ref.watch(activitiesProvider))
      if (a.status == ActivityStatus.done && !sent.contains(a.id)) a,
  ]..sort((a, b) => a.date.compareTo(b.date));
});
