import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/extended_repository_providers.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_form_sheet.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(servicesProvider);

    return ResponsivePage(
      title: l10n.services,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة خدمة متكررة' : 'Add recurring service',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showForm(context, ref, null, lang),
        ),
      ],
      children: [
        Text(
          lang == 'ar' ? 'نظّم الخدمات المتكررة مثل تنظيف المسبح والحديقة والصيانة الدورية.' : 'Organize recurring services such as pool cleaning, gardening and regular maintenance.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.cleaning_services_rounded,
            title: lang == 'ar' ? 'لا توجد خدمات متكررة' : 'No recurring services',
            message: lang == 'ar' ? 'أضف خدمة تحتاجها بشكل دوري وسنتابع موعدها القادم.' : 'Add a service you need regularly and keep its next visit visible.',
            actionLabel: lang == 'ar' ? 'إضافة خدمة' : 'Add service',
            onAction: () => _showForm(context, ref, null, lang),
          )
        else
          ...items.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .62),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.cleaning_services_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(service.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${service.frequency.value(lang)} • ${service.cost.toStringAsFixed(0)} SAR\n'
                    '${lang == 'ar' ? 'القادم' : 'Next'}: ${compactDate(service.nextVisit, lang)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'complete') _complete(context, ref, service, lang);
                      if (value == 'edit') _showForm(context, ref, service, lang);
                      if (value == 'delete') _delete(context, ref, service, lang);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'complete', child: ListTile(leading: const Icon(Icons.check_circle_outline_rounded), title: Text(lang == 'ar' ? 'تمت الزيارة' : 'Mark visit complete'))),
                      PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(lang == 'ar' ? 'تعديل' : 'Edit'))),
                      PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error), title: Text(lang == 'ar' ? 'حذف' : 'Delete'))),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _complete(BuildContext context, WidgetRef ref, ServicePlan service, String lang) {
    ref.read(serviceRepositoryProvider).markServiceVisitCompleted(service.id);
    ref.invalidate(servicesProvider);
    ref.invalidate(activityProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم تسجيل الزيارة' : 'Visit marked complete')));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ServicePlan service, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang == 'ar' ? 'حذف الخدمة؟' : 'Delete service?'),
            content: Text(lang == 'ar' ? 'سيتم حذف ${service.name.value(lang)} من جدول الخدمات.' : '${service.name.value(lang)} will be removed from recurring services.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    ref.read(serviceRepositoryProvider).deleteService(service.id);
    ref.invalidate(servicesProvider);
  }

  void _showForm(BuildContext context, WidgetRef ref, ServicePlan? existing, String lang) {
    final nameCtrl = TextEditingController(text: existing?.name.value(lang));
    final frequencyCtrl = TextEditingController(text: existing?.frequency.value(lang));
    final costCtrl = TextEditingController(text: existing?.cost.toString());

    showAppFormSheet<void>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            existing == null ? (lang == 'ar' ? 'إضافة خدمة' : 'Add service') : (lang == 'ar' ? 'تعديل الخدمة' : 'Edit service'),
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: lang == 'ar' ? 'اسم الخدمة' : 'Service name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: frequencyCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: lang == 'ar' ? 'التكرار' : 'Frequency', hintText: lang == 'ar' ? 'مثال: أسبوعيًا' : 'Example: Weekly'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: costCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: lang == 'ar' ? 'التكلفة' : 'Cost', suffixText: 'SAR'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final now = DateTime.now();
              final service = ServicePlan(
                id: existing?.id ?? 'service-${now.microsecondsSinceEpoch}',
                name: LocalizedText(ar: nameCtrl.text.trim(), en: nameCtrl.text.trim()),
                providerId: existing?.providerId ?? '',
                phone: existing?.phone ?? '',
                frequency: LocalizedText(ar: frequencyCtrl.text.trim().isEmpty ? 'شهريًا' : frequencyCtrl.text.trim(), en: frequencyCtrl.text.trim().isEmpty ? 'Monthly' : frequencyCtrl.text.trim()),
                cost: double.tryParse(costCtrl.text) ?? 0,
                lastVisit: existing?.lastVisit ?? now,
                nextVisit: existing?.nextVisit ?? now.add(const Duration(days: 30)),
                notes: existing?.notes,
              );
              ref.read(serviceRepositoryProvider).upsertService(service);
              ref.invalidate(servicesProvider);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ الخدمة' : 'Service saved')));
            },
            child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }
}
