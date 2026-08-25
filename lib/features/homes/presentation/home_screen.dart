import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final homeRepo = ref.watch(homeRepositoryProvider);
    final locations = homeRepo.watchLocations();
    final assets = ref.watch(assetsProvider);

    return ResponsivePage(
      title: l10n.house,
      children: [
        Text(
          lang == 'ar' ? 'رتّب أجهزتك وممتلكاتك حسب الغرفة أو الموقع لتصل إليها بسرعة.' : 'Organize assets by room or location so everything stays easy to find.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        SectionTitle(l10n.location),
        if (locations.isEmpty)
          EmptyState(
            icon: Icons.room_preferences_rounded,
            title: lang == 'ar' ? 'لا توجد مواقع بعد' : 'No locations yet',
            message: lang == 'ar' ? 'أضف غرفتك أو موقعك الأول ثم ابدأ بإضافة الأجهزة.' : 'Add your first room or location, then start adding assets.',
            actionLabel: lang == 'ar' ? 'إدارة المواقع' : 'Manage locations',
            onAction: () => context.push('/manage/locations'),
          )
        else
          for (final location in locations)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.room_preferences_rounded, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(location.name.value(lang), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                      ],
                    ),
                    const SizedBox(height: 14),
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
