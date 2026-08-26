import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/subscriptions/subscription_gate.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key, this.assetId});

  final String? assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final assets = ref.watch(assetsProvider);
    final contextAsset = assetId == null ? null : assets.where((asset) => asset.id == assetId).firstOrNull;
    final allItems = ref.watch(documentsProvider);
    final items = assetId == null ? allItems : allItems.where((item) => item.relatedAssetId == assetId).toList();
    final title = contextAsset == null ? l10n.documents : '${l10n.documents} • ${contextAsset.name.value(lang)}';

    return ResponsivePage(
      title: title,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة بيانات مستند' : 'Add document metadata',
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            if (ensureDocumentAccess(context, ref)) _showAdd(context, ref, lang, contextAsset);
          },
        ),
      ],
      children: [
        if (contextAsset != null) ...[
          _AssetContextBanner(asset: contextAsset, lang: lang, icon: Icons.description_rounded),
          const SizedBox(height: 14),
        ],
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cloud_off_rounded, color: Theme.of(context).colorScheme.secondary),
            title: Text(lang == 'ar' ? 'رفع الملفات مؤجل حاليًا' : 'File upload is currently deferred', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(lang == 'ar' ? 'يمكنك حفظ بيانات المستند وربطه بالأصل الآن. رفع الصور والملفات سيتاح عند تفعيل التخزين السحابي.' : 'You can save document details and link them to an asset now. Uploads will be enabled when cloud storage is activated.'),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.description_rounded,
            title: contextAsset == null ? (lang == 'ar' ? 'لا توجد مستندات' : 'No documents yet') : (lang == 'ar' ? 'لا توجد مستندات لهذا الأصل' : 'No documents for this asset'),
            message: contextAsset == null ? (lang == 'ar' ? 'ابدأ بفواتير الأجهزة أو الضمانات أو وثائق التأمين.' : 'Start with invoices, warranties or insurance documents.') : (lang == 'ar' ? 'أضف فاتورة الشراء أو كتيب الضمان أو أي مستند يخص ${contextAsset.name.value(lang)}.' : 'Add a purchase invoice, warranty record or any document for ${contextAsset.name.value(lang)}.'),
            actionLabel: lang == 'ar' ? 'إضافة بيانات مستند' : 'Add document details',
            onAction: () {
              if (ensureDocumentAccess(context, ref)) _showAdd(context, ref, lang, contextAsset);
            },
          )
        else
          ...items.map((document) {
            final assetName = _assetName(assets, document.relatedAssetId, lang);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58), borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.description_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(document.title.value(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${document.category.value(lang)} • $assetName', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ]),
                    ),
                    IconButton(tooltip: lang == 'ar' ? 'حذف' : 'Delete', icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _delete(context, ref, document, lang)),
                  ],
                ),
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

  Future<void> _delete(BuildContext context, WidgetRef ref, HomeDocument document, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang == 'ar' ? 'حذف بيانات المستند؟' : 'Delete document details?'),
            content: Text(lang == 'ar' ? 'سيتم حذف ${document.title.value(lang)} من Home OS.' : '${document.title.value(lang)} will be removed from Home OS.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
            ],
          ),
        ) ?? false;
    if (!ok) return;
    ref.read(documentRepositoryProvider).deleteDocument(document.id);
    ref.invalidate(documentsProvider);
  }

  void _showAdd(BuildContext context, WidgetRef ref, String lang, HomeAsset? contextAsset) {
    if (!ensureDocumentAccess(context, ref)) return;
    final title = TextEditingController();
    final category = TextEditingController();
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
              initialChildSize: keyboard > 0 ? .9 : .68,
              minChildSize: .5,
              maxChildSize: .94,
              builder: (ctx, controller) => Material(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(lang == 'ar' ? 'إضافة بيانات مستند' : 'Add document details', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(contextAsset == null ? (lang == 'ar' ? 'احفظ بيانات المستند واربطه بالأصل الصحيح.' : 'Save document details and link them to the right asset.') : (lang == 'ar' ? 'سيتم ربط هذا المستند تلقائيًا بـ ${contextAsset.name.value(lang)}.' : 'This document will be linked automatically to ${contextAsset.name.value(lang)}.'), style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 18),
                    if (contextAsset != null)
                      _LockedAssetTile(asset: contextAsset, lang: lang)
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
                    TextField(controller: title, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'اسم المستند' : 'Document name')),
                    const SizedBox(height: 12),
                    TextField(controller: category, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'التصنيف' : 'Category')),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(errorText!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        if (title.text.trim().isEmpty) {
                          setSheetState(() => errorText = lang == 'ar' ? 'اكتب اسم المستند أولًا.' : 'Enter a document name first.');
                          return;
                        }
                        final now = DateTime.now();
                        ref.read(documentRepositoryProvider).upsertDocument(HomeDocument(
                              id: 'doc-${now.microsecondsSinceEpoch}',
                              title: LocalizedText(ar: title.text.trim(), en: title.text.trim()),
                              category: LocalizedText(ar: category.text.trim().isEmpty ? 'أخرى' : category.text.trim(), en: category.text.trim().isEmpty ? 'Other' : category.text.trim()),
                              relatedAssetId: selectedAssetId,
                              createdAt: now,
                              placeholder: 'metadata-only',
                            ));
                        ref.invalidate(documentsProvider);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ بيانات المستند' : 'Document details saved')));
                      },
                      child: Text(lang == 'ar' ? 'حفظ المستند' : 'Save document'),
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

class _AssetContextBanner extends StatelessWidget {
  const _AssetContextBanner({required this.asset, required this.lang, required this.icon});
  final HomeAsset asset;
  final String lang;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(lang == 'ar' ? 'أنت تدير الآن: ${asset.name.value(lang)}' : 'Managing: ${asset.name.value(lang)}', style: const TextStyle(fontWeight: FontWeight.w800))),
        ]),
      );
}

class _LockedAssetTile extends StatelessWidget {
  const _LockedAssetTile({required this.asset, required this.lang});
  final HomeAsset asset;
  final String lang;

  @override
  Widget build(BuildContext context) => AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.link_rounded),
          title: Text(asset.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(lang == 'ar' ? 'مرتبط بهذا الأصل تلقائيًا' : 'Automatically linked to this asset'),
          trailing: const Icon(Icons.lock_outline_rounded),
        ),
      );
}
