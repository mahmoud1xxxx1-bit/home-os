import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
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
    final items = ref.watch(documentsProvider);

    return ResponsivePage(
      title: l10n.documents,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة بيانات مستند' : 'Add document metadata',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showAdd(context, ref, lang),
        ),
      ],
      children: [
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cloud_off_rounded, color: Theme.of(context).colorScheme.secondary),
            title: Text(lang == 'ar' ? 'رفع الملفات مؤجل حاليًا' : 'File upload is currently deferred', style: const TextStyle(fontWeight: FontWeight.w750)),
            subtitle: Text(lang == 'ar' ? 'يمكنك حفظ بيانات المستند وتصنيفه الآن. رفع الصور والملفات سيتاح عند تفعيل التخزين السحابي.' : 'You can save document details and categories now. Image and file uploads will be enabled when cloud storage is activated.'),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.description_rounded,
            title: lang == 'ar' ? 'لا توجد مستندات' : 'No documents yet',
            message: lang == 'ar' ? 'ابدأ بفواتير الأجهزة أو الضمانات أو وثائق التأمين.' : 'Start with invoices, warranties or insurance documents.',
            actionLabel: lang == 'ar' ? 'إضافة بيانات مستند' : 'Add document details',
            onAction: () => _showAdd(context, ref, lang),
          )
        else
          ...items.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.description_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(document.title.value(lang), style: const TextStyle(fontWeight: FontWeight.w750)),
                  subtitle: Text(document.category.value(lang)),
                  trailing: IconButton(
                    tooltip: lang == 'ar' ? 'حذف' : 'Delete',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _delete(context, ref, document, lang),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
        ) ??
        false;
    if (!ok) return;
    ref.read(documentRepositoryProvider).deleteDocument(document.id);
    ref.invalidate(documentsProvider);
  }

  void _showAdd(BuildContext context, WidgetRef ref, String lang) {
    final title = TextEditingController();
    final category = TextEditingController();
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
            Text(lang == 'ar' ? 'إضافة بيانات مستند' : 'Add document details', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w850)),
            const SizedBox(height: 16),
            TextField(controller: title, autofocus: true, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: lang == 'ar' ? 'اسم المستند' : 'Document name')),
            const SizedBox(height: 12),
            TextField(controller: category, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'التصنيف' : 'Category')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (title.text.trim().isEmpty) return;
                  final now = DateTime.now();
                  ref.read(documentRepositoryProvider).upsertDocument(
                        HomeDocument(
                          id: 'doc-${now.microsecondsSinceEpoch}',
                          title: LocalizedText(ar: title.text.trim(), en: title.text.trim()),
                          category: LocalizedText(ar: category.text.trim().isEmpty ? 'أخرى' : category.text.trim(), en: category.text.trim().isEmpty ? 'Other' : category.text.trim()),
                          relatedAssetId: null,
                          createdAt: now,
                          placeholder: 'metadata-only',
                        ),
                      );
                  ref.invalidate(documentsProvider);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تم حفظ بيانات المستند' : 'Document details saved')));
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
