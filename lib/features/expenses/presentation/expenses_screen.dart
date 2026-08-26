import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key, this.assetId});

  final String? assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final assets = ref.watch(assetsProvider);
    HomeAsset? contextAsset;
    if (assetId != null) {
      for (final asset in assets) {
        if (asset.id == assetId) {
          contextAsset = asset;
          break;
        }
      }
    }
    final allItems = ref.watch(expensesProvider);
    final items = assetId == null ? allItems : allItems.where((item) => item.assetId == assetId).toList();
    final total = items.fold<double>(0, (sum, expense) => sum + expense.amount);
    final title = contextAsset == null ? l10n.expenses : '${l10n.expenses} • ${contextAsset.name.value(lang)}';

    return ResponsivePage(
      title: title,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة مصروف' : 'Add expense',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showAdd(context, ref, lang, contextAsset),
        ),
      ],
      children: [
        if (contextAsset != null) ...[
          AppCard(
            child: Row(children: [
              Icon(Icons.payments_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(lang == 'ar' ? 'مصاريف ${contextAsset.name.value(lang)} فقط' : 'Expenses for ${contextAsset.name.value(lang)} only', style: const TextStyle(fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 14),
        ] else ...[
          Text(
            lang == 'ar' ? 'سجّل مصاريف المنزل والخدمات واربط التكلفة بالأصل عند الحاجة.' : 'Track home and service costs and link a cost to an asset when relevant.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 14),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.secondaryContainer, Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .72)]),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(children: [
            Icon(Icons.account_balance_wallet_rounded, size: 32, color: Theme.of(context).colorScheme.onSecondaryContainer),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(contextAsset == null ? (lang == 'ar' ? 'إجمالي المصاريف المسجلة' : 'Total recorded expenses') : (lang == 'ar' ? 'إجمالي مصاريف هذا الأصل' : 'Total for this asset')),
              const SizedBox(height: 4),
              FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: Text('${total.toStringAsFixed(2)} SAR', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900))),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.payments_rounded,
            title: contextAsset == null ? (lang == 'ar' ? 'لا توجد مصاريف' : 'No expenses yet') : (lang == 'ar' ? 'لا توجد مصاريف لهذا الأصل' : 'No expenses for this asset'),
            message: contextAsset == null ? (lang == 'ar' ? 'أضف أول مصروف منزلي أو تكلفة خدمة.' : 'Add your first household expense or service cost.') : (lang == 'ar' ? 'سجّل أي تكلفة تخص ${contextAsset.name.value(lang)} وستبقى مرتبطة به.' : 'Record any cost for ${contextAsset.name.value(lang)} and it will stay linked to it.'),
            actionLabel: lang == 'ar' ? 'إضافة مصروف' : 'Add expense',
            onAction: () => _showAdd(context, ref, lang, contextAsset),
          )
        else
          ...items.map((expense) {
            final assetName = _assetName(assets, expense.assetId, lang);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: .68), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.payments_rounded, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(expense.title.value(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${expense.category.value(lang)} • $assetName', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 5),
                    Text('${expense.amount.toStringAsFixed(2)} SAR', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
                  ])),
                  IconButton(tooltip: lang == 'ar' ? 'حذف' : 'Delete', icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _delete(context, ref, expense, lang)),
                ]),
              ),
            );
          }),
      ],
    );
  }

  String _assetName(List<HomeAsset> assets, String? id, String lang) {
    if (id == null) return lang == 'ar' ? 'عام للمنزل' : 'Home-wide';
    for (final asset in assets) {
      if (asset.id == id) return asset.name.value(lang);
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

  void _showAdd(BuildContext context, WidgetRef ref, String lang, HomeAsset? contextAsset) {
    final title = TextEditingController();
    final category = TextEditingController();
    final amount = TextEditingController();
    final assets = ref.read(assetsProvider);
    String? selectedAssetId = contextAsset?.id;
    String? errorText;

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
            padding: EdgeInsets.only(bottom: keyboard),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: keyboard > 0 ? .9 : .72,
              minChildSize: .52,
              maxChildSize: .94,
              builder: (ctx, controller) => Material(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(lang == 'ar' ? 'إضافة مصروف' : 'Add expense', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(contextAsset == null ? (lang == 'ar' ? 'أضف التكلفة واربطها بالأصل عند الحاجة.' : 'Add the cost and link it to an asset when relevant.') : (lang == 'ar' ? 'سيتم ربط المصروف تلقائيًا بـ ${contextAsset.name.value(lang)}.' : 'This expense will be linked automatically to ${contextAsset.name.value(lang)}.'), style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 18),
                    if (contextAsset != null)
                      AppCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.link_rounded), title: Text(contextAsset.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(lang == 'ar' ? 'مرتبط بهذا الأصل تلقائيًا' : 'Automatically linked to this asset'), trailing: const Icon(Icons.lock_outline_rounded)))
                    else
                      DropdownButtonFormField<String?>(
                        initialValue: selectedAssetId,
                        decoration: InputDecoration(labelText: lang == 'ar' ? 'ربط بأصل (اختياري)' : 'Link to asset (optional)'),
                        items: [
                          DropdownMenuItem<String?>(value: null, child: Text(lang == 'ar' ? 'عام للمنزل' : 'Home-wide')),
                          ...assets.map((asset) => DropdownMenuItem<String?>(value: asset.id, child: Text(asset.name.value(lang)))),
                        ],
                        onChanged: (value) => setSheetState(() => selectedAssetId = value),
                      ),
                    const SizedBox(height: 12),
                    TextField(controller: title, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'اسم المصروف' : 'Expense name')),
                    const SizedBox(height: 12),
                    TextField(controller: category, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'التصنيف' : 'Category')),
                    const SizedBox(height: 12),
                    TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'المبلغ' : 'Amount', suffixText: 'SAR')),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(errorText!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final value = double.tryParse(amount.text.trim());
                        if (title.text.trim().isEmpty || value == null || value < 0) {
                          setSheetState(() => errorText = lang == 'ar' ? 'أدخل اسم المصروف ومبلغًا صحيحًا.' : 'Enter an expense name and a valid amount.');
                          return;
                        }
                        final now = DateTime.now();
                        ref.read(expenseRepositoryProvider).upsertExpense(Expense(
                              id: 'expense-${now.microsecondsSinceEpoch}',
                              title: LocalizedText(ar: title.text.trim(), en: title.text.trim()),
                              category: LocalizedText(ar: category.text.trim().isEmpty ? 'عام' : category.text.trim(), en: category.text.trim().isEmpty ? 'General' : category.text.trim()),
                              assetId: selectedAssetId,
                              amount: value,
                              date: now,
                            ));
                        ref.invalidate(expensesProvider);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ المصروف' : 'Expense saved')));
                      },
                      child: Text(lang == 'ar' ? 'حفظ المصروف' : 'Save expense'),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
