import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';

/// Envoie une activite terminee au serveur. Une exception signale un echec
/// (reseau, serveur) : l'activite reste a envoyer.
typedef ActivityUploader = Future<void> Function(Activity activity);

/// Demonstration : simule un envoi de moins d'une seconde. Avec le back :
/// envoi de la realisation (date, position, photos, observations) avec
/// l'identifiant UUID de l'activite, pour des reprises sans doublon.
final activityUploaderProvider = Provider<ActivityUploader>((ref) {
  return (activity) => Future<void>.delayed(const Duration(milliseconds: 800));
});
