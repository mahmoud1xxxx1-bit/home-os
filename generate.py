import os

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# 1. Maintenance Screen
maintenance = """import 'package:flutter/material.dart';
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
        if (records.isEmpty)
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.handyman_rounded),
              title: Text(lang == 'ar' ? 'لا توجد سجلات صيانة' : 'No maintenance records'),
            ),
          )
        else
          ...records.map((r) => AppCard(
            child: ListTile(
              title: Text(r.description.value(lang)),
              subtitle: Text('${r.type.value(lang)} • ${compactDate(r.date, lang)} • ${r.cost} SAR\\nProvider ID: ${r.providerId ?? "N/A"}'),
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
"""

write_file('lib/features/maintenance/presentation/maintenance_screen.dart', maintenance)

# 2. Services Screen
services = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../l10n/app_localizations.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.services;

    return ResponsivePage(
      title: l10n.services,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showForm(context, ref, null),
        ),
      ],
      children: [
        if (items.isEmpty)
          const AppCard(child: ListTile(title: Text('No recurring services')))
        else
          ...items.map((s) => AppCard(
            child: ListTile(
              title: Text(s.name.value(lang)),
              subtitle: Text('${s.frequency.value(lang)} • ${s.cost} SAR\\nLast: ${compactDate(s.lastVisit, lang)} | Next: ${compactDate(s.nextVisit, lang)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Mark Completed',
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    onPressed: () {
                      store.markServiceVisitCompleted(s.id);
                      ref.invalidate(activityProvider);
                    },
                  ),
                  IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _showForm(context, ref, s)),
                ],
              ),
            ),
          )),
      ],
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, ServicePlan? existing) {
    final nameCtrl = TextEditingController(text: existing?.name.en);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Service'),
      content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save'))
      ]
    ));
  }
}
"""
write_file('lib/features/services/presentation/services_screen.dart', services)

# 3. Providers Screen
providers = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.watchProviders();

    return ResponsivePage(
      title: l10n.providers,
      actions: [
        IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showForm(context, ref, null)),
      ],
      children: [
        if (items.isEmpty)
          const AppCard(child: ListTile(title: Text('No providers')))
        else
          ...items.map((p) => AppCard(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text('${p.type.value(lang)} • ${p.phone}\\nVisits: ${p.visitCount} | Total Paid: ${p.totalPaid} SAR'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _showForm(context, ref, p)),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () {
                     store.deleteProvider(p.id);
                  }),
                ],
              ),
            ),
          )),
      ],
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, ProviderContact? p) {
    final nameCtrl = TextEditingController(text: p?.name);
    final phoneCtrl = TextEditingController(text: p?.phone);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Provider'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
      ]),
      actions: [
        FilledButton(onPressed: () {
          ref.read(localStoreProvider).upsertProvider(ProviderContact(
            id: p?.id ?? 'p-${DateTime.now().millisecondsSinceEpoch}',
            name: nameCtrl.text,
            type: p?.type ?? const LocalizedText(ar: 'عام', en: 'General'),
            phone: phoneCtrl.text,
            whatsApp: phoneCtrl.text,
            visitCount: p?.visitCount ?? 0,
            totalPaid: p?.totalPaid ?? 0,
            lastVisit: p?.lastVisit ?? DateTime.now(),
            linkedAssetIds: p?.linkedAssetIds ?? const [],
          ));
          Navigator.pop(ctx);
        }, child: const Text('Save'))
      ]
    ));
  }
}
"""
write_file('lib/features/providers/presentation/providers_screen.dart', providers)

# 4. Warranties Screen
warranties = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../l10n/app_localizations.dart';

class WarrantiesScreen extends ConsumerWidget {
  const WarrantiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.warranties;

    return ResponsivePage(
      title: l10n.warranties,
      actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})],
      children: [
        if (items.isEmpty)
          const AppCard(child: ListTile(title: Text('No warranties')))
        else
          ...items.map((w) => AppCard(
            child: ListTile(
              leading: Icon(w.status == WarrantyStatus.valid ? Icons.verified : Icons.warning_amber),
              title: Text(w.provider),
              subtitle: Text('Number: ${w.number}\\nExpires: ${compactDate(w.end, lang)} (${w.status.name})'),
              trailing: IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () {}),
            ),
          )),
      ],
    );
  }
}
"""
write_file('lib/features/warranties/presentation/warranties_screen.dart', warranties)

# 5. Documents Screen
documents = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.watchDocuments();

    return ResponsivePage(
      title: l10n.documents,
      actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})],
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Invoices', 'Warranties', 'Contracts', 'Insurance', 'Manuals', 'Reports', 'Other']
                .map((e) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(e), selected: e == 'All'))).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const AppCard(child: ListTile(title: Text('No documents')))
        else
          ...items.map((d) => AppCard(
            child: ListTile(
              leading: const Icon(Icons.description_rounded),
              title: Text(d.title.value(lang)),
              subtitle: Text('${d.category.value(lang)} • ${d.placeholder}'),
              trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => store.deleteDocument(d.id)),
            ),
          )),
      ],
    );
  }
}
"""
write_file('lib/features/documents/presentation/documents_screen.dart', documents)

# 6. Expenses Screen
expenses = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.watchExpenses();
    final total = items.fold<double>(0, (sum, e) => sum + e.amount);

    return ResponsivePage(
      title: l10n.expenses,
      actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})],
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(lang == 'ar' ? 'إجمالي المصاريف' : 'Total Expenses', style: Theme.of(context).textTheme.titleMedium),
                Text('${total.toStringAsFixed(2)} SAR', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const AppCard(child: ListTile(title: Text('No expenses')))
        else
          ...items.map((e) => AppCard(
            child: ListTile(
              leading: const Icon(Icons.payments_rounded),
              title: Text(e.title.value(lang)),
              subtitle: Text(e.category.value(lang)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${e.amount} SAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => store.deleteExpense(e.id)),
                ],
              ),
            ),
          )),
      ],
    );
  }
}
"""
write_file('lib/features/expenses/presentation/expenses_screen.dart', expenses)

# 7. Family Screen
family = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.family;

    return ResponsivePage(
      title: l10n.family,
      actions: [
        IconButton(
          tooltip: 'Invite Member',
          icon: const Icon(Icons.person_add_rounded),
          onPressed: () {
            store.upsertFamilyMember(FamilyMember(
              id: 'f-${DateTime.now().millisecondsSinceEpoch}',
              name: 'New Invite',
              role: FamilyRole.viewer,
              status: const LocalizedText(ar: 'مدعو', en: 'Invited'),
            ));
          },
        )
      ],
      children: [
        AppCard(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(lang == 'ar' ? 'المشاهد لا يمكنه التعديل أو الحذف.' : 'Viewers cannot edit or delete data.')),
            ],
          ),
        )),
        const SizedBox(height: 16),
        ...items.map((m) => AppCard(
          child: ListTile(
            leading: CircleAvatar(child: Text(m.name[0])),
            title: Text(m.name),
            subtitle: Text('${m.role.name} • ${m.status.value(lang)}'),
            trailing: PopupMenuButton<FamilyRole>(
              onSelected: (role) {
                store.upsertFamilyMember(FamilyMember(id: m.id, name: m.name, role: role, status: m.status));
              },
              itemBuilder: (ctx) => FamilyRole.values.map((r) => PopupMenuItem(value: r, child: Text(r.name))).toList(),
            ),
          ),
        )),
      ],
    );
  }
}
"""
write_file('lib/features/family/presentation/family_screen.dart', family)

print("Files generated.")
