import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/extended_repository_providers.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final assets = ref.watch(assetsProvider);
    final matching = assets.where((item) => item.id == id).toList();

    if (matching.isEmpty) {
      return ResponsivePage(
        title: l10n.assets,
        children: [
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              title: Text(lang == 'ar' ? 'جارٍ تحميل الأصل...' : 'Loading asset...'),
              subtitle: Text(
                lang == 'ar'
                    ? 'إذا أضفت الأصل للتو فقد يستغرق وصول التحديث من السحابة لحظة قصيرة.'
                    : 'If you just added this asset, the cloud update may take a brief moment to arrive.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.go('/house'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(lang == 'ar' ? 'العودة إلى المنزل' : 'Back to home'),
          ),
        ],
      );
    }

    final asset = matching.first;
    final maintenance = ref.watch(maintenanceProvider).where((item) => item.assetId == id).toList();
    final warranties = ref.watch(warrantiesProvider).where((item) => item.assetId == id).toList();
    final documents = ref.watch(documentsProvider).where((item) => item.relatedAssetId == id).toList();
    final expenses = ref.watch(expensesProvider).where((item) => item.assetId == id).toList();
    final activity = ref.watch(activityProvider);

    return DefaultTabController(
      length: 6,
      child: ResponsivePage(
        title: asset.name.value(lang),
        actions: [
          IconButton(
            tooltip: lang == 'ar' ? 'أرشفة الأصل' : 'Archive asset',
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => _confirmArchive(context, ref, asset.id, asset.name.value(lang), lang),
          ),
        ],
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(asset.vehicle == null ? Icons.devices_other_rounded : Icons.directions_car_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset.name.value(lang), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(
                            [asset.brand, asset.model].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • ').isEmpty
                                ? (lang == 'ar' ? 'لا توجد تفاصيل إضافية' : 'No additional details')
                                : [asset.brand, asset.model].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • '),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: l10n.overview),
                    Tab(text: l10n.maintenance),
                    Tab(text: l10n.warranty),
                    Tab(text: l10n.documents),
                    Tab(text: l10n.expenses),
                    Tab(text: l10n.activity),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 500,
            child: TabBarView(
              children: [
                _Overview(assetId: id),
                _LinkedSection(
                  items: maintenance.map((item) => '${item.type.value(lang)} • ${compactDate(item.date, lang)} • ${item.cost.toStringAsFixed(0)} SAR').toList(),
                  emptyText: lang == 'ar' ? 'لا توجد صيانة مسجلة لهذا الأصل.' : 'No maintenance recorded for this asset.',
                  buttonLabel: l10n.maintenance,
                  onOpen: () => context.push('/manage/maintenance'),
                ),
                _LinkedSection(
                  items: warranties.map((item) => '${item.provider} • ${compactDate(item.end, lang)}').toList(),
                  emptyText: lang == 'ar' ? 'لا يوجد ضمان مرتبط بهذا الأصل.' : 'No warranty linked to this asset.',
                  buttonLabel: l10n.warranties,
                  onOpen: () => context.push('/manage/warranties'),
                ),
                _LinkedSection(
                  items: documents.map((item) => '${item.title.value(lang)} • ${item.category.value(lang)}').toList(),
                  emptyText: lang == 'ar' ? 'لا توجد مستندات مرتبطة بهذا الأصل.' : 'No documents linked to this asset.',
                  buttonLabel: l10n.documents,
                  onOpen: () => context.push('/manage/documents'),
                ),
                _LinkedSection(
                  items: expenses.map((item) => '${item.title.value(lang)} • ${item.amount.toStringAsFixed(0)} SAR').toList(),
                  emptyText: lang == 'ar' ? 'لا توجد مصاريف مرتبطة بهذا الأصل.' : 'No expenses linked to this asset.',
                  buttonLabel: l10n.expenses,
                  onOpen: () => context.push('/manage/expenses'),
                ),
                _Timeline(
                  items: activity.map((item) => item.description.value(lang)).toList(),
                  emptyText: lang == 'ar' ? 'لا يوجد نشاط مسجل بعد.' : 'No activity recorded yet.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref, String assetId, String name, String lang) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.archive_outlined),
            title: Text(lang == 'ar' ? 'أرشفة الأصل؟' : 'Archive asset?'),
            content: Text(
              lang == 'ar'
                  ? 'سيتم نقل $name إلى الأرشيف بدل حذفه نهائيًا. يمكنك استعادته لاحقًا.'
                  : '$name will be moved to the archive instead of being permanently deleted. You can restore it later.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'أرشفة' : 'Archive')),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final removed = ref.read(assetRepositoryProvider).softDeleteAsset(assetId);
    ref.invalidate(assetsProvider);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang == 'ar' ? 'تم نقل الأصل إلى الأرشيف' : 'Asset moved to archive'),
        action: SnackBarAction(
          label: lang == 'ar' ? 'تراجع' : 'Undo',
          onPressed: () {
            if (removed != null) {
              ref.read(assetRepositoryProvider).restoreAsset(removed);
              ref.invalidate(assetsProvider);
            }
          },
        ),
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final assets = ref.watch(assetsProvider);
    final matching = assets.where((item) => item.id == assetId).toList();
    if (matching.isEmpty) {
      return AppCard(child: Center(child: Text(lang == 'ar' ? 'جارٍ تحديث البيانات...' : 'Refreshing data...')));
    }

    final asset = matching.first;
    final location = ref.watch(homeRepositoryProvider).locationById(asset.locationId);

    return AppCard(
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Chip(l10n.location, location?.name.value(lang) ?? '-'),
            _Chip(l10n.category, asset.category.name),
            _Chip(l10n.brand, asset.brand ?? '-'),
            _Chip(l10n.model, asset.model ?? '-'),
            _Chip(l10n.serialNumber, asset.serialNumber ?? '-'),
            if (asset.purchaseDate != null) _Chip(l10n.purchaseDate, compactDate(asset.purchaseDate!, lang)),
            if (asset.purchasePrice != null) _Chip(l10n.purchasePrice, '${asset.purchasePrice!.toStringAsFixed(0)} SAR'),
            if (asset.vehicle != null) _Chip(l10n.vehicles, '${asset.vehicle!.odometerKm} km'),
            if (asset.notes != null) _Chip(l10n.notes, asset.notes!.value(lang)),
          ],
        ),
      ),
    );
  }
}

class _LinkedSection extends StatelessWidget {
  const _LinkedSection({required this.items, required this.emptyText, required this.buttonLabel, required this.onOpen});

  final List<String> items;
  final String emptyText;
  final String buttonLabel;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _Timeline(items: items, emptyText: emptyText)),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onOpen, child: Text(buttonLabel))),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items, required this.emptyText});

  final List<String> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(emptyText, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.circle, size: 11, color: Theme.of(context).colorScheme.primary),
                title: Text(items[index]),
              ),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
