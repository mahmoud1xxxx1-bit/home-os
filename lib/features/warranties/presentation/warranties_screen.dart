import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/extended_repository_providers.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/subscriptions/subscription_gate.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class WarrantiesScreen extends ConsumerWidget {
  const WarrantiesScreen({super.key, this.assetId});

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
    final allItems = ref.watch(warrantiesProvider);
    final items = assetId == null ? allItems : allItems.where((item) => item.assetId == assetId).toList();
    final title = contextAsset == null ? l10n.warranties : '${l10n.warranties} • ${contextAsset.name.value(lang)}';

    return ResponsivePage(
      title: title,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة ضمان' : 'Add warranty',
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            if (ensureWarrantyAccess(context, ref)) _showForm(context, ref, null, lang, contextAsset);
          },
        ),
      ],
      children: [
        if (contextAsset != null) ...[
          AppCard(
            child: Row(children: [
              Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(lang == 'ar' ? 'ضمانات ${contextAsset.name.value(lang)} فقط' : 'Warranties for ${contextAsset.name.value(lang)} only', style: const TextStyle(fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 14),
        ] else ...[
          Text(
            lang == 'ar' ? 'تابع الضمانات قبل انتهائها واربط كل ضمان بالأصل الصحيح.' : 'Track warranties before they expire and link each warranty to the correct asset.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 14),
        ],
        if (items.isEmpty)
          EmptyState(
            icon: Icons.verified_rounded,
            title: contextAsset == null ? (lang == 'ar' ? 'لا توجد ضمانات' : 'No warranties yet') : (lang == 'ar' ? 'لا يوجد ضمان لهذا الأصل' : 'No warranty for this asset'),
            message: contextAsset == null ? (lang == 'ar' ? 'أضف أول ضمان وسنحسب حالته تلقائيًا من تاريخ الانتهاء.' : 'Add your first warranty and its status will be calculated from the expiry date.') : (lang == 'ar' ? 'أضف ضمان ${contextAsset.name.value(lang)} وسيتم ربطه به مباشرة.' : 'Add the warranty for ${contextAsset.name.value(lang)} and it will be linked automatically.'),
            actionLabel: lang == 'ar' ? 'إضافة ضمان' : 'Add warranty',
            onAction: () {
              if (ensureWarrantyAccess(context, ref)) _showForm(context, ref, null, lang, contextAsset);
            },
          )
        else
          ...items.map((warranty) {
            final assetName = _assetName(assets, warranty.assetId, lang);
            final currentStatus = _statusFor(warranty.end);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 2), child: _StatusIcon(status: currentStatus)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(warranty.provider, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text('$assetName • ${lang == 'ar' ? 'رقم' : 'No.'} ${warranty.number}', maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${lang == 'ar' ? 'ينتهي' : 'Expires'}: ${compactDate(warranty.end, lang)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    _WarrantyBadge(status: currentStatus, lang: lang),
                  ])),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    tooltip: lang == 'ar' ? 'خيارات الضمان' : 'Warranty options',
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'edit') _showForm(context, ref, warranty, lang, contextAsset);
                      if (value == 'delete') _delete(context, ref, warranty, lang);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(lang == 'ar' ? 'تعديل' : 'Edit')),
                      PopupMenuItem(value: 'delete', child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
                    ],
                  ),
                ]),
              ),
            );
          }),
      ],
    );
  }

  String _assetName(List<HomeAsset> assets, String id, String lang) {
    for (final asset in assets) {
      if (asset.id == id) return asset.name.value(lang);
    }
    return lang == 'ar' ? 'أصل غير متاح' : 'Unavailable asset';
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
        ) ?? false;
    if (!ok) return;
    ref.read(warrantyRepositoryProvider).deleteWarranty(warranty.id);
    ref.invalidate(warrantiesProvider);
  }

  void _showForm(BuildContext context, WidgetRef ref, Warranty? existing, String lang, HomeAsset? contextAsset) {
    if (existing == null && !ensureWarrantyAccess(context, ref)) return;
    final assets = ref.read(assetsProvider);
    final providerCtrl = TextEditingController(text: existing?.provider);
    final numberCtrl = TextEditingController(text: existing?.number == '-' ? '' : existing?.number);
    var expiry = existing?.end ?? DateTime.now().add(const Duration(days: 365));
    String? selectedAssetId = contextAsset?.id ?? existing?.assetId;
    if (selectedAssetId == null && assets.isNotEmpty) selectedAssetId = assets.first.id;
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
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: keyboard),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: keyboard > 0 ? .92 : .78,
              minChildSize: .55,
              maxChildSize: .94,
              builder: (ctx, controller) => Material(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(existing == null ? (lang == 'ar' ? 'إضافة ضمان' : 'Add warranty') : (lang == 'ar' ? 'تعديل الضمان' : 'Edit warranty'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(contextAsset == null ? (lang == 'ar' ? 'اربط الضمان بالأصل الصحيح وسنتابع تاريخ انتهائه تلقائيًا.' : 'Link the warranty to the right asset and we will track its expiry automatically.') : (lang == 'ar' ? 'سيتم ربط الضمان تلقائيًا بـ ${contextAsset.name.value(lang)}.' : 'This warranty will be linked automatically to ${contextAsset.name.value(lang)}.'), style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 18),
                    if (assets.isEmpty) ...[
                      AppCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.devices_other_rounded), title: Text(lang == 'ar' ? 'لا يوجد أصل لربط الضمان به' : 'There is no asset to link this warranty to'), subtitle: Text(lang == 'ar' ? 'أضف الأصل أولًا ثم سجّل ضمانه.' : 'Add the asset first, then record its warranty.'))),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(onPressed: () { Navigator.pop(ctx); context.push('/asset/new'); }, icon: const Icon(Icons.add_rounded), label: Text(lang == 'ar' ? 'إضافة أصل' : 'Add asset')),
                    ] else ...[
                      if (contextAsset != null)
                        AppCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.link_rounded), title: Text(contextAsset.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(lang == 'ar' ? 'مرتبط بهذا الأصل تلقائيًا' : 'Automatically linked to this asset'), trailing: const Icon(Icons.lock_outline_rounded)))
                      else
                        DropdownButtonFormField<String>(
                          initialValue: selectedAssetId,
                          decoration: InputDecoration(labelText: lang == 'ar' ? 'الأصل' : 'Asset', prefixIcon: const Icon(Icons.devices_other_rounded)),
                          items: assets.map((asset) => DropdownMenuItem(value: asset.id, child: Text(asset.name.value(lang)))).toList(),
                          onChanged: (value) => selectedAssetId = value,
                        ),
                      const SizedBox(height: 12),
                      TextField(controller: providerCtrl, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'المزوّد أو الشركة' : 'Provider or company')),
                      const SizedBox(height: 12),
                      TextField(controller: numberCtrl, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'رقم الضمان' : 'Warranty number')),
                      const SizedBox(height: 12),
                      AppCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_outlined), title: Text(lang == 'ar' ? 'تاريخ انتهاء الضمان' : 'Warranty expiry'), subtitle: Text(compactDate(expiry, lang)), trailing: TextButton(onPressed: () async { FocusScope.of(ctx).unfocus(); final picked = await showDatePicker(context: ctx, initialDate: expiry, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650))); if (picked != null) setSheetState(() => expiry = picked); }, child: Text(lang == 'ar' ? 'تغيير' : 'Change')))),
                      const SizedBox(height: 8),
                      Align(alignment: AlignmentDirectional.centerStart, child: _WarrantyBadge(status: _statusFor(expiry), lang: lang)),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(errorText!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          if (selectedAssetId == null || providerCtrl.text.trim().isEmpty) {
                            setSheetState(() => errorText = lang == 'ar' ? 'اختر الأصل واكتب اسم الشركة أو المزوّد.' : 'Select an asset and enter the provider or company.');
                            return;
                          }
                          final now = DateTime.now();
                          final warranty = Warranty(
                            id: existing?.id ?? 'warranty-${now.microsecondsSinceEpoch}',
                            assetId: selectedAssetId!,
                            start: existing?.start ?? now,
                            end: expiry,
                            provider: providerCtrl.text.trim(),
                            number: numberCtrl.text.trim().isEmpty ? '-' : numberCtrl.text.trim(),
                            status: _statusFor(expiry),
                            documentPlaceholder: existing?.documentPlaceholder,
                          );
                          ref.read(warrantyRepositoryProvider).upsertWarranty(warranty);
                          ref.invalidate(warrantiesProvider);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ الضمان وربطه بالأصل' : 'Warranty saved and linked to the asset')));
                        },
                        child: Text(lang == 'ar' ? 'حفظ الضمان' : 'Save warranty'),
                      ),
                    ],
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

WarrantyStatus _statusFor(DateTime expiry) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final end = DateTime(expiry.year, expiry.month, expiry.day);
  if (end.isBefore(today)) return WarrantyStatus.expired;
  if (end.difference(today).inDays <= 30) return WarrantyStatus.expiringSoon;
  return WarrantyStatus.valid;
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
    return Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(status == WarrantyStatus.valid ? Icons.verified_rounded : Icons.warning_amber_rounded, color: color));
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
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)), child: Text(_statusLabel(status, lang), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}
