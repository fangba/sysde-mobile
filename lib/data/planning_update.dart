import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/planning_update.dart';

/// Etapes affichees pendant la mise a jour, dans l'ordre.
const planningUpdateSteps = 4;

/// Lance la mise a jour du planning. [onStep] recoit l'etape en cours
/// (0 a [planningUpdateSteps] - 1) ; la liste rendue est celle des changements
/// recus. Une exception signale un echec (reseau, serveur...).
typedef PlanningUpdater = Future<List<PlanningChange>> Function(void Function(int step) onStep);

/// Demonstration : simule les etapes et rend quelques changements fictifs.
/// Avec le back, ce sera : connexion, `GET` du planning valide, comparaison
/// avec la base locale, enregistrement.
final planningUpdaterProvider = Provider<PlanningUpdater>((ref) {
  return (onStep) async {
    for (var i = 0; i < planningUpdateSteps; i++) {
      onStep(i);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    return const [
      PlanningChange(
        kind: PlanningChangeKind.added,
        title: 'Visite de plantation · Plantation 4502',
        detail: 'Mardi 17 novembre',
      ),
      PlanningChange(
        kind: PlanningChangeKind.added,
        title: 'Rencontre · Groupe Espoir',
        detail: 'Jeudi 19 novembre',
      ),
      PlanningChange(
        kind: PlanningChangeKind.changed,
        title: 'Formation à la saignée · Bonoua',
        detail: 'Déplacée au lundi 23 novembre',
      ),
      PlanningChange(
        kind: PlanningChangeKind.removed,
        title: 'Visite de plantation · Plantation 4391',
        detail: 'Retirée du planning',
      ),
    ];
  };
});
