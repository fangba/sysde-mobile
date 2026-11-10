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
  static const hubTrainingSub = 'Contenu des activités de formation';
  static const hubMeetingSub = 'Contenu des activités de rencontre';
  static const hubVisitSub = 'Contenu des activités de visite';
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
  static const settingsAccount = 'Compte';
  static const settingsHelp = 'Aide';
  static const profile = 'Profil';
  static const profileInfo = 'Informations';
  static const profileAssignment = 'Affectation';
  static const profileDevice = 'Compte et appareil';
  static const profileMatricule = 'Matricule';
  static const profileRole = 'Poste';
  static const profilePhone = 'Téléphone';
  static const profileEmail = 'E-mail';
  static const profileOperator = 'Opérateur';
  static const profileSector = 'Secteur';
  static const profileLot = 'Lot';
  static const profileSections = 'Sections';
  static const profileStatus = 'Statut du compte';
  static const profileActive = 'Actif';
  static const profileLastSync = 'Dernière synchronisation';
  static const profileApp = 'Application';
  static const groupTotal = 'Total';
  static const noActivityHere = 'Aucune activité';
  static const statTotal = 'Activités';
  static const statDone = 'Terminées';
  static const statTodo = 'À faire';
  static const dangerZone = 'Zone sensible';
  static const deactivateAccount = 'Désactiver ce compte';
  static const deactivateExplain =
      'Révoque tous les droits de ce profil sur cet appareil. Vous pourrez ensuite '
      'vous connecter avec un autre profil.';
  static const deactivateTitle = 'Désactiver ce compte ?';
  static const deactivateRights = 'Votre session est fermée et vos droits sur cet appareil sont révoqués.';
  static const deactivateData = 'Les données de ce profil enregistrées sur l\'appareil sont supprimées.';
  static const deactivateNext = 'Un autre profil pourra ensuite se connecter.';
  static String deactivateUnsent(int n) =>
      '$n ${n > 1 ? 'activités terminées ne sont pas envoyées' : 'activité terminée n\'est pas envoyée'} '
      'au serveur : ${n > 1 ? 'elles seront perdues' : 'elle sera perdue'}. Envoyez-${n > 1 ? 'les' : 'la'} d\'abord.';
  static const deactivateConfirm = 'Désactiver';
  static const cancel = 'Annuler';
  static const accountDeactivated = 'Compte désactivé sur cet appareil.';
  static const planningUpdate = 'Mise à jour du planning';
  static const planCurrent = 'Planning en vigueur';
  static const planYear = 'Planning annuel';
  static const planLastUpdate = 'Dernière mise à jour';
  static const planActivities = 'Activités au planning';
  static const planTip =
      'La mise à jour récupère les modifications validées par votre chef de secteur. '
      'Vos données terminées, non envoyées, ne sont pas touchées.';
  static const planSearch = 'Rechercher les mises à jour';
  static const planRunning = 'Mise à jour en cours…';
  static const planStepConnect = 'Connexion au serveur';
  static const planStepCheck = 'Vérification du planning validé';
  static const planStepDownload = 'Téléchargement des activités';
  static const planStepSave = 'Enregistrement sur l\'appareil';
  static const planUpToDate = 'Planning à jour';
  static const planChangesTitle = 'Changements reçus';
  static const planAdded = 'Ajoutées';
  static const planChanged = 'Modifiées';
  static const planRemoved = 'Retirées';
  static const planKindNew = 'Nouveau';
  static const planKindChanged = 'Modifié';
  static const planKindRemoved = 'Retiré';
  static const planNoChange = 'Aucun changement : votre planning était déjà à jour.';
  static const planFailed = 'Mise à jour impossible';
  static const planFailedBody = 'Vérifiez votre connexion au réseau puis réessayez. Votre planning actuel est conservé.';
  static const planRetry = 'Réessayer';
  static const planDone = 'Terminer';
  static const planDemo = 'Démonstration : les changements affichés sont simulés.';
  static String planLastUpdateShort(String when) => 'Dernière mise à jour : $when';
  static const planningUpdateDesc = 'Récupérer le planning validé depuis le serveur';
  static const sendData = 'Envoyer les données au serveur';
  static const about = 'À propos';
  static const close = 'Fermer';
  static const aboutDesc = 'Version et informations sur l\'application';
  static const aboutBody = 'Application mobile d\'encadrement technique de l\'hévéa. '
      'Elle fonctionne hors ligne et envoie vos données au serveur dès que le réseau revient.';
  static const appVersion = 'Version 0.1.0';
  static String sendSummary(int n, String lastSync) =>
      n == 0 ? 'Rien à envoyer · $lastSync' : '$n à envoyer · $lastSync';
  static const selectAll = 'Tout sélectionner';
  static const deselectAll = 'Tout désélectionner';
  static String sendSelected(int n) => n == 0 ? 'Envoyer la sélection' : 'Envoyer la sélection ($n)';
  static String selectedOf(int n, int total) =>
      '$n ${n > 1 ? 'sélectionnées' : 'sélectionnée'} sur $total';
  static const sendTitle = 'Envoyer les données';
  static const sendRunning = 'Envoi en cours…';
  static String sendProgress(int done, int total) => '$done sur $total traitées';
  static const sendDone = 'Données envoyées';
  static String sendDoneBody(int n) =>
      n > 1 ? '$n activités ont été envoyées au serveur.' : '1 activité a été envoyée au serveur.';
  static const sendPartial = 'Envoi partiel';
  static String sendPartialBody(int failed) => failed > 1
      ? '$failed activités n\'ont pas pu être envoyées. Elles restent sur l\'appareil.'
      : '1 activité n\'a pas pu être envoyée. Elle reste sur l\'appareil.';
  static const sendRetry = 'Renvoyer les échecs';
  static const sendAllDone = 'Tout est envoyé';
  static const sendAllDoneBody = 'Aucune activité terminée n\'attend d\'être envoyée.';
  static const sendFailed = 'Échec';
  static const nothingToSend = 'Aucune activité terminée à envoyer.';
  static const catTrainingPlural = 'Formations';
  static const catMeetingPlural = 'Rencontres';
  static const catVisitPlural = 'Visites';

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
  static const actionAttendance = 'Liste de présence';
  static const markAllPresent = 'Tout marquer présent';
  static const saveAttendance = 'Enregistrer la liste';
  static const attendanceSaved = 'Liste de présence enregistrée sur l\'appareil.';
  static const participants = 'Participants';
  static const noParticipant = 'Aucun participant.';
  static const attPresent = 'Présent';
  static const attAbsent = 'Absent';
  static const evaluated = 'évalué';
  static const attPending = 'Non renseigné';
  static const attendanceQuestion = 'Présence';
  static const evaluationTitle = 'Évaluation';
  static const conformityNotesTitle = 'Notes des visites de plantation';
  static const conformityNotesHint =
      'Notes relevées par le moniteur lors des visites de plantation. Consultation seulement.';
  static const conformityNoVisit = 'Aucune visite de plantation avec contrôle pour cette plantation.';
  static const conformityNoNote = 'Aucune note pour ce participant.';
  static const conformityLastThree = 'Les 3 dernières visites sont affichées.';
  static const noNote = '—';
  static const monitorNote = 'Moniteur';
  static const gapSame = 'identique';
  static const gapLabel = 'écart';
  static const overallTitle = 'Note globale';
  static const verdictCompliant = 'Conforme';
  static const verdictNonCompliant = 'Non conforme';
  static const commentLabel = 'Commentaire';
  static const commentHint = 'Observations sur la conformité du participant';
  static const commentRequired = 'Commentaire obligatoire si le participant est non conforme.';
  static const absentNotEvaluated = 'Un participant absent n\'est pas évalué.';
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
  static const trainingPostControl = 'Suivi post perfectionnement';
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
