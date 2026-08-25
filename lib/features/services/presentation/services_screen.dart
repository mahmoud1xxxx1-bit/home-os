import 'package:flutter/material.dart';
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
        if (items.isEmpty) EmptyState(icon: Icons.cleaning_services_rounded, title: lang == 'ar' ? 'لا توجد خدمات' : 'No recurring services', message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () => _showForm(context, ref, null))
        else
          ...items.map((s) => AppCard(
            child: ListTile(
              title: Text(s.name.value(lang)),
              subtitle: Text('${s.frequency.value(lang)} • ${s.cost} SAR\nLast: ${compactDate(s.lastVisit, lang)} | Next: ${compactDate(s.nextVisit, lang)}'),
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
