import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/local_repositories.dart';
import '../../l10n/app_localizations.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final locations = ref.watch(homeRepositoryProvider).watchLocations();
    final assets = ref.watch(assetsProvider);
    final setupIncomplete = locations.isEmpty || assets.isEmpty;
    final destinations = [
      _Destination(l10n.home, Icons.home_rounded),
      _Destination(l10n.house, Icons.maps_home_work_rounded),
      _Destination(l10n.schedule, Icons.event_available_rounded),
      _Destination(l10n.activity, Icons.history_rounded),
      _Destination(lang == 'ar' ? 'الإعدادات' : 'Settings', Icons.settings_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final extendedRail = constraints.maxWidth >= 1180;

        return Scaffold(
          body: Row(
            children: [
              if (desktop)
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  extended: extendedRail,
                  labelType: extendedRail ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  groupAlignment: -.78,
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: Column(
                  children: [
                    if (navigationShell.currentIndex == 0 && setupIncomplete)
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: _SetupBanner(
                            lang: lang,
                            hasLocation: locations.isNotEmpty,
                            onTap: () => context.go('/house'),
                          ),
                        ),
                      ),
                    Expanded(child: navigationShell),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  destinations: [
                    for (final item in destinations)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ),
                  ],
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

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({required this.lang, required this.hasLocation, required this.onTap});
  final String lang;
  final bool hasLocation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = hasLocation
        ? (lang == 'ar' ? 'أكمل إعداد منزلك: أضف أول أصل' : 'Finish setup: add your first asset')
        : (lang == 'ar' ? 'ابدأ من هنا: أضف أول غرفة' : 'Start here: add your first room');
    final subtitle = hasLocation
        ? (lang == 'ar' ? 'بعدها ستظهر الصيانة والضمانات والتذكيرات في مكانها الطبيعي.' : 'Maintenance, warranties and reminders will then appear in their natural place.')
        : (lang == 'ar' ? 'سنرتب بعدها الأجهزة والممتلكات داخل الغرف خطوة بخطوة.' : 'Then we will organize devices and belongings room by room.');

    return Material(
      color: scheme.primaryContainer.withValues(alpha: .72),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .8), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.route_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, [IconData? selectedIcon]) : selectedIcon = selectedIcon ?? icon;

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
