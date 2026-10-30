import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Date de la derniere synchronisation reussie ; null = jamais.
/// Demonstration : valeur de depart fixe. Avec la base locale, elle sera lue
/// et enregistree sur l'appareil, et mise a jour a la fin de chaque envoi.
class LastSyncNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => DateTime(2026, 10, 27, 17, 42);

  void markSynced(DateTime at) => state = at;
}

final lastSyncProvider = NotifierProvider<LastSyncNotifier, DateTime?>(LastSyncNotifier.new);
