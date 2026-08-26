import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/subscriptions/subscription_gate.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final assets = ref.watch(assetsProvider);
    final records = ref.watch(maintenanceProvider).where((record) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final assetName = _assetName(assets, record.assetId, lang).toLowerCase();
      return record.description.value(lang).toLowerCase().contains(query) ||
          record.type.value(lang).toLowerCase().contains(query) ||
          assetName.contains(query);
    }).toList();

    return ResponsivePage(
      title: l10n.maintenance,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة سجل صيانة' : 'Add maintenance record',
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            if (ensureMaintenanceAccess(context, ref)) _showForm(context, null);
          },
        ),
      ],
      children: [
        Text(
          lang == 'ar' ? 'احتفظ بتاريخ الصيانة والتكلفة والموعد القادم لكل أصل.' : 'Keep maintenance history, costs and the next due date for every asset.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), labelText: lang == 'ar' ? 'بحث في الصيانة أو الأصل' : 'Search maintenance or asset'),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          EmptyState(
            icon: Icons.handyman_rounded,
            title: lang == 'ar' ? 'لا توجد سجلات صيانة' : 'No maintenance records',
            message: lang == 'ar' ? 'عند تنفيذ أول صيانة اربطها بالأصل ليبقى تاريخه واضحًا.' : 'Add your first maintenance record and link it to the asset to build a clear history.',
            actionLabel: lang == 'ar' ? 'إضافة صيانة' : 'Add maintenance',
            onAction: () {
              if (ensureMaintenanceAccess(context, ref)) _showForm(context, null);
            },
          )
        else
          ...records.map((record) {
            final assetName = _assetName(assets, record.assetId, lang);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.handyman_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(record.description.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('$assetName • ${compactDate(record.date, lang)} • ${record.cost.toStringAsFixed(0)} SAR'),
                  trailing: IconButton(
                    tooltip: lang == 'ar' ? 'التفاصيل' : 'Details',
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () => _showDetails(context, record, assetName, lang),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _assetName(List<HomeAsset> assets, String assetId, String lang) {
    for (final asset in assets) {
      if (asset.id == assetId) return asset.name.value(lang);
    }
    return lang == 'ar' ? 'أصل غير متاح' : 'Unavailable asset';
  }

  void _showDetails(BuildContext context, MaintenanceRecord record, String assetName, String lang) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.description.value(lang), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text('${lang == 'ar' ? 'الأصل' : 'Asset'}: $assetName'),
              const SizedBox(height: 6),
              Text('${lang == 'ar' ? 'التكلفة' : 'Cost'}: ${record.cost.toStringAsFixed(0)} SAR'),
              const SizedBox(height: 6),
              Text('${lang == 'ar' ? 'التاريخ' : 'Date'}: ${compactDate(record.date, lang)}'),
              if (record.nextDue != null) ...[
                const SizedBox(height: 6),
                Text('${lang == 'ar' ? 'الموعد القادم' : 'Next due'}: ${compactDate(record.nextDue!, lang)}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, MaintenanceRecord? existing) {
    if (existing == null && !ensureMaintenanceAccess(context, ref)) return;

    final lang = Localizations.localeOf(context).languageCode;
    final assets = ref.read(assetsProvider);
    final descCtrl = TextEditingController(text: existing?.description.value(lang));
    final costCtrl = TextEditingController(text: existing?.cost.toString());
    String? selectedAssetId;

    if (existing != null && assets.any((asset) => asset.id == existing.assetId)) {
      selectedAssetId = existing.assetId;
    } else if (assets.isNotEmpty) {
      selectedAssetId = assets.first.id;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(existing == null ? (lang == 'ar' ? 'إضافة صيانة' : 'Add maintenance') : (lang == 'ar' ? 'تعديل الصيانة' : 'Edit maintenance'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (assets.isEmpty) ...[
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.devices_other_rounded),
                  title: Text(lang == 'ar' ? 'لا يوجد أصل لربط الصيانة به' : 'There is no asset to link this maintenance to'),
                  subtitle: Text(lang == 'ar' ? 'أضف أصلًا أولًا ثم سجّل الصيانة.' : 'Add an asset first, then record its maintenance.'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/asset/new');
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(lang == 'ar' ? 'إضافة أصل' : 'Add asset'),
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                initialValue: selectedAssetId,
                decoration: InputDecoration(labelText: lang == 'ar' ? 'الأصل' : 'Asset', prefixIcon: const Icon(Icons.devices_other_rounded)),
                items: assets.map((asset) => DropdownMenuItem(value: asset.id, child: Text(asset.name.value(lang)))).toList(),
                onChanged: (value) => selectedAssetId = value,
              ),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, autofocus: true, decoration: InputDecoration(labelText: lang == 'ar' ? 'ماذا تم؟' : 'What was done?')),
              const SizedBox(height: 12),
              TextField(controller: costCtrl, decoration: InputDecoration(labelText: lang == 'ar' ? 'التكلفة' : 'Cost', suffixText: 'SAR'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  if (existing == null && !ensureMaintenanceAccess(context, ref)) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final cost = double.tryParse(costCtrl.text.trim());
                  if (selectedAssetId == null || descCtrl.text.trim().isEmpty || cost == null || cost < 0) return;
                  final record = MaintenanceRecord(
                    id: existing?.id ?? 'm-${DateTime.now().microsecondsSinceEpoch}',
                    assetId: selectedAssetId!,
                    date: existing?.date ?? DateTime.now(),
                    type: existing?.type ?? const LocalizedText(ar: 'عام', en: 'General'),
                    description: LocalizedText(ar: descCtrl.text.trim(), en: descCtrl.text.trim()),
                    cost: cost,
                    nextDue: existing?.nextDue ?? DateTime.now().add(const Duration(days: 30)),
                  );
                  ref.read(maintenanceRepositoryProvider).addMaintenance(record);
                  ref.invalidate(maintenanceProvider);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم تسجيل الصيانة وربطها بالأصل' : 'Maintenance saved and linked to the asset')));
                },
                child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
