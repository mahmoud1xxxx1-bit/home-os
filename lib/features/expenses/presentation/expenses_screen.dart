import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        if (items.isEmpty) EmptyState(icon: Icons.payments_rounded, title: lang == 'ar' ? 'لا توجد مصاريف' : 'No expenses', message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () {})
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
