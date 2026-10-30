/// Textes de l'interface (francais). A migrer vers des fichiers .arb
/// (flutter gen-l10n) quand l'ecran sera stabilise.
abstract final class S {
  static const appName = 'SysDE';
  static const tagline = 'Votre terrain, planifié et suivi, même sans réseau.';
  static const swipeUp = 'Glissez vers le haut pour commencer';

  static const navHome = 'Accueil';
  static const navActivity = 'Activité';
  static const navMap = 'Carte';
  static const navSettings = 'Paramètres';

  static const loginTitle = 'Accédez à votre compte';
  static const loginGreeting = 'Bonjour.';
  static const loginWelcomeBack = 'Bon retour !';
  static const welcomeSwipe = 'Glissez vers le haut';
  static const welcomeRest = " pour explorer l'encadrement technique de l'hévéa.";
  static const matriculeHint = 'Entrez votre matricule…';
  static const passwordHint = 'Entrez votre mot de passe…';
  static const closeSheet = 'Replier la connexion';
  static const matricule = 'Matricule';
  static const password = 'Mot de passe';
  static const forgotPassword = 'Mot de passe oublié ?';
  static const signIn = 'Se connecter';
  static const loginOfflineNote =
      "La connexion n'est nécessaire qu'une fois. Ensuite, l'application "
      "fonctionne sans réseau et envoie vos activités dès que le signal revient.";
  static const noSignup = 'Pas de compte ? Il est créé par votre chef secteur.';
  static const showPassword = 'Afficher le mot de passe';
  static const hidePassword = 'Masquer le mot de passe';

  static const hello = 'Bonjour, Yao';
  static const offline = 'Hors ligne';
  static const monthRealisation = "Réalisation d'octobre";
  static const today = "Aujourd'hui";
  static const late = 'En retard';
  static const toSend = 'À envoyer';
  static const toCheck = 'à vérifier';

  static const activities = 'Activités';
  static const noActivitySelected = 'Sélectionnez une activité';
  static const activity = 'Activité';
  static const positionSaved = 'Position enregistrée';
  static const photos = 'Photos';
  static const addPhoto = 'Ajouter une photo';
  static const observations = 'Observations';
  static const finishActivity = "Terminer l'activité";
  static const savedLocally =
      "Enregistré sur l'appareil, envoyé à la prochaine connexion.";

  static const sync = 'Synchronisation';
  static const syncSubtitle = 'Vos données voyagent quand le réseau revient.';
  static const syncQueue = "File d'envoi";
  static const syncNow = 'Synchroniser maintenant';
  static const noNetwork = 'Aucun réseau (démonstration).';

  static const mapTitle = 'Carte';
  static const mapOfflineTitle = 'Carte hors ligne';
  static const mapOfflineBody =
      'Vos secteurs, lots et plantations sur un fond de carte téléchargé à '
      "l'avance, pour travailler sans réseau.";
  static const mapSoon = 'À venir';

  static const settings = 'Paramètres';
  static const signOut = 'Se déconnecter';
  static const appVersion = 'Version 0.1.0';
  static const syncPendingSummary = '4 à envoyer · dernière synchro 17:42';

