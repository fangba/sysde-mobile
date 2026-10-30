# SysDE Mobile

Application terrain (Flutter, Android en priorité) de SysDE : planning, réalisation des activités, synchronisation hors ligne. Cible principale : tablettes 8 pouces ; elle s'adapte aux téléphones.

> État : squelette sur données de démonstration. Aucun appel réseau, pas encore de base locale ni de synchronisation. Le code a été écrit sans compilateur Dart : le premier `flutter analyze` peut signaler des corrections mineures.

## Première installation

1. Installer Flutter (stable) et Android Studio, puis `flutter doctor`.
2. Dans ce dossier, générer les fichiers Android (sans toucher à `lib/` ni à `pubspec.yaml`) :
   ```
   flutter create --platforms=android --org ci.sysde --project-name sysde_mobile .
   ```
   Si la commande a remplacé `lib/main.dart` ou `test/widget_test.dart`, restaurer `lib/main.dart` depuis la livraison et supprimer `test/widget_test.dart`.
3. Récupérer les paquets et figer les versions :
   ```
   flutter pub get
   flutter pub upgrade --major-versions
   ```
4. Vérifier : `flutter analyze` puis `flutter test`.
5. Lancer sur un émulateur tablette (ou une tablette en débogage USB) : `flutter run`.

## Police Montserrat

Embarquée (l'application fonctionne hors ligne, aucun téléchargement à l'exécution). Deux polices variables dans `assets/fonts/` : `Montserrat-VariableFont_wght.ttf` (romain) et `Montserrat-Italic-VariableFont_wght.ttf` (italique), déclarées dans `pubspec.yaml` pour les graisses 400 à 900. `ThemeData` l'applique à toute l'application (`fontFamily: 'Montserrat'`).

## Structure

```
lib/
  core/        thème (jetons), mise en page adaptative, routeur, widgets communs
  domain/      modèles purs et règles de calcul (identiques au web)
  data/        données de démonstration (puis base locale + API)
  features/    auth, home, planning, sync
test/          règles de calcul, coque adaptative (téléphone / tablette)
```

Largeurs : compacte < 600 dp (barre du bas), moyenne 600–840 dp (rail latéral, liste + détail), étendue > 840 dp.

## Étapes suivantes

1. Base locale (drift) et file d'envoi (outbox).
2. Client HTTP (dio), authentification par matricule, jetons.
3. Synchronisation en arrière-plan, photos en différé.
4. Calendrier mensuel du planning, localisation (.arb), tests d'intégration.

Références : `claude/mobile-reference-back.md`, `claude/endpoints-back.md`, `claude/decisions-back.md` (projet SYSDE).


## Photos du carrousel (menu Activité)

Dépose tes photos dans `assets/images/carousel/` sous les noms `saignee.jpg`, `plantation.jpg` et `rencontre.jpg` (format paysage, 1280 px de large suffit, moins de 300 Ko chacune). Tant qu'elles sont absentes, un fond vert avec une icône s'affiche à la place. Pour changer la liste, modifier `defaultCarouselSlides` dans `lib/features/planning/activity_carousel.dart`.
# sysde-mobile
