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
    final items = ref.watch(providersProvider);

    return ResponsivePage(
      title: l10n.providers,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة مقدم خدمة' : 'Add provider',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showForm(context, ref, null),
        ),
      ],
      children: [
        Text(
          lang == 'ar' ? 'احتفظ بأرقام الفنيين والشركات وسجل الزيارات في مكان واحد.' : 'Keep technicians, companies and visit history in one place.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.contacts_rounded,
            title: lang == 'ar' ? 'لا يوجد مقدمو خدمة' : 'No providers yet',
            message: lang == 'ar' ? 'أضف أول فني أو شركة تتعامل معها.' : 'Add the first technician or company you work with.',
            actionLabel: lang == 'ar' ? 'إضافة مقدم خدمة' : 'Add provider',
            onAction: () => _showForm(context, ref, null),
          )
        else
          ...items.map(
            (provider) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(provider.name.isEmpty ? '?' : provider.name.characters.first.toUpperCase()),
                  ),
                  title: Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${provider.type.value(lang)} • ${provider.phone}\n${lang == 'ar' ? 'الزيارات' : 'Visits'}: ${provider.visitCount}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _showForm(context, ref, provider);
                      if (value == 'delete') _delete(context, ref, provider, lang);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(lang == 'ar' ? 'تعديل' : 'Edit'))),
                      PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), title: Text(lang == 'ar' ? 'حذف' : 'Delete'))),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ProviderContact provider, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.delete_outline_rounded),
            title: Text(lang == 'ar' ? 'حذف مقدم الخدمة؟' : 'Delete provider?'),
            content: Text(lang == 'ar' ? 'سيتم حذف ${provider.name} من قائمتك. لن تُحذف سجلات الصيانة السابقة.' : '${provider.name} will be removed. Existing maintenance history will remain.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    ref.read(providerRepositoryProvider).deleteProvider(provider.id);
    ref.invalidate(providersProvider);
  }

  void _showForm(BuildContext context, WidgetRef ref, ProviderContact? provider) {
    final lang = Localizations.localeOf(context).languageCode;
    final nameCtrl = TextEditingController(text: provider?.name);
    final phoneCtrl = TextEditingController(text: provider?.phone);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider == null ? (lang == 'ar' ? 'إضافة مقدم خدمة' : 'Add provider') : (lang == 'ar' ? 'تعديل مقدم الخدمة' : 'Edit provider'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'الاسم' : 'Name', prefixIcon: const Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'رقم الهاتف' : 'Phone', prefixIcon: const Icon(Icons.phone_outlined))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  ref.read(providerRepositoryProvider).upsertProvider(
                        ProviderContact(
                          id: provider?.id ?? 'p-${DateTime.now().microsecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          type: provider?.type ?? const LocalizedText(ar: 'عام', en: 'General'),
                          phone: phoneCtrl.text.trim(),
                          whatsApp: provider?.whatsApp ?? phoneCtrl.text.trim(),
                          visitCount: provider?.visitCount ?? 0,
                          totalPaid: provider?.totalPaid ?? 0,
                          lastVisit: provider?.lastVisit ?? DateTime.now(),
                          linkedAssetIds: provider?.linkedAssetIds ?? const [],
                        ),
                      );
                  ref.invalidate(providersProvider);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ مقدم الخدمة' : 'Provider saved')));
                },
                child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
