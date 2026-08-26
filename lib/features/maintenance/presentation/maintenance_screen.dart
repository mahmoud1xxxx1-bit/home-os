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
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

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
        _MaintenanceIntro(lang: lang),
        const SizedBox(height: 14),
        if (records.length > 4)
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              labelText: lang == 'ar' ? 'بحث في الصيانة أو الأصل' : 'Search maintenance or asset',
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        if (records.length > 4) const SizedBox(height: 16),
        if (records.isEmpty)
          EmptyState(
            icon: Icons.handyman_rounded,
            title: lang == 'ar' ? 'لا توجد سجلات صيانة' : 'No maintenance records',
            message: lang == 'ar'
                ? 'سجّل الصيانة بعد تنفيذها واربطها بالأصل. الموعد القادم اختياري ولن نضع تاريخًا من عندنا.'
                : 'Record maintenance after it is done and link it to the asset. The next due date is optional and never guessed for you.',
            actionLabel: lang == 'ar' ? 'إضافة أول صيانة' : 'Add first maintenance',
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.handyman_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showDetails(context, record, assetName, lang),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.description.value(lang), style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 5),
                              Text(assetName, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 5),
                              Text('${compactDate(record.date, lang)} • ${record.cost.toStringAsFixed(0)} SAR'),
                              if (record.nextDue != null) ...[
                                const SizedBox(height: 5),
                                Text(
                                  '${lang == 'ar' ? 'القادم' : 'Next'}: ${compactDate(record.nextDue!, lang)}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: lang == 'ar' ? 'تعديل السجل' : 'Edit record',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showForm(context, record),
                    ),
                  ],
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
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.description.value(lang), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _DetailRow(label: lang == 'ar' ? 'الأصل' : 'Asset', value: assetName),
            _DetailRow(label: lang == 'ar' ? 'التكلفة' : 'Cost', value: '${record.cost.toStringAsFixed(0)} SAR'),
            _DetailRow(label: lang == 'ar' ? 'تاريخ الصيانة' : 'Maintenance date', value: compactDate(record.date, lang)),
            if (record.nextDue != null)
              _DetailRow(label: lang == 'ar' ? 'الموعد القادم' : 'Next due', value: compactDate(record.nextDue!, lang)),
          ],
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
    var maintenanceDate = existing?.date ?? DateTime.now();
    DateTime? nextDue = existing?.nextDue;

    if (existing != null && assets.any((asset) => asset.id == existing.assetId)) {
      selectedAssetId = existing.assetId;
    } else if (assets.isNotEmpty) {
      selectedAssetId = assets.first.id;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final keyboard = MediaQuery.viewInsetsOf(ctx).bottom;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: keyboard),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: keyboard > 0 ? .92 : .8,
              minChildSize: .58,
              maxChildSize: .94,
              builder: (ctx, scrollController) => Material(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(99)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              existing == null ? (lang == 'ar' ? 'إضافة صيانة' : 'Add maintenance') : (lang == 'ar' ? 'تعديل الصيانة' : 'Edit maintenance'),
                              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lang == 'ar'
                                  ? 'سجّل ما تم فعليًا. الموعد القادم اختياري ويجب أن تختاره أنت.'
                                  : 'Record what actually happened. The next due date is optional and always chosen by you.',
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant, height: 1.45),
                            ),
                            const SizedBox(height: 18),
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
                              TextField(
                                controller: descCtrl,
                                autofocus: true,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(labelText: lang == 'ar' ? 'ماذا تم في الصيانة؟' : 'What was done?'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: costCtrl,
                                decoration: InputDecoration(labelText: lang == 'ar' ? 'التكلفة' : 'Cost', suffixText: 'SAR'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 12),
                              _DatePickerTile(
                                icon: Icons.event_available_outlined,
                                title: lang == 'ar' ? 'تاريخ الصيانة' : 'Maintenance date',
                                value: compactDate(maintenanceDate, lang),
                                action: lang == 'ar' ? 'تغيير' : 'Change',
                                onTap: () async {
                                  FocusScope.of(ctx).unfocus();
                                  final picked = await showDatePicker(
                                    context: ctx,
                                    initialDate: maintenanceDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) setSheetState(() => maintenanceDate = picked);
                                },
                              ),
                              const SizedBox(height: 10),
                              _DatePickerTile(
                                icon: Icons.notifications_active_outlined,
                                title: lang == 'ar' ? 'الموعد القادم (اختياري)' : 'Next due date (optional)',
                                value: nextDue == null ? (lang == 'ar' ? 'غير محدد' : 'Not set') : compactDate(nextDue!, lang),
                                action: nextDue == null ? (lang == 'ar' ? 'إضافة' : 'Add') : (lang == 'ar' ? 'تغيير' : 'Change'),
                                onTap: () async {
                                  FocusScope.of(ctx).unfocus();
                                  final base = nextDue ?? maintenanceDate.add(const Duration(days: 30));
                                  final picked = await showDatePicker(
                                    context: ctx,
                                    initialDate: base,
                                    firstDate: maintenanceDate,
                                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                                  );
                                  if (picked != null) setSheetState(() => nextDue = picked);
                                },
                                onClear: nextDue == null ? null : () => setSheetState(() => nextDue = null),
                              ),
                              const SizedBox(height: 20),
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
                                    date: maintenanceDate,
                                    type: existing?.type ?? const LocalizedText(ar: 'عام', en: 'General'),
                                    description: LocalizedText(ar: descCtrl.text.trim(), en: descCtrl.text.trim()),
                                    cost: cost,
                                    nextDue: nextDue,
                                  );
                                  ref.read(maintenanceRepositoryProvider).addMaintenance(record);
                                  ref.invalidate(maintenanceProvider);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(lang == 'ar' ? 'تم حفظ سجل الصيانة' : 'Maintenance record saved')),
                                  );
                                },
                                child: Text(lang == 'ar' ? 'حفظ سجل الصيانة' : 'Save maintenance record'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MaintenanceIntro extends StatelessWidget {
  const _MaintenanceIntro({required this.lang});
  final String lang;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang == 'ar' ? 'تاريخ واضح لكل أصل' : 'A clear history for every asset', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    lang == 'ar'
                        ? 'سجّل ما تم وتكلفته، وحدد الموعد القادم فقط إذا كنت تعرفه.'
                        : 'Record what was done and its cost. Set a next date only when you actually know it.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.icon, required this.title, required this.value, required this.action, required this.onTap, this.onClear});
  final IconData icon;
  final String title;
  final String value;
  final String action;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value),
          trailing: Wrap(
            spacing: 2,
            children: [
              if (onClear != null) IconButton(onPressed: onClear, icon: const Icon(Icons.close_rounded), tooltip: 'Clear'),
              TextButton(onPressed: onTap, child: Text(action)),
            ],
          ),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
            const SizedBox(width: 10),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
