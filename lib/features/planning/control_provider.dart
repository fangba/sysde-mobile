import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/control.dart';

String controlKey(String activityId, String participantId) => '$activityId/$participantId';

/// Presence et notes saisies, par activite et participant. Provisoire (memoire) :
/// sera enregistre dans la base locale puis envoye au serveur.
class ControlsNotifier extends Notifier<Map<String, ParticipantControl>> {
  @override
  Map<String, ParticipantControl> build() => const {};

  void setAttendance(String key, Attendance a) {
    final current = state[key] ?? const ParticipantControl();
    state = {...state, key: current.withAttendance(a)};
  }

  void setRating(String key, Criterion c, Rating r) {
    final current = state[key] ?? const ParticipantControl();
    state = {...state, key: current.withRating(c, r)};
  }
}

final controlsProvider =
    NotifierProvider<ControlsNotifier, Map<String, ParticipantControl>>(ControlsNotifier.new);
