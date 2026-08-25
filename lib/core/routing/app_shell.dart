import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/quick_add_sheet.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      _Destination(l10n.home, Icons.home_rounded),
      _Destination(l10n.house, Icons.maps_home_work_rounded),
      _Destination(l10n.schedule, Icons.event_available_rounded),
      _Destination(l10n.activity, Icons.history_rounded),
      _Destination(l10n.more, Icons.more_horiz_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        return Scaffold(
          body: Row(
            children: [
              if (desktop)
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  extended: constraints.maxWidth >= 1180,
                  labelType: constraints.maxWidth >= 1180
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label)),
                  ],
                ),
              Expanded(child: navigationShell),
            ],
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  destinations: [
                    for (final item in destinations)
                      NavigationDestination(icon: Icon(item.icon), label: item.label),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            tooltip: l10n.quickAdd,
            onPressed: () => showQuickAddSheet(context),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon);

  final String label;
  final IconData icon;
}
