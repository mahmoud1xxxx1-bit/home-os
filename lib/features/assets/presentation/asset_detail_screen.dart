import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/extended_repository_providers.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final assets = ref.watch(assetsProvider);
    final matches = assets.where((asset) => asset.id == id).toList();

    if (matches.isEmpty) {
      return ResponsivePage(
        title: l10n.assets,
        children: [
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.4)),
              title: Text(lang == 'ar' ? 'جارٍ تحميل الأصل...' : 'Loading asset...'),
              subtitle: Text(lang == 'ar' ? 'قد يستغرق وصول آخر تحديث من السحابة لحظة قصيرة.' : 'The latest cloud update may take a brief moment to arrive.'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.go('/house'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(lang == 'ar' ? 'العودة إلى المنزل' : 'Back to home'),
          ),
        ],
      );
    }

    final asset = matches.first;
    final maintenance = ref.watch(maintenanceProvider).where((item) => item.assetId == id).toList()..sort((a, b) => b.date.compareTo(a.date));
    final warranties = ref.watch(warrantiesProvider).where((item) => item.assetId == id).toList()..sort((a, b) => a.end.compareTo(b.end));
    final documents = ref.watch(documentsProvider).where((item) => item.relatedAssetId == id).toList();
    final expenses = ref.watch(expensesProvider).where((item) => item.assetId == id).toList()..sort((a, b) => b.date.compareTo(a.date));
    final location = ref.watch(homeRepositoryProvider).locationById(asset.locationId);
    final encodedId = Uri.encodeQueryComponent(id);

    String route(String feature) => '/manage/$feature?assetId=$encodedId';

    return ResponsivePage(
      title: asset.name.value(lang),
      actions: [
        PopupMenuButton<String>(
          tooltip: lang == 'ar' ? 'خيارات الأصل' : 'Asset options',
          onSelected: (value) {
            if (value == 'archive') _confirmArchive(context, ref, asset.id, asset.name.value(lang), lang);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'archive', child: Text(lang == 'ar' ? 'أرشفة الأصل' : 'Archive asset')),
          ],
        ),
      ],
      children: [
        _AssetHero(
          name: asset.name.value(lang),
          subtitle: [asset.brand, asset.model].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • '),
          location: location?.name.value(lang),
          isVehicle: asset.vehicle != null,
          lang: lang,
        ),
        const SizedBox(height: 18),
        Text(lang == 'ar' ? 'إدارة هذا الأصل' : 'Manage this asset', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(
          lang == 'ar' ? 'كل ما يخص هذا الأصل في مكان واحد؛ لن تحتاج لاختياره مرة أخرى.' : 'Everything for this asset lives here; you will not need to select it again.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            _ActionCard(icon: Icons.handyman_rounded, label: lang == 'ar' ? 'الصيانة' : 'Maintenance', count: maintenance.length, onTap: () => context.push(route('maintenance'))),
            _ActionCard(icon: Icons.verified_rounded, label: lang == 'ar' ? 'الضمان' : 'Warranty', count: warranties.length, onTap: () => context.push(route('warranties'))),
            _ActionCard(icon: Icons.description_rounded, label: lang == 'ar' ? 'المستندات' : 'Documents', count: documents.length, onTap: () => context.push(route('documents'))),
            _ActionCard(icon: Icons.payments_rounded, label: lang == 'ar' ? 'المصاريف' : 'Expenses', count: expenses.length, onTap: () => context.push(route('expenses'))),
          ],
        ),
        const SizedBox(height: 18),
        _DetailsCard(
          lang: lang,
          location: location?.name.value(lang),
          category: asset.category.name,
          brand: asset.brand,
          model: asset.model,
          serial: asset.serialNumber,
          purchasePrice: asset.purchasePrice,
          notes: asset.notes?.value(lang),
        ),
        const SizedBox(height: 18),
        _HistorySection(
          title: lang == 'ar' ? 'آخر الصيانة' : 'Recent maintenance',
          icon: Icons.handyman_rounded,
          count: maintenance.length,
          emptyText: lang == 'ar' ? 'لا توجد صيانة مسجلة لهذا الأصل.' : 'No maintenance recorded for this asset.',
          items: maintenance.take(3).map((item) => '${item.description.value(lang)} • ${compactDate(item.date, lang)} • ${item.cost.toStringAsFixed(0)} SAR').toList(),
          onOpen: () => context.push(route('maintenance')),
          lang: lang,
        ),
        const SizedBox(height: 12),
        _HistorySection(
          title: lang == 'ar' ? 'الضمان' : 'Warranty',
          icon: Icons.verified_rounded,
          count: warranties.length,
          emptyText: lang == 'ar' ? 'لا يوجد ضمان مرتبط بهذا الأصل.' : 'No warranty linked to this asset.',
          items: warranties.take(3).map((item) => '${item.provider} • ${compactDate(item.end, lang)}').toList(),
          onOpen: () => context.push(route('warranties')),
          lang: lang,
        ),
        const SizedBox(height: 12),
        _HistorySection(
          title: lang == 'ar' ? 'المستندات' : 'Documents',
          icon: Icons.description_rounded,
          count: documents.length,
          emptyText: lang == 'ar' ? 'لا توجد مستندات مرتبطة بهذا الأصل.' : 'No documents linked to this asset.',
          items: documents.take(3).map((item) => item.title.value(lang)).toList(),
          onOpen: () => context.push(route('documents')),
          lang: lang,
        ),
        const SizedBox(height: 12),
        _HistorySection(
          title: lang == 'ar' ? 'المصاريف' : 'Expenses',
          icon: Icons.payments_rounded,
          count: expenses.length,
          emptyText: lang == 'ar' ? 'لا توجد مصاريف مرتبطة بهذا الأصل.' : 'No expenses linked to this asset.',
          items: expenses.take(3).map((item) => '${item.title.value(lang)} • ${item.amount.toStringAsFixed(0)} SAR').toList(),
          onOpen: () => context.push(route('expenses')),
          lang: lang,
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref, String assetId, String name, String lang) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.archive_outlined),
            title: Text(lang == 'ar' ? 'أرشفة الأصل؟' : 'Archive asset?'),
            content: Text(lang == 'ar' ? 'سيتم نقل $name إلى الأرشيف بدل حذفه نهائيًا. يمكنك استعادته لاحقًا.' : '$name will be moved to the archive instead of being permanently deleted. You can restore it later.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(lang == 'ar' ? 'أرشفة' : 'Archive')),
            ],
          ),
        ) ?? false;
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final removed = ref.read(assetRepositoryProvider).softDeleteAsset(assetId);
    ref.invalidate(assetsProvider);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(lang == 'ar' ? 'تم نقل الأصل إلى الأرشيف' : 'Asset moved to archive'),
        action: SnackBarAction(
          label: lang == 'ar' ? 'تراجع' : 'Undo',
          onPressed: () {
            if (removed != null) {
              ref.read(assetRepositoryProvider).restoreAsset(removed);
              ref.invalidate(assetsProvider);
            }
          },
        ),
      ),
    );
  }
}

