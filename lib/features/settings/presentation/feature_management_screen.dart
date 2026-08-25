import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class FeatureManagementScreen extends ConsumerWidget {
  const FeatureManagementScreen({super.key, required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = _title(feature, lang);
    return ResponsivePage(
      title: title,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'إضافة' : 'Add',
          onPressed: () => _add(context, ref),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      children: [
        _body(context, ref, lang),
      ],
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, String lang) {
    final store = ref.watch(localStoreProvider);
    return switch (feature) {
      'homes' => _list(
          context,
          ref,
          store.watchHomes().map((item) => _Row(item.id, item.name.value(lang), item.type.value(lang), Icons.home_work_rounded)).toList(),
        ),
      'locations' => _list(
          context,
          ref,
          store.watchLocations().map((item) {
            final count = store.watchAssets().where((asset) => asset.locationId == item.id).length;
            return _Row(item.id, item.name.value(lang), '$count ${lang == 'ar' ? 'أصول' : 'assets'}', Icons.room_preferences_rounded);
          }).toList(),
        ),
      'assets' => Column(children: [
          TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), labelText: lang == 'ar' ? 'بحث وتصفية' : 'Search and filter')),
          const SizedBox(height: 10),
          _list(
            context,
            ref,
            store.watchAssets().map((item) => _Row(item.id, item.name.value(lang), item.vehicle == null ? item.category.name : 'Vehicle • ${item.vehicle!.odometerKm} km', Icons.devices_other_rounded)).toList(),
            assetRows: true,
          ),
          SectionTitle(lang == 'ar' ? 'الأرشيف' : 'Archive'),
          _list(context, ref, store.archivedAssets().map((item) => _Row(item.id, item.name.value(lang), lang == 'ar' ? 'محذوف محليًا' : 'Soft deleted', Icons.archive_rounded)).toList()),
        ]),
      'maintenance' => _list(
          context,
          ref,
          store.watchMaintenance().map((item) => _Row(item.id, item.description.value(lang), '${item.cost.toStringAsFixed(0)} SAR', Icons.handyman_rounded)).toList(),
        ),
      'reminders' => _reminderBoard(store, lang),
      'warranties' => _list(
          context,
          ref,
          store.warranties.map((item) => _Row(item.id, item.provider, item.status.name, Icons.verified_rounded)).toList(),
        ),
      'services' => _list(
          context,
          ref,
          store.services.map((item) => _Row(item.id, item.name.value(lang), '${item.frequency.value(lang)} • ${item.cost.toStringAsFixed(0)} SAR', Icons.cleaning_services_rounded)).toList(),
          serviceRows: true,
        ),
      'providers' => _list(
          context,
          ref,
          store.watchProviders().map((item) => _Row(item.id, item.name, '${item.type.value(lang)} • ${item.totalPaid.toStringAsFixed(0)} SAR', Icons.contacts_rounded)).toList(),
        ),
      'documents' => _list(
          context,
          ref,
          store.watchDocuments().map((item) => _Row(item.id, item.title.value(lang), item.category.value(lang), Icons.description_rounded)).toList(),
        ),
      'expenses' => Column(children: [
          AppCard(
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              Chip(label: Text('${lang == 'ar' ? 'الشهر' : 'Month'}: ${store.watchExpenses().fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(0)} SAR')),
              Chip(label: Text('${lang == 'ar' ? 'السنة' : 'Year'}: ${store.watchExpenses().fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(0)} SAR')),
              Chip(label: Text(lang == 'ar' ? 'حسب الفئة' : 'By category')),
              Chip(label: Text(lang == 'ar' ? 'حسب الأصل' : 'By asset')),
            ]),
          ),
          const SizedBox(height: 10),
          _list(context, ref, store.watchExpenses().map((item) => _Row(item.id, item.title.value(lang), '${item.amount.toStringAsFixed(0)} SAR', Icons.payments_rounded)).toList()),
        ]),
      'family' => _familyList(context, ref, lang),
      'reports' => _reports(store, lang),
      'help' => _help(lang),
      _ => AppCard(child: Text(lang == 'ar' ? 'القسم غير موجود' : 'Unknown section')),
    };
  }

  Widget _list(BuildContext context, WidgetRef ref, List<_Row> rows, {bool assetRows = false, bool serviceRows = false}) {
    final lang = Localizations.localeOf(context).languageCode;
    if (rows.isEmpty) {
      return AppCard(child: ListTile(leading: const Icon(Icons.inbox_rounded), title: Text(lang == 'ar' ? 'لا توجد عناصر بعد' : 'Nothing here yet')));
    }
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: assetRows ? () => context.push('/asset/${row.id}') : null,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(row.icon),
                title: Text(row.title),
                subtitle: Text(row.subtitle),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    if (serviceRows)
                      IconButton(
                        tooltip: lang == 'ar' ? 'إكمال زيارة' : 'Complete visit',
                        onPressed: () {
                          ref.read(localStoreProvider).markServiceVisitCompleted(row.id);
                          ref.invalidate(activityProvider);
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded),
                      ),
                    IconButton(onPressed: () => _edit(context, ref, row), icon: const Icon(Icons.edit_rounded)),
                    IconButton(onPressed: () => _delete(context, ref, row.id), icon: const Icon(Icons.delete_outline_rounded)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _reminderBoard(LocalHomeStore store, String lang) {
    final now = DateTime.now();
    final groups = {
      lang == 'ar' ? 'اليوم' : 'Today': store.watchReminders().where((r) => r.dueDate.difference(now).inDays == 0),
      lang == 'ar' ? 'القادمة' : 'Upcoming': store.watchReminders().where((r) => r.dueDate.isAfter(now)),
      lang == 'ar' ? 'المتأخرة' : 'Overdue': store.watchReminders().where((r) => r.dueDate.isBefore(now)),
      lang == 'ar' ? 'المكتملة' : 'Completed': store.watchReminders().where((r) => r.isDone),
    };
    return Column(
      children: [
        for (final group in groups.entries) ...[
          SectionTitle(group.key),
          for (final reminder in group.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: Text(reminder.title.value(lang)),
                  subtitle: Text(reminder.type.name),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _familyList(BuildContext context, WidgetRef ref, String lang) {
    final store = ref.watch(localStoreProvider);
    final canEdit = store.family.first.role != FamilyRole.viewer;
    return Column(
      children: [
        for (final member in store.family)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ListTile(
                leading: const Icon(Icons.person_rounded),
                title: Text(member.name),
                subtitle: Text('${member.role.name} • ${member.status.value(lang)}'),
                trailing: canEdit
                    ? IconButton(
                        icon: const Icon(Icons.admin_panel_settings_rounded),
                        onPressed: () => ref.read(localStoreProvider).upsertFamilyMember(
                              FamilyMember(id: member.id, name: member.name, role: FamilyRole.viewer, status: member.status),
                            ),
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _reports(LocalHomeStore store, String lang) {
    final expenses = store.watchExpenses();
    final maintenance = store.watchMaintenance();
    return AppCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          Chip(label: Text('${lang == 'ar' ? 'إنفاق الصيانة' : 'Maintenance spending'}: ${maintenance.fold<double>(0, (sum, e) => sum + e.cost).toStringAsFixed(0)} SAR')),
          Chip(label: Text('${lang == 'ar' ? 'المصاريف' : 'Expenses'}: ${expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(0)} SAR')),
          Chip(label: Text('${lang == 'ar' ? 'أصول تحتاج انتباه' : 'Assets requiring attention'}: ${store.watchReminders().length}')),
          Chip(label: Text('${lang == 'ar' ? 'ضمانات قريبة' : 'Warranties expiring'}: ${store.warranties.where((w) => w.status == WarrantyStatus.expiringSoon).length}')),
          Chip(label: Text(lang == 'ar' ? 'تصدير PDF مؤجل' : 'PDF export placeholder')),
        ],
      ),
    );
  }

  Widget _help(String lang) {
    final topics = [
      'Adding an asset',
      'Reminders',
      'Warranties',
      'Family',
      'Documents',
      'Services',
      'Privacy',
    ];
    return Column(
      children: [
        for (final topic in topics)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(child: ListTile(leading: const Icon(Icons.help_outline_rounded), title: Text(topic), subtitle: Text(lang == 'ar' ? 'شرح مبسط داخل التطبيق' : 'In-app guidance'))),
          ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final row = await _rowDialog(context);
    if (row == null) return;
    final store = ref.read(localStoreProvider);
    final now = DateTime.now();
    final id = '$feature-${now.microsecondsSinceEpoch}';
    switch (feature) {
      case 'homes':
        store.upsertHome(HomeProfile(id: id, name: LocalizedText(ar: row, en: row), type: const LocalizedText(ar: 'منزل', en: 'Home'), createdAt: now));
      case 'locations':
        store.upsertLocation(LocationArea(id: id, name: LocalizedText(ar: row, en: row), icon: 'room'));
      case 'providers':
        store.upsertProvider(ProviderContact(id: id, name: row, type: const LocalizedText(ar: 'عام', en: 'General'), phone: '-', whatsApp: '-', visitCount: 0, totalPaid: 0, lastVisit: now, linkedAssetIds: const []));
      case 'documents':
        store.upsertDocument(HomeDocument(id: id, title: LocalizedText(ar: row, en: row), category: const LocalizedText(ar: 'أخرى', en: 'Other'), relatedAssetId: null, createdAt: now, placeholder: 'metadata only'));
      case 'expenses':
        store.upsertExpense(Expense(id: id, title: LocalizedText(ar: row, en: row), category: const LocalizedText(ar: 'خدمات', en: 'Services'), assetId: null, amount: 100, date: now));
      case 'family':
        store.upsertFamilyMember(FamilyMember(id: id, name: row, role: FamilyRole.member, status: const LocalizedText(ar: 'دعوة محلية', en: 'Local invite')));
      case 'assets':
        if (context.mounted) context.push('/asset/new');
      default:
        store.addActivity(ActivityEvent(id: id, actor: 'Local User', type: const LocalizedText(ar: 'إنشاء', en: 'Create'), entity: LocalizedText(ar: row, en: row), timestamp: now, description: LocalizedText(ar: 'تم إنشاء $row', en: '$row created')));
    }
    ref.invalidate(activityProvider);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, _Row row) async {
    final value = await _rowDialog(context, initial: row.title);
    if (value == null) return;
    final store = ref.read(localStoreProvider);
    if (feature == 'locations') {
      store.upsertLocation(LocationArea(id: row.id, name: LocalizedText(ar: value, en: value), icon: 'room'));
    } else if (feature == 'homes') {
      store.upsertHome(HomeProfile(id: row.id, name: LocalizedText(ar: value, en: value), type: const LocalizedText(ar: 'منزل', en: 'Home'), createdAt: DateTime.now()));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Delete this item?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    final store = ref.read(localStoreProvider);
    switch (feature) {
      case 'homes':
        store.deleteHome(id);
      case 'locations':
        store.deleteLocation(id);
      case 'assets':
        final removed = store.softDeleteAsset(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Deleted'), action: SnackBarAction(label: 'Undo', onPressed: () => removed == null ? null : store.restoreAsset(removed))),
          );
        }
      case 'providers':
        store.deleteProvider(id);
      case 'documents':
        store.deleteDocument(id);
      case 'expenses':
        store.deleteExpense(id);
    }
  }

  Future<String?> _rowDialog(BuildContext context, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }

  String _title(String feature, String lang) {
    final ar = {
      'homes': 'إدارة المنازل',
      'locations': 'إدارة الأماكن',
      'assets': 'إدارة الأجهزة والأصول',
      'maintenance': 'إدارة الصيانة',
      'reminders': 'إدارة التذكيرات',
      'warranties': 'إدارة الضمانات',
      'services': 'الخدمات المتكررة',
      'providers': 'مقدمو الخدمات',
      'documents': 'خزنة المستندات',
      'expenses': 'المصاريف',
      'family': 'العائلة والأدوار',
      'reports': 'التقارير',
      'help': 'مركز المساعدة',
    };
    return lang == 'ar' ? ar[feature] ?? feature : feature;
  }
}

class _Row {
  const _Row(this.id, this.title, this.subtitle, this.icon);

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