  static const statusTodo = 'À faire';
  static const statusInProgress = 'En cours';
  static const statusDone = 'Réalisée';
  static const reportUpToDate = 'À jour';
  static const reportSlightDelay = 'Léger retard';
  static const reportLate = 'En retard';
  static const syncPending = 'En attente';
  static const syncSent = 'Envoyée';
  static const syncReview = 'À vérifier';
  static const nextActivity = 'PROCHAINE ACTIVITÉ';
  static const nothingNext = "Aucune activité à démarrer aujourd'hui.";
  static const start = 'Démarrer';
  static const resume = 'Continuer';
  static const percentDone = 'EFFECTUÉES';
  static const notProcessed = 'NON TRAITÉES';
  static const processed = 'TRAITÉES';
  static const pendingUpper = 'EN ATTENTE';
  static const finishedUpper = 'TERMINÉES';
  static const toHandle = 'Tâches du jour';
  static const nothingToHandle = "Aucune tâche en retard ni prévue aujourd'hui.";
  static const lateLabel = 'En retard';
  static const toCheckLabel = 'À vérifier';
  static const plannedOn = 'Prévue le';
  static const sectionProgram = 'Programme d\'activités';
  static const sectionProgramDesc = 'Toutes vos activités, jour par jour';
  static const sectionTraining = 'Formation à la saignée';
  static const sectionMeeting = 'Rencontre technique';
  static const sectionVisit = 'Visite de plantation';
  static const back = 'Retour';
  static const newPlantation = 'Nouvelle plantation';
  static const gpsUnavailable = 'Position GPS indisponible. Touchez la carte pour pointer à la main.';
  static const plantationNeedsPoints = 'Ajoutez au moins 3 points pour former le contour.';
  static const plantationSaved = 'Contour enregistré sur l\'appareil.';
  static const plantationTapToTrace = 'Activez le tracé puis touchez la carte';
  static String pointsCount(int n) => n > 1 ? '$n points' : '$n point';
  static const zoomIn = 'Zoom avant';
  static const zoomOut = 'Zoom arrière';
  static const toolTrace = 'Tracer le contour sur la carte';
  static const toolAddPosition = 'Ajouter ma position';
  static const toolUndo = 'Annuler le dernier point';
  static const toolSave = 'Enregistrer';
  static const toolLayers = 'Fond de carte';
  static const toolLocate = 'Ma position';
  static const planningTitle = 'Planning';
  static String planningYear(int year) => 'Année $year';
  static const planDraft = 'Brouillon';
  static const planSubmitted = 'Soumis';
  static const planValidated = 'Validé';
  static const planRejected = 'Rejeté';
  static const previousMonth = 'Mois précédent';
  static const nextMonth = 'Mois suivant';
  static const noActivityThatDay = 'Aucune activité ce jour.';
  static const sectionField = 'Section :';
  static const chooseSection = 'Choisir une section';
  static const clearSearch = 'Effacer la recherche';
  static const previous = 'Précédent';
  static const next = 'Suivant';
  static String pageOf(int page, int count) => 'Page $page / $count';
  static const endDate = 'Date fin';
  static const actionControl = 'Contrôle';
  static const actionReport = 'Rapport';
  static const participants = 'Participants';
  static const noParticipant = 'Aucun participant.';
  static const attPresent = 'Présent';
  static const attAbsent = 'Absent';
  static const evaluated = 'évalué';
  static const attPending = 'Non renseigné';
  static const attendanceQuestion = 'Présence';
  static const ratingGood = 'Bon';
  static const ratingAverage = 'Moyen';
  static const ratingPoor = 'Mauvais';
  static const critConsumption = 'Consommation';
  static const critDepth = 'Profondeur';
  static const critSlope = 'Pente';
  static const critWounds = 'Blessures';
  static const critCleanliness = 'Propreté';
  static const saveControl = 'Enregistrer le contrôle';
  static const controlSaved = 'Contrôle enregistré sur l\'appareil.';
  static String controlSummary(int present, int absent, int pending) =>
      '$present ${present > 1 ? 'présents' : 'présent'} · '
      '$absent ${absent > 1 ? 'absents' : 'absent'} · $pending à renseigner';
  static const screenToDefine = 'écran à définir';
  static const visitDone = 'Visite effectuée';
  static const sessionDone = 'Session terminée';
  static const animationDone = 'Animation effectuée';
  static const expand = 'Déplier';
  static const collapse = 'Replier';
  static String visitNth(int n) => n == 1 ? '1ère visite' : '${n}e visite';
  static const chooseTrainingType = 'Choisissez un type de formation';
  static const chooseVisitType = 'Choisissez un type de visite';
  static String activitiesCount(int n) => '$n activité${n > 1 ? 's' : ''}';
  static const visitPlantation = 'Visite de plantation';
  static const visitIntervention = 'Visite d\'intervention';
  static const visitConformity = 'Visite de conformité';
  static const visitOrchard = 'Découverte du verger';
  static const chooseMeetingType = 'Choisissez un type de rencontre';
  static const meetingOutreach = 'Groupe de vulgarisation';
  static const meetingConference = 'Conférence thématique';
  static const meetingStudyTrip = 'Voyage d\'étude';
  static const meetingFair = 'Foire aux régisseurs';
  static const trainingInitial = 'Formation initiale';
  static const trainingInSitu = 'Perfectionnement in situ';
  static const trainingPostControl = 'Contrôle post perfectionnement';
  static const trainingRecycling = 'Recyclage des saigneurs';
  static const carouselTraining = 'Formation à la saignée';
  static const carouselVisit = 'Visite de plantation';
  static const carouselMeeting = 'Rencontre technique';
  static String pendingAndDone(int pending, int done) =>
      '$pending en attente · $done terminée${done > 1 ? 's' : ''}';
  static const noActivityInFilter = 'Aucune activité ici.';
  static const tabTraining = 'FORMATIONS';
  static const tabMeeting = 'RENCONTRES';
  static const tabVisit = 'VISITES';
  static const catVisit = 'Visite';
  static const catTraining = 'Formation';
  static const catMeeting = 'Rencontre';
}
