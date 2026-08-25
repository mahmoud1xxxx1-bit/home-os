import 'package:flutter/material.dart';
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
        if (items.isEmpty) EmptyState(icon: Icons.contacts_rounded, title: lang == 'ar' ? 'لا يوجد مقدمو خدمة' : 'No providers', message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () => _showForm(context, ref, null))
        else
          ...items.map((p) => AppCard(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text('${p.type.value(lang)} • ${p.phone}\nVisits: ${p.visitCount} | Total Paid: ${p.totalPaid} SAR'),
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
