import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final store = ref.watch(localStoreProvider);
    final asset = store.assetById(id);
    if (asset == null) {
      return ResponsivePage(title: l10n.assets, children: [Text(l10n.genericError)]);
    }
    final maintenance = store.forAsset(id);
    final documents = ref.watch(documentsProvider).where((doc) => doc.relatedAssetId == id).toList();
    final expenses = ref.watch(expensesProvider).where((expense) => expense.assetId == id).toList();

    return DefaultTabController(
      length: 6,
      child: ResponsivePage(
        title: asset.name.value(lang),
        actions: [
          IconButton(
            tooltip: l10n.deleteAccount,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              final removed = store.softDeleteAsset(id);
              ref.invalidate(assetsProvider);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.deletedAsset),
                  action: SnackBarAction(
                    label: l10n.undo,
                    onPressed: () {
                      if (removed != null) {
                        store.restoreAsset(removed);
                        ref.invalidate(assetsProvider);
                      }
                    },
                  ),
                ),
              );
            },
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
                      child: Icon(asset.vehicle == null ? Icons.devices_other_rounded : Icons.directions_car_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset.name.value(lang), style: Theme.of(context).textTheme.titleLarge),
                          Text('${asset.brand ?? ''} ${asset.model ?? ''}'),
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
            height: 480,
            child: TabBarView(
              children: [
                _Overview(assetId: id),
                Column(children: [Expanded(child: _Timeline(items: maintenance.map((m) => '${m.type.value(lang)} • ${compactDate(m.date, lang)} • ${m.cost.toStringAsFixed(0)} SAR').toList())), TextButton(onPressed: () => context.push('/manage/maintenance'), child: Text(l10n.maintenance))]),
                Column(children: [Expanded(child: _Timeline(items: store.warranties.where((w) => w.assetId == id).map((w) => '${w.provider} • ${compactDate(w.end, lang)}').toList())), TextButton(onPressed: () => context.push('/manage/warranties'), child: Text(l10n.warranties))]),
                Column(children: [Expanded(child: _Timeline(items: documents.map((d) => '${d.title.value(lang)} • ${d.category.value(lang)}').toList())), TextButton(onPressed: () => context.push('/manage/documents'), child: Text(l10n.documents))]),
                Column(children: [Expanded(child: _Timeline(items: expenses.map((e) => '${e.title.value(lang)} • ${e.amount.toStringAsFixed(0)} SAR').toList())), TextButton(onPressed: () => context.push('/manage/expenses'), child: Text(l10n.expenses))]),
                _Timeline(items: ref.watch(activityProvider).map((a) => a.description.value(lang)).toList()),
              ],
            ),
          ),
        ],
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
    final store = ref.watch(localStoreProvider);
    final asset = store.assetById(assetId)!;
    final location = store.locationById(asset.locationId);
    return AppCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _Chip(l10n.location, location?.name.value(lang) ?? '-'),
          _Chip(l10n.brand, asset.brand ?? '-'),
          _Chip(l10n.model, asset.model ?? '-'),
          _Chip(l10n.serialNumber, asset.serialNumber ?? '-'),
          if (asset.purchaseDate != null) _Chip(l10n.purchaseDate, compactDate(asset.purchaseDate!, lang)),
          if (asset.purchasePrice != null) _Chip(l10n.purchasePrice, '${asset.purchasePrice!.toStringAsFixed(0)} SAR'),
          if (asset.vehicle != null) _Chip(l10n.vehicles, '${asset.vehicle!.odometerKm} km'),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListView.separated(
        itemCount: items.isEmpty ? 1 : items.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          if (items.isEmpty) {
            return const ListTile(leading: Icon(Icons.inbox_rounded), title: Text('—'));
          }
          return ListTile(leading: const Icon(Icons.circle, size: 12), title: Text(items[index]));
        },
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
