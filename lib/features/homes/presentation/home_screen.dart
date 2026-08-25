import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final store = ref.watch(localStoreProvider);
    final assets = ref.watch(assetsProvider);
    return ResponsivePage(
      title: l10n.house,
      children: [
        SectionTitle(l10n.location),
        for (final location in store.watchLocations())
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.room_preferences_rounded),
                      const SizedBox(width: 10),
                      Text(location.name.value(lang), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final asset in assets.where((asset) => asset.locationId == location.id))
                        ActionChip(
                          avatar: Icon(asset.vehicle == null ? Icons.devices_other_rounded : Icons.directions_car_rounded),
                          label: Text(asset.name.value(lang)),
                          onPressed: () => context.push('/asset/${asset.id}'),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded),
                        label: Text(l10n.addAsset),
                        onPressed: () => context.push('/asset/new'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
