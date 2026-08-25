import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
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
    final records = ref.watch(maintenanceProvider).where((r) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return r.description.value(lang).toLowerCase().contains(query) || r.type.value(lang).toLowerCase().contains(query);
    }).toList();

    return ResponsivePage(
      title: l10n.maintenance,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة سجل صيانة' : 'Add maintenance record',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showForm(context, null),
        ),
      ],
      children: [
        Text(
          lang == 'ar' ? 'احتفظ بتاريخ الصيانة والتكلفة والموعد القادم لكل أصل.' : 'Keep maintenance history, costs and the next due date for every asset.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            labelText: lang == 'ar' ? 'بحث في سجلات الصيانة' : 'Search maintenance',
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          EmptyState(
            icon: Icons.handyman_rounded,
            title: lang == 'ar' ? 'لا توجد سجلات صيانة' : 'No maintenance records',
            message: lang == 'ar' ? 'عند تنفيذ أول صيانة أضفها هنا ليبقى تاريخ الأصل واضحًا.' : 'Add your first completed maintenance to start building the asset history.',
            actionLabel: lang == 'ar' ? 'إضافة صيانة' : 'Add maintenance',
            onAction: () => _showForm(context, null),
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.handyman_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(record.description.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${record.type.value(lang)} • ${compactDate(record.date, lang)} • ${record.cost.toStringAsFixed(0)} SAR'),
                  trailing: IconButton(
                    tooltip: lang == 'ar' ? 'التفاصيل' : 'Details',
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () => _showDetails(context, record, lang),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDetails(BuildContext context, MaintenanceRecord record, String lang) {
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
    final lang = Localizations.localeOf(context).languageCode;
    final descCtrl = TextEditingController(text: existing?.description.value(lang));
    final costCtrl = TextEditingController(text: existing?.cost.toString());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                existing == null ? (lang == 'ar' ? 'إضافة صيانة' : 'Add maintenance') : (lang == 'ar' ? 'تعديل الصيانة' : 'Edit maintenance'),
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: descCtrl, autofocus: true, decoration: InputDecoration(labelText: lang == 'ar' ? 'ماذا تم؟' : 'What was done?')),
            const SizedBox(height: 12),
            TextField(controller: costCtrl, decoration: InputDecoration(labelText: lang == 'ar' ? 'التكلفة' : 'Cost'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (descCtrl.text.trim().isEmpty) return;
                  final record = MaintenanceRecord(
                    id: existing?.id ?? 'm-${DateTime.now().millisecondsSinceEpoch}',
                    assetId: existing?.assetId ?? 'unassigned',
                    date: existing?.date ?? DateTime.now(),
                    type: existing?.type ?? const LocalizedText(ar: 'عام', en: 'General'),
                    description: LocalizedText(ar: descCtrl.text.trim(), en: descCtrl.text.trim()),
                    cost: double.tryParse(costCtrl.text) ?? 0,
                    nextDue: existing?.nextDue ?? DateTime.now().add(const Duration(days: 30)),
                  );
                  ref.read(maintenanceRepositoryProvider).addMaintenance(record);
                  ref.invalidate(maintenanceProvider);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ سجل الصيانة' : 'Maintenance saved')));
                },
                child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
