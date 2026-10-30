import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/splash_page.dart';
import '../../features/home/home_page.dart';
import '../../features/map/map_page.dart';
import '../../features/planning/activities_by_subject_page.dart';
import '../../features/plantation/new_plantation_page.dart';
import '../../features/planning/activity_hub_page.dart';
import '../../features/planning/activity_page.dart';
import '../../features/planning/meeting_hub_page.dart';
import '../../features/planning/orchard_discovery_page.dart';
import '../../features/planning/meeting_labels.dart';
import '../../features/planning/training_hub_page.dart';
import '../../features/planning/visit_labels.dart';
import '../../features/planning/training_labels.dart';
import '../../features/planning/subject_labels.dart';
import '../../features/planning/visit_actions_page.dart';
import '../../features/planning/visit_hub_page.dart';
import '../../features/planning/participants_page.dart';
import '../../features/planning/planning_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/sync/sync_page.dart';
import '../../domain/meeting_type.dart';
import '../../domain/training_type.dart';
import '../../domain/visit_type.dart';
import '../strings.dart';
import 'app_shell.dart';

GoRouter buildRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
      GoRoute(
        path: '/connexion',
        builder: (context, state) => const WelcomePage(startOpen: true),
      ),
      GoRoute(
        path: '/fiche/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ActivityPage(activityId: id ?? '');
        },
      ),
      GoRoute(
        path: '/action/:id',
        builder: (context, state) =>
            VisitActionsPage(activityId: state.pathParameters['id'] ?? ''),
        routes: [
          GoRoute(
            path: 'controle',
            builder: (context, state) =>
                ParticipantsPage(activityId: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: '/plantation/nouvelle',
        builder: (context, state) => const NewPlantationPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/accueil', builder: (context, state) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activite',
                builder: (context, state) => const ActivityHubPage(),
                routes: [
                  GoRoute(
                    path: 'formation',
                    builder: (context, state) => const TrainingHubPage(),
                    routes: [
                      GoRoute(
                        path: ':type',
                        builder: (context, state) {
                          final type = TrainingType.fromSlug(state.pathParameters['type']) ??
                              TrainingType.initial;
                          return ActivitiesBySubjectPage(
                            title: type.label,
                            icon: type.icon,
                            labels: trainingLabels,
                            matches: (a) => a.trainingType == type,
                            backPath: '/activite/formation',
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'visite',
                    builder: (context, state) => const VisitHubPage(),
                    routes: [
                      GoRoute(
                        path: ':type',
                        builder: (context, state) {
                          final type = VisitType.fromSlug(state.pathParameters['type']) ??
                              VisitType.plantation;
                          if (type == VisitType.orchard) return const OrchardDiscoveryPage();
                          return ActivitiesBySubjectPage(
                            title: type.label,
                            icon: type.icon,
                            labels: visitLabels,
                            matches: (a) => a.visitType == type,
                            backPath: '/activite/visite',
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'rencontre',
                    builder: (context, state) => const MeetingHubPage(),
                    routes: [
                      GoRoute(
                        path: ':type',
                        builder: (context, state) {
                          final type = MeetingType.fromSlug(state.pathParameters['type']) ??
                              MeetingType.outreachGroup;
                          return ActivitiesBySubjectPage(
                            title: type.label,
                            icon: type.icon,
                            labels: meetingLabels,
                            matches: (a) => a.meetingType == type,
                            backPath: '/activite/rencontre',
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'programme',
                    builder: (context, state) => const PlanningPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/carte', builder: (context, state) => const MapPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/parametres',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'synchro',
                    builder: (context, state) => Scaffold(
                      appBar: AppBar(
                        title: const Text(S.sync),
                        leading: BackButton(onPressed: () => context.pop()),
                      ),
                      body: const SyncPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => buildRouter());
