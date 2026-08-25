import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../core/utils/date_formatters.dart';
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
    final store = ref.watch(localStoreProvider);
    final records = store.watchMaintenance().where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.description.value(lang).toLowerCase().contains(_searchQuery.toLowerCase()) || 
             r.type.value(lang).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ResponsivePage(
      title: l10n.maintenance,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showForm(context, ref, null),
        ),
      ],
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            labelText: lang == 'ar' ? 'بحث وتصفية' : 'Search and filter',
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 16),
        if (records.isEmpty) EmptyState(icon: Icons.handyman_rounded, title: lang == 'ar' ? 'لا توجد سجلات صيانة' : 'No maintenance records', message: lang == 'ar' ? 'يمكنك إضافة سجل جديد الآن' : 'You can add a new record now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () => _showForm(context, ref, null))
        else
          ...records.map((r) => AppCard(
            child: ListTile(
              title: Text(r.description.value(lang)),
              subtitle: Text('${r.type.value(lang)} • ${compactDate(r.date, lang)} • ${r.cost} SAR\nProvider ID: ${r.providerId ?? "N/A"}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.info_outline_rounded), onPressed: () {
                     showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Info'), content: Text(lang == 'ar' ? 'يحتوي على: قبل/بعد, فواتير.' : 'Includes before/after placeholders, invoice.')));
                  }),
                  IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _showForm(context, ref, r)),
                ],
              ),
            ),
          )),
      ],
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, MaintenanceRecord? existing) {
    final lang = Localizations.localeOf(context).languageCode;
    final descCtrl = TextEditingController(text: existing?.description.value(lang));
    final costCtrl = TextEditingController(text: existing?.cost.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? (lang == 'ar' ? 'إضافة' : 'Add') : (lang == 'ar' ? 'تعديل' : 'Edit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Cost'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
          FilledButton(
            onPressed: () {
              final store = ref.read(localStoreProvider);
              final r = MaintenanceRecord(
                id: existing?.id ?? 'm-${DateTime.now().millisecondsSinceEpoch}',
                assetId: existing?.assetId ?? 'asset-1',
                date: existing?.date ?? DateTime.now(),
                type: existing?.type ?? LocalizedText(ar: 'عام', en: 'General'),
                description: LocalizedText(ar: descCtrl.text, en: descCtrl.text),
                cost: double.tryParse(costCtrl.text) ?? 0,
                nextDue: DateTime.now().add(const Duration(days: 30)),
              );
              store.addMaintenance(r); 
              Navigator.pop(ctx);
            },
            child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }
}
