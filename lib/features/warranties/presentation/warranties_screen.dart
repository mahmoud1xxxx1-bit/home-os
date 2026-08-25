import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/extended_repository_providers.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class WarrantiesScreen extends ConsumerWidget {
  const WarrantiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(warrantiesProvider);

    return ResponsivePage(
      title: l10n.warranties,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة ضمان' : 'Add warranty',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showForm(context, ref, null, lang),
        ),
      ],
      children: [
        Text(
          lang == 'ar' ? 'تابع الضمانات قبل انتهائها واربطها بأصول منزلك.' : 'Track warranties before they expire and keep them tied to your home assets.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.verified_rounded,
            title: lang == 'ar' ? 'لا توجد ضمانات' : 'No warranties yet',
            message: lang == 'ar' ? 'أضف أول ضمان وسنوضح لك حالته وموعد انتهائه.' : 'Add your first warranty to keep its status and expiry visible.',
            actionLabel: lang == 'ar' ? 'إضافة ضمان' : 'Add warranty',
            onAction: () => _showForm(context, ref, null, lang),
          )
        else
          ...items.map(
            (warranty) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _StatusIcon(status: warranty.status),
                  title: Text(warranty.provider, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${lang == 'ar' ? 'الرقم' : 'Number'}: ${warranty.number}\n'
                    '${lang == 'ar' ? 'ينتهي' : 'Expires'}: ${compactDate(warranty.end, lang)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _WarrantyBadge(status: warranty.status, lang: lang),
                      const SizedBox(height: 4),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'edit') _showForm(context, ref, warranty, lang);
                          if (value == 'delete') _delete(context, ref, warranty, lang);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text(lang == 'ar' ? 'تعديل' : 'Edit')),
                          PopupMenuItem(value: 'delete', child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Warranty warranty, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang == 'ar' ? 'حذف الضمان؟' : 'Delete warranty?'),
            content: Text(lang == 'ar' ? 'سيتم حذف ضمان ${warranty.provider} من Home OS.' : '${warranty.provider} warranty will be removed from Home OS.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    ref.read(warrantyRepositoryProvider).deleteWarranty(warranty.id);
    ref.invalidate(warrantiesProvider);
  }

  void _showForm(BuildContext context, WidgetRef ref, Warranty? existing, String lang) {
    final providerCtrl = TextEditingController(text: existing?.provider);
    final numberCtrl = TextEditingController(text: existing?.number);
    var status = existing?.status ?? WarrantyStatus.valid;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? (lang == 'ar' ? 'إضافة ضمان' : 'Add warranty') : (lang == 'ar' ? 'تعديل الضمان' : 'Edit warranty'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: providerCtrl, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'المزوّد أو الشركة' : 'Provider or company')),
              const SizedBox(height: 12),
              TextField(controller: numberCtrl, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'رقم الضمان' : 'Warranty number')),
              const SizedBox(height: 12),
              DropdownButtonFormField<WarrantyStatus>(
                initialValue: status,
                decoration: InputDecoration(labelText: lang == 'ar' ? 'الحالة' : 'Status'),
                items: WarrantyStatus.values.map((value) => DropdownMenuItem(value: value, child: Text(_statusLabel(value, lang)))).toList(),
                onChanged: (value) => setSheetState(() => status = value ?? status),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (providerCtrl.text.trim().isEmpty) return;
                    final now = DateTime.now();
                    final warranty = Warranty(
                      id: existing?.id ?? 'warranty-${now.microsecondsSinceEpoch}',
                      assetId: existing?.assetId ?? 'unassigned',
                      start: existing?.start ?? now,
                      end: existing?.end ?? now.add(const Duration(days: 365)),
                      provider: providerCtrl.text.trim(),
                      number: numberCtrl.text.trim().isEmpty ? '-' : numberCtrl.text.trim(),
                      status: status,
                      documentPlaceholder: existing?.documentPlaceholder,
                    );
                    ref.read(warrantyRepositoryProvider).upsertWarranty(warranty);
                    ref.invalidate(warrantiesProvider);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ الضمان' : 'Warranty saved')));
                  },
                  child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _statusLabel(WarrantyStatus status, String lang) => switch (status) {
      WarrantyStatus.valid => lang == 'ar' ? 'ساري' : 'Valid',
      WarrantyStatus.expiringSoon => lang == 'ar' ? 'ينتهي قريبًا' : 'Expiring soon',
      WarrantyStatus.expired => lang == 'ar' ? 'منتهي' : 'Expired',
    };

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final WarrantyStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      WarrantyStatus.valid => const Color(0xFF41866A),
      WarrantyStatus.expiringSoon => const Color(0xFFC47A32),
      WarrantyStatus.expired => Theme.of(context).colorScheme.error,
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)),
      child: Icon(status == WarrantyStatus.valid ? Icons.verified_rounded : Icons.warning_amber_rounded, color: color),
    );
  }
}

class _WarrantyBadge extends StatelessWidget {
  const _WarrantyBadge({required this.status, required this.lang});
  final WarrantyStatus status;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      WarrantyStatus.valid => const Color(0xFF41866A),
      WarrantyStatus.expiringSoon => const Color(0xFFC47A32),
      WarrantyStatus.expired => Theme.of(context).colorScheme.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
      child: Text(_statusLabel(status, lang), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