class _AssetHero extends StatelessWidget {
  const _AssetHero({required this.name, required this.subtitle, required this.location, required this.isVehicle, required this.lang});
  final String name;
  final String subtitle;
  final String? location;
  final bool isVehicle;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: [scheme.primaryContainer, scheme.secondaryContainer.withValues(alpha: .72)]),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .8), borderRadius: BorderRadius.circular(18)),
            child: Icon(isVehicle ? Icons.directions_car_rounded : Icons.devices_other_rounded, size: 30, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.room_outlined, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location ?? (lang == 'ar' ? 'موقع غير محدد' : 'No location'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurfaceVariant))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.count, required this.onTap});
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(99)),
              child: Text('$count', style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.lang, required this.location, required this.category, this.brand, this.model, this.serial, this.purchasePrice, this.notes});
  final String lang;
  final String? location;
  final String category;
  final String? brand;
  final String? model;
  final String? serial;
  final double? purchasePrice;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, String>>[
      MapEntry(lang == 'ar' ? 'الموقع' : 'Location', location ?? '-'),
      MapEntry(lang == 'ar' ? 'الفئة' : 'Category', category),
      if (brand != null && brand!.trim().isNotEmpty) MapEntry(lang == 'ar' ? 'العلامة' : 'Brand', brand!),
      if (model != null && model!.trim().isNotEmpty) MapEntry(lang == 'ar' ? 'الموديل' : 'Model', model!),
      if (serial != null && serial!.trim().isNotEmpty) MapEntry(lang == 'ar' ? 'الرقم التسلسلي' : 'Serial number', serial!),
      if (purchasePrice != null) MapEntry(lang == 'ar' ? 'سعر الشراء' : 'Purchase price', '${purchasePrice!.toStringAsFixed(0)} SAR'),
      if (notes != null && notes!.trim().isNotEmpty) MapEntry(lang == 'ar' ? 'ملاحظات' : 'Notes', notes!),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lang == 'ar' ? 'معلومات الأصل' : 'Asset information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 108, child: Text(entry.key, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
              const SizedBox(width: 10),
              Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
      ]),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.title, required this.icon, required this.count, required this.emptyText, required this.items, required this.onOpen, required this.lang});
  final String title;
  final IconData icon;
  final int count;
  final String emptyText;
  final List<String> items;
  final VoidCallback onOpen;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: .6), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: scheme.primary)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
          Text('$count', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(emptyText, style: TextStyle(color: scheme.onSurfaceVariant))
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: 7), child: Container(width: 5, height: 5, decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle))),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ]),
            ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(onPressed: onOpen, icon: const Icon(Icons.arrow_forward_rounded), label: Text(lang == 'ar' ? 'فتح وإدارة' : 'Open & manage')),
        ),
      ]),
    );
  }
}
