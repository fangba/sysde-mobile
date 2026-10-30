import '../../core/strings.dart';

/// Libelles d'une page « par sujet » : le sujet est la plantation (visite),
/// le saigneur (formation) ou le groupe (rencontre).
class SubjectLabels {
  const SubjectLabels({
    required this.prefix,
    required this.single,
    required this.plural,
    required this.masculine,
    required this.item,
    required this.doneLabel,
  });

  /// Devant le nom du sujet, en majuscules : « PLANTATION », « SAIGNEUR »...
  /// Vide quand le nom porte deja le mot (« Groupe Espoir »).
  final String prefix;
  final String single;
  final String plural;

  /// Accord de « trouve » et de « un / une ».
  final bool masculine;

  /// Libelle de la n-ieme activite du sujet : « 2e visite », « Session 2 ».
  final String Function(int rank) item;
  final String doneLabel;

  String count(int n) => '$n ${n > 1 ? plural : single}';
  String get searchHint => 'Rechercher ${masculine ? 'un' : 'une'} $single';
  String get pickHint => 'Sélectionnez une section pour afficher les $plural.';
  String get empty => masculine ? 'Aucun $single trouvé.' : 'Aucune $single trouvée.';
}

const visitLabels = SubjectLabels(
  prefix: 'PLANTATION',
  single: 'plantation',
  plural: 'plantations',
  masculine: false,
  item: S.visitNth,
  doneLabel: S.visitDone,
);

const trainingLabels = SubjectLabels(
  prefix: 'SAIGNEUR',
  single: 'saigneur',
  plural: 'saigneurs',
  masculine: true,
  item: _session,
  doneLabel: S.sessionDone,
);

const meetingLabels = SubjectLabels(
  prefix: '',
  single: 'groupe',
  plural: 'groupes',
  masculine: true,
  item: _animation,
  doneLabel: S.animationDone,
);

String _session(int n) => 'Session $n';
String _animation(int n) => 'Animation $n';
