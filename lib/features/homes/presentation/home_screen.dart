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
    final setupStep = locations.isEmpty ? 0 : (assets.isEmpty ? 1 : 2);

    return ResponsivePage(
      title: l10n.house,
      children: [
        _SetupJourney(
          lang: lang,
          currentStep: setupStep,
          locationsCount: locations.length,
          assetsCount: assets.length,
          onAddLocation: () => context.push('/manage/locations'),
          onAddAsset: () => context.push('/asset/new'),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'غرف ومواقع المنزل' : 'Rooms & locations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang == 'ar'
                        ? 'كل أصل يجب أن يكون داخل غرفة أو موقع واضح.'
                        : 'Every asset belongs to a clear room or location.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/manage/locations'),
              icon: const Icon(Icons.add_rounded),
              label: Text(lang == 'ar' ? 'موقع' : 'Location'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (locations.isEmpty)
          EmptyState(
            icon: Icons.room_preferences_rounded,
            title: lang == 'ar' ? 'ابدأ بالغرفة الأولى' : 'Start with your first room',
            message: lang == 'ar'
                ? 'مثال: الصالة، المطبخ، غرفة النوم أو المرآب. بعدها ستضيف الأجهزة والممتلكات داخلها.'
                : 'For example: living room, kitchen, bedroom or garage. Then add the assets that belong there.',
            actionLabel: lang == 'ar' ? 'إضافة غرفة أو موقع' : 'Add room or location',
            onAction: () => context.push('/manage/locations'),
          )
        else
          for (final location in locations)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LocationCard(
                name: location.name.value(lang),
                assets: assets.where((asset) => asset.locationId == location.id).toList(),
                lang: lang,
                onAddAsset: () => context.push('/asset/new'),
                onAssetTap: (id) => context.push('/asset/$id'),
              ),
            ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SetupJourney extends StatelessWidget {
  const _SetupJourney({
    required this.lang,
    required this.currentStep,
    required this.locationsCount,
    required this.assetsCount,
    required this.onAddLocation,
    required this.onAddAsset,
  });

  final String lang;
  final int currentStep;
  final int locationsCount;
  final int assetsCount;
  final VoidCallback onAddLocation;
  final VoidCallback onAddAsset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = currentStep >= 2;
    final title = switch (currentStep) {
      0 => lang == 'ar' ? 'الخطوة التالية: أضف غرفة' : 'Next step: add a room',
      1 => lang == 'ar' ? 'الخطوة التالية: أضف أول أصل' : 'Next step: add your first asset',
      _ => lang == 'ar' ? 'منزلك منظم وجاهز للمتابعة' : 'Your home is organized and ready',
    };
    final description = switch (currentStep) {
      0 => lang == 'ar'
          ? 'نبدأ بالمكان أولًا حتى يكون لكل جهاز وممتلك موضع واضح.'
          : 'Start with locations so every device and belonging has a clear place.',
      1 => lang == 'ar'
          ? 'اختر الغرفة ثم أضف الأجهزة أو الممتلكات الموجودة فيها.'
          : 'Choose a room, then add the devices or belongings inside it.',
      _ => lang == 'ar'
          ? 'افتح أي أصل لإدارة صيانته وضمانه ومستنداته من مكان واحد.'
          : 'Open any asset to manage maintenance, warranty and documents in one place.',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [scheme.primaryContainer, scheme.secondaryContainer.withValues(alpha: .72)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .72), borderRadius: BorderRadius.circular(16)),
                child: Icon(complete ? Icons.check_circle_rounded : Icons.route_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          Row(
            children: [
              _StepDot(number: 1, label: lang == 'ar' ? 'المكان' : 'Room', done: locationsCount > 0, active: currentStep == 0),
              const Expanded(child: Divider(indent: 8, endIndent: 8)),
              _StepDot(number: 2, label: lang == 'ar' ? 'الأصول' : 'Assets', done: assetsCount > 0, active: currentStep == 1),
              const Expanded(child: Divider(indent: 8, endIndent: 8)),
              _StepDot(number: 3, label: lang == 'ar' ? 'المتابعة' : 'Track', done: complete, active: currentStep >= 2),
            ],
          ),
          if (!complete) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: currentStep == 0 ? onAddLocation : onAddAsset,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(currentStep == 0
                    ? (lang == 'ar' ? 'إضافة غرفة أو موقع' : 'Add room or location')
                    : (lang == 'ar' ? 'إضافة أول أصل' : 'Add first asset')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.label, required this.done, required this.active});
  final int number;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = done || active ? scheme.primary : scheme.outline;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: done ? color : color.withValues(alpha: .10), shape: BoxShape.circle, border: Border.all(color: color)),
          child: Center(
            child: done
                ? Icon(Icons.check_rounded, size: 18, color: scheme.onPrimary)
                : Text('$number', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: color)),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.name, required this.assets, required this.lang, required this.onAddAsset, required this.onAssetTap});

  final String name;
  final List<dynamic> assets;
  final String lang;
  final VoidCallback onAddAsset;
  final ValueChanged<String> onAssetTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: .65), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.room_preferences_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
                child: Text('${assets.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (assets.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(16)),
              child: Text(lang == 'ar' ? 'لا توجد أصول هنا بعد. أضف أول جهاز أو ممتلك لهذه الغرفة.' : 'No assets here yet. Add the first device or belonging for this room.'),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final asset in assets)
                  ActionChip(
                    avatar: Icon(asset.vehicle == null ? Icons.devices_other_rounded : Icons.directions_car_rounded),
                    label: Text(asset.name.value(lang)),
                    onPressed: () => onAssetTap(asset.id as String),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(onPressed: onAddAsset, icon: const Icon(Icons.add_rounded), label: Text(lang == 'ar' ? 'إضافة أصل لهذه الغرفة' : 'Add asset to this room')),
          ),
        ],
      ),
    );
  }
}
