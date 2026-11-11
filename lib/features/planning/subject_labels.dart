import '../../core/strings.dart';
import '../../domain/training_type.dart';

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
    this.sectionWord = 'section',
    this.sectionFeminine = true,
    this.pickTarget,
    this.lotThenSection = false,
    this.typeIconOnHint = false,
    this.sessionCards = false,
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

  /// Mot qui regroupe les sujets : « section » (par defaut) ou « lot ».
  final String sectionWord;
  final bool sectionFeminine;

  /// Ce que la consigne propose d'afficher ; par defaut le pluriel du sujet.
  final String? pickTarget;

  /// On choisit d'abord le lot, puis la section de ce lot.
  final bool lotThenSection;

  /// La consigne montre l'icone du type d'activite (formation) plutot que l'arbre.
  final bool typeIconOnHint;

  /// Une carte par session (« Session de Janvier ») au lieu d'une par sujet.
  final bool sessionCards;

  String get _sectionCap => '${sectionWord[0].toUpperCase()}${sectionWord.substring(1)}';
  String get sectionField => '$_sectionCap :';
  String get chooseSection => 'Choisir ${sectionFeminine ? 'une' : 'un'} $sectionWord';

  String count(int n) => '$n ${n > 1 ? plural : single}';
  String get searchHint => 'Rechercher ${masculine ? 'un' : 'une'} $single';
  String get pickHint => 'Sélectionnez ${sectionFeminine ? 'une' : 'un'} $sectionWord pour afficher ${pickTarget ?? 'les $plural'}.';
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
  typeIconOnHint: true,
);

/// Formation initiale : les saigneurs sont regroupes par lot, pas par section.
const initialTrainingLabels = SubjectLabels(
  prefix: 'SAIGNEUR',
  single: 'session',
  plural: 'sessions',
  masculine: false,
  item: _formationSession,
  doneLabel: S.sessionDone,
  typeIconOnHint: true,
  sectionWord: 'lot',
  sectionFeminine: false,
  pickTarget: 'les sessions de formation',
  sessionCards: true,
);

/// Suivi post perfectionnement : meme regroupement par lot.
const postControlTrainingLabels = SubjectLabels(
  prefix: 'SAIGNEUR',
  single: 'saigneur',
  plural: 'saigneurs',
  masculine: true,
  item: _session,
  doneLabel: S.sessionDone,
  typeIconOnHint: true,
  sectionWord: 'lot',
  sectionFeminine: false,
  lotThenSection: true,
);

/// Recyclage des saigneurs : les saigneurs sont regroupes par lot.
const recyclingTrainingLabels = SubjectLabels(
  prefix: 'SAIGNEUR',
  single: 'saigneur',
  plural: 'saigneurs',
  masculine: true,
  item: _session,
  doneLabel: S.sessionDone,
  typeIconOnHint: true,
  sectionWord: 'lot',
  sectionFeminine: false,
  pickTarget: 'la session de recyclage',
);

SubjectLabels trainingLabelsFor(TrainingType type) => switch (type) {
      TrainingType.initial => initialTrainingLabels,
      TrainingType.postControl => postControlTrainingLabels,
      TrainingType.recycling => recyclingTrainingLabels,
      _ => trainingLabels,
    };

const meetingLabels = SubjectLabels(
  prefix: '',
  single: 'groupe',
  plural: 'groupes',
  masculine: true,
  item: _animation,
  doneLabel: S.animationDone,
);

String _formationSession(int n) => 'Session de formation';
String _session(int n) => 'Session $n';
String _animation(int n) => 'Animation $n';
