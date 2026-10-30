import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/breakpoints.dart';
import '../strings.dart';

typedef _Dest = ({IconData icon, IconData selected, String label});

const List<_Dest> _destinations = [
  (icon: Icons.home_outlined, selected: Icons.home, label: S.navHome),
  (icon: Icons.event_note_outlined, selected: Icons.event_note, label: S.navActivity),
  (icon: Icons.map_outlined, selected: Icons.map, label: S.navMap),
  (icon: Icons.settings_outlined, selected: Icons.settings, label: S.navSettings),
];

/// Coque de navigation adaptative : barre du bas sur telephone, rail lateral
/// des 600 dp de large.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;

    if (context.isCompact) {
      return Scaffold(
        body: SafeArea(child: navigationShell),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _select,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selected),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: _select,
            labelType: NavigationRailLabelType.all,
            minWidth: 96,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selected),
                  label: Text(d.label),
                ),
            ],
          ),
          Expanded(child: SafeArea(child: navigationShell)),
        ],
      ),
    );
  }
}
