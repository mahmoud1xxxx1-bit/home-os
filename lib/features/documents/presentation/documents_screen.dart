import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        if (items.isEmpty) EmptyState(icon: Icons.description_rounded, title: lang == 'ar' ? 'لا توجد مستندات' : 'No documents', message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () {})
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
