import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysde_mobile/app.dart';
import 'package:sysde_mobile/core/router/app_router.dart';
import 'package:sysde_mobile/features/planning/activities_by_subject_page.dart';
import 'package:sysde_mobile/features/auth/splash_page.dart';
import 'package:sysde_mobile/features/planning/orchard_discovery_page.dart';
import 'package:sysde_mobile/features/plantation/new_plantation_page.dart';
import 'package:sysde_mobile/features/planning/participants_page.dart';
import 'package:sysde_mobile/features/planning/section_card.dart';
import 'package:sysde_mobile/features/planning/visit_actions_page.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWithValue(buildRouter(initialLocation: '/accueil')),
      ],
      child: const SysdeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('telephone : barre de navigation en bas', (tester) async {
    await _pump(tester, const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('tablette 8 pouces : rail lateral', (tester) async {
    await _pump(tester, const Size(800, 1280));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('quatre menus : Accueil, Activité, Carte, Paramètres', (tester) async {
    await _pump(tester, const Size(390, 844));
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['Accueil', 'Activité', 'Carte', 'Paramètres']) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('tableau de bord : jauge et onglets de categories', (tester) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('78'), findsOneWidget);

    await tester.ensureVisible(find.text('FORMATIONS'));
    await tester.tap(find.text('FORMATIONS'));
    await tester.pumpAndSettle();
    // Formations : 0 en attente, 2 terminees -> 0 % et 100 %.
    expect(find.text('100 %'), findsOneWidget);
    expect(find.text('0 %'), findsOneWidget);

    // Toucher une ligne n'ouvre aucun ecran : on reste sur l'accueil.
    await tester.tap(find.text('100 %'));
    await tester.pumpAndSettle();
    expect(find.text('78'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Bonjour, Yao'), findsOneWidget);
  });

  testWidgets('activité : cartes, types de formation puis liste', (tester) async {
    await _pump(tester, const Size(390, 844));
    await tester.tap(find.text('Activité').last);
    await tester.pumpAndSettle();
    for (final t in ['PROGRAMME D\'ACTIVITÉS', 'FORMATION À LA SAIGNÉE', 'VISITE DE PLANTATION', 'RENCONTRE TECHNIQUE']) {
      expect(find.text(t), findsOneWidget);
    }

    await tester.ensureVisible(find.text('FORMATION À LA SAIGNÉE'));
    await tester.tap(find.text('FORMATION À LA SAIGNÉE'));
    await tester.pumpAndSettle();
    for (final t in [
      'Formation initiale',
      'Perfectionnement in situ',
      'Contrôle post perfectionnement',
      'Recyclage des saigneurs',
    ]) {
      expect(find.text(t), findsOneWidget);
    }

    await tester.tap(find.text('Formation initiale'));
    await tester.pumpAndSettle();

    // Meme principe que la visite : section d'abord, puis les saigneurs.
    expect(find.byType(ActivitiesBySubjectPage), findsOneWidget);
    expect(find.text('Sélectionnez une section pour afficher les saigneurs.'), findsOneWidget);
    expect(find.text('SAIGNEUR KOUAMÉ JEAN'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nord').last);
    await tester.pumpAndSettle();

    expect(find.text('1 saigneur'), findsOneWidget);
    expect(find.text('SAIGNEUR KOUAMÉ JEAN'), findsOneWidget);
    expect(find.text('Session 1'), findsOneWidget);
    expect(find.text('Session 2'), findsOneWidget);
    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('activité : visite de plantation, types puis liste', (tester) async {
    await _pump(tester, const Size(390, 844));
    await tester.tap(find.text('Activité').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('VISITE DE PLANTATION'));
    await tester.tap(find.text('VISITE DE PLANTATION'));
    await tester.pumpAndSettle();
    for (final t in [
      'Visite d\'intervention',
      'Visite de conformité',
      'Découverte du verger',
    ]) {
      expect(find.text(t), findsOneWidget);
    }

    await tester.tap(find.text('Visite d\'intervention'));
    await tester.pumpAndSettle();

    // Meme principe que la visite de plantation : section d'abord.
    expect(find.byType(ActivitiesBySubjectPage), findsOneWidget);
    expect(find.text('Visite d\'intervention'), findsOneWidget);
    expect(find.text('Sélectionnez une section pour afficher les plantations.'), findsOneWidget);
    expect(find.text('PLANTATION YAO KOUASSI'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nord').last);
    await tester.pumpAndSettle();

    expect(find.text('1 plantation'), findsOneWidget);
    expect(find.text('PLANTATION YAO KOUASSI'), findsOneWidget);
    expect(find.text('Visite effectuée'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    // Les plantations des autres types de visite n'apparaissent pas ici.
    expect(find.text('PLANTATION AHIZI AKA MATHIEU'), findsNothing);

    // Toucher une visite ouvre Controle / Rapport, meme style de page.
    await tester.tap(find.text('Visite effectuée'));
    await tester.pumpAndSettle();
    expect(find.byType(VisitActionsPage), findsOneWidget);
    expect(find.text('Contrôle'), findsOneWidget);
    expect(find.text('Rapport'), findsOneWidget);
    expect(find.text('PLANTATION YAO KOUASSI'), findsOneWidget);
    expect(find.text('Section : Nord'), findsOneWidget);
    // Une visite se fait en 1 jour : pas de date de fin.
    expect(find.textContaining('Date fin'), findsNothing);

    // Controle : liste des participants.
    await tester.tap(find.text('Contrôle'));
    await tester.pumpAndSettle();
    expect(find.byType(ParticipantsPage), findsOneWidget);
    expect(find.text('Participants'), findsOneWidget);
    expect(find.text('N GUESSAN Valentin'), findsOneWidget);
    expect(find.text('Saigneur / 78-85-55-58'), findsOneWidget);
    expect(find.text('Planteur / 78-98-89-98'), findsOneWidget);
    expect(find.text('0 présent · 0 absent · 3 à renseigner'), findsOneWidget);

    // Deplier un participant : presence puis cinq criteres.
    expect(find.text('Consommation'), findsNothing);
    await tester.tap(find.text('N GUESSAN Valentin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Présent'));
    await tester.pumpAndSettle();
    for (final c in ['Consommation', 'Profondeur', 'Pente', 'Blessures', 'Propreté']) {
      expect(find.text(c), findsOneWidget);
    }
    await tester.tap(find.text('Bon').first);
    await tester.pumpAndSettle();
    expect(find.text('Présent · 1/5'), findsOneWidget);
    expect(find.text('1 présent · 0 absent · 2 à renseigner'), findsOneWidget);

    // Un absent n'est pas evalue : les criteres disparaissent.
    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();
    expect(find.text('Consommation'), findsNothing);
    expect(find.text('1 présent · 0 absent · 2 à renseigner'), findsNothing);
    expect(find.text('0 présent · 1 absent · 2 à renseigner'), findsOneWidget);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.byType(VisitActionsPage), findsOneWidget);

    // Retour : la liste garde la section choisie.
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('1 plantation'), findsOneWidget);
  });

  testWidgets('activité : rencontre technique, types puis liste', (tester) async {
    await _pump(tester, const Size(390, 844));
    await tester.tap(find.text('Activité').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('RENCONTRE TECHNIQUE'));
    await tester.tap(find.text('RENCONTRE TECHNIQUE'));
    await tester.pumpAndSettle();
    for (final t in [
      'Groupe de vulgarisation',
      'Conférence thématique',
      'Voyage d\'étude',
      'Foire aux régisseurs',
    ]) {
      expect(find.text(t), findsOneWidget);
    }

    await tester.tap(find.text('Conférence thématique'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesBySubjectPage), findsOneWidget);
    expect(find.text('Sélectionnez une section pour afficher les groupes.'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nord').last);
    await tester.pumpAndSettle();

    expect(find.text('1 groupe'), findsOneWidget);
    expect(find.text('GROUPE UNION'), findsOneWidget);
    expect(find.text('Animation 1'), findsOneWidget);
    expect(find.text('Animation effectuée'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('visite de plantation : section, recherche, pagination', (tester) async {
    await _pump(tester, const Size(390, 844));
    await tester.tap(find.text('Activité').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('VISITE DE PLANTATION'));
    await tester.tap(find.text('VISITE DE PLANTATION'));
    await tester.pumpAndSettle();
    // Premiere carte de la page : le type « Visite de plantation ».
    await tester.tap(find.byType(SectionCard).first);
    await tester.pumpAndSettle();

    // Rien tant qu'aucune section n'est choisie.
    expect(find.byType(ActivitiesBySubjectPage), findsOneWidget);
    expect(find.text('Sélectionnez une section pour afficher les plantations.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('PLANTATION AHIZI AKA MATHIEU'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nord').last);
    await tester.pumpAndSettle();

    // Section Nord : 7 plantations, 5 par page, la premiere est depliee.
    expect(find.text('7 plantations'), findsOneWidget);
    expect(find.text('PLANTATION AHIZI AKA MATHIEU'), findsOneWidget);
    expect(find.text('1ère visite'), findsOneWidget);
    expect(find.text('2e visite'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('PLANTATION KONAN BROU'), findsNothing);

    // La barre de pagination est en bas de la liste : on y descend.
    await tester.scrollUntilVisible(
      find.text('Suivant'),
      200,
      scrollable: find
          .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
          .first,
    );
    // scrollUntilVisible s'arrete des que l'element est construit ; on le
    // ramene ensuite dans la zone visible.
    await tester.ensureVisible(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 / 2'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 / 2'), findsOneWidget);
    expect(find.text('PLANTATION KONAN BROU'), findsOneWidget);
    expect(find.text('PLANTATION AHIZI AKA MATHIEU'), findsNothing);

    // La recherche revient a la premiere page et filtre sur le nom.
    await tester.enterText(find.byType(TextField), 'kouadio');
    await tester.pumpAndSettle();
    expect(find.text('1 plantation'), findsOneWidget);
    expect(find.text('PLANTATION KOUADIO YAO'), findsOneWidget);
    expect(find.text('Page 1 / 1'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Aucune plantation trouvée.'), findsOneWidget);
  });

  testWidgets('programme : calendrier du mois et activités du jour', (tester) async {
    // Ecran haut : tout le calendrier et la liste du jour tiennent a l'ecran
    // (le test ne voit pas les elements d'une liste hors de la zone visible).
    await _pump(tester, const Size(390, 1400));
    await tester.tap(find.text('Activité').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PROGRAMME D\'ACTIVITÉS'));
    await tester.pumpAndSettle();

    expect(find.text('Planning'), findsOneWidget);
    expect(find.text('Année 2026'), findsOneWidget);
    expect(find.text('Validé'), findsOneWidget);
    expect(find.text('Octobre 2026'), findsOneWidget);
    expect(find.text('Mardi 27 octobre'), findsOneWidget);
    // Activites du 27 octobre : deux visites et une rencontre.
    expect(find.text('Visite de plantation'), findsNWidgets(2));
    expect(find.text('Rencontre de groupe'), findsOneWidget);

    // Un autre jour du mois.
    await tester.tap(find.text('26'));
    await tester.pumpAndSettle();
    expect(find.text('Lundi 26 octobre'), findsOneWidget);
    expect(find.text('Visite de plantation'), findsOneWidget);
    expect(find.text('Rencontre de groupe'), findsNothing);

    // Mois suivant : plus d'activite, puis retour sur aujourd'hui.
    await tester.tap(find.byTooltip('Mois suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Novembre 2026'), findsOneWidget);
    expect(find.text('Dimanche 1 novembre'), findsOneWidget);
    expect(find.text('Aucune activité ce jour.'), findsOneWidget);

    await tester.tap(find.byTooltip('Mois précédent'));
    await tester.pumpAndSettle();
    expect(find.text('Octobre 2026'), findsOneWidget);
    expect(find.text('Mardi 27 octobre'), findsOneWidget);
  });

  testWidgets('découverte du verger : bouton Nouvelle plantation', (tester) async {
    await _pump(tester, const Size(390, 844));
    await tester.tap(find.text('Activité').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('VISITE DE PLANTATION'));
    await tester.tap(find.text('VISITE DE PLANTATION'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Découverte du verger'));
    await tester.pumpAndSettle();

    // Ni section ni liste : un seul bouton.
    expect(find.byType(OrchardDiscoveryPage), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Nouvelle plantation'), findsOneWidget);

    await tester.tap(find.text('Nouvelle plantation'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NewPlantationPage), findsOneWidget);
    expect(find.byTooltip('Enregistrer'), findsOneWidget);
    expect(find.byTooltip('Ajouter ma position'), findsOneWidget);

    // Enregistrer sans contour : refuse.
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pump();
    expect(find.textContaining('au moins 3 points'), findsOneWidget);
  });

  testWidgets('accueil : glisser vers le haut ouvre la connexion', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(buildRouter(initialLocation: '/')),
        ],
        child: const SysdeApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.textContaining('pour explorer'), findsOneWidget);

    // Glisser la feuille vers le haut.
    await tester.drag(find.byType(WelcomePage), const Offset(0, -400));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Bon retour !'), findsOneWidget);
    expect(find.text('Matricule'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
