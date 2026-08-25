import 'package:flutter/material.dart';
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
        if (items.isEmpty) EmptyState(icon: Icons.verified_rounded, title: lang == 'ar' ? 'لا توجد ضمانات' : 'No warranties', message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () {})
        else
          ...items.map((w) => AppCard(
            child: ListTile(
              leading: Icon(w.status == WarrantyStatus.valid ? Icons.verified : Icons.warning_amber),
              title: Text(w.provider),
              subtitle: Text('Number: ${w.number}\nExpires: ${compactDate(w.end, lang)} (${w.status.name})'),
              trailing: IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () {}),
            ),
          )),
      ],
    );
  }
}
