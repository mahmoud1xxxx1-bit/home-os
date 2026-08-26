import 'package:flutter/material.dart';
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
    final items = ref.watch(expensesProvider);
    final assets = ref.watch(assetsProvider);
    final total = items.fold<double>(0, (sum, expense) => sum + expense.amount);

    return ResponsivePage(
      title: l10n.expenses,
      actions: [IconButton(tooltip: lang == 'ar' ? 'إضافة مصروف' : 'Add expense', icon: const Icon(Icons.add_rounded), onPressed: () => _showAdd(context, ref, lang))],
      children: [
        Text(
          lang == 'ar' ? 'سجّل مصاريف المنزل والخدمات واربط التكلفة بالأصل عند الحاجة.' : 'Track home and service costs and link a cost to an asset when relevant.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.secondaryContainer, Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .72)]),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(children: [
            Icon(Icons.account_balance_wallet_rounded, size: 34, color: Theme.of(context).colorScheme.onSecondaryContainer),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang == 'ar' ? 'إجمالي المصاريف المسجلة' : 'Total recorded expenses', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('${total.toStringAsFixed(2)} SAR', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.payments_rounded,
            title: lang == 'ar' ? 'لا توجد مصاريف' : 'No expenses yet',
            message: lang == 'ar' ? 'أضف أول مصروف منزلي أو تكلفة خدمة.' : 'Add your first household expense or service cost.',
            actionLabel: lang == 'ar' ? 'إضافة مصروف' : 'Add expense',
            onAction: () => _showAdd(context, ref, lang),
          )
        else
          ...items.map((expense) {
            final assetName = _assetName(assets, expense.assetId, lang);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: .68), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.payments_rounded, color: Theme.of(context).colorScheme.secondary),
                  ),
                  title: Text(expense.title.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${expense.category.value(lang)} • $assetName'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('${expense.amount.toStringAsFixed(0)} SAR', style: const TextStyle(fontWeight: FontWeight.w800)),
                    IconButton(tooltip: lang == 'ar' ? 'حذف' : 'Delete', icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _delete(context, ref, expense, lang)),
                  ]),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _assetName(List<HomeAsset> assets, String? assetId, String lang) {
    if (assetId == null) return lang == 'ar' ? 'عام للمنزل' : 'Home-wide';
    for (final asset in assets) {
      if (asset.id == assetId) return asset.name.value(lang);
    }
    return lang == 'ar' ? 'أصل غير متاح' : 'Unavailable asset';
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Expense expense, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang == 'ar' ? 'حذف المصروف؟' : 'Delete expense?'),
            content: Text(lang == 'ar' ? 'سيتم حذف ${expense.title.value(lang)} بقيمة ${expense.amount.toStringAsFixed(0)} SAR.' : '${expense.title.value(lang)} (${expense.amount.toStringAsFixed(0)} SAR) will be removed.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
            ],
          ),
        ) ?? false;
    if (!ok) return;
    ref.read(expenseRepositoryProvider).deleteExpense(expense.id);
    ref.invalidate(expensesProvider);
  }

  void _showAdd(BuildContext context, WidgetRef ref, String lang) {
    final title = TextEditingController();
    final category = TextEditingController();
    final amount = TextEditingController();
    final assets = ref.read(assetsProvider);
    String? selectedAssetId;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(lang == 'ar' ? 'إضافة مصروف' : 'Add expense', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: title, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'اسم المصروف' : 'Expense name')),
            const SizedBox(height: 12),
            TextField(controller: category, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'التصنيف' : 'Category')),
            const SizedBox(height: 12),
            TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'المبلغ' : 'Amount', suffixText: 'SAR')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: selectedAssetId,
              decoration: InputDecoration(labelText: lang == 'ar' ? 'ربط بأصل (اختياري)' : 'Link to asset (optional)'),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(lang == 'ar' ? 'عام للمنزل' : 'Home-wide')),
                ...assets.map((asset) => DropdownMenuItem<String?>(value: asset.id, child: Text(asset.name.value(lang)))),
              ],
              onChanged: (value) => setSheetState(() => selectedAssetId = value),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text);
                if (title.text.trim().isEmpty || value == null || value < 0) return;
                final now = DateTime.now();
                ref.read(expenseRepositoryProvider).upsertExpense(
                      Expense(
                        id: 'expense-${now.microsecondsSinceEpoch}',
                        title: LocalizedText(ar: title.text.trim(), en: title.text.trim()),
                        category: LocalizedText(ar: category.text.trim().isEmpty ? 'عام' : category.text.trim(), en: category.text.trim().isEmpty ? 'General' : category.text.trim()),
                        assetId: selectedAssetId,
                        amount: value,
                        date: now,
                      ),
                    );
                ref.invalidate(expensesProvider);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ المصروف' : 'Expense saved')));
              },
              child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
            ),
          ]),
        ),
      ),
    );
  }
}
