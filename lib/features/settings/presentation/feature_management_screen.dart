import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/extended_repository_providers.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class FeatureManagementScreen extends ConsumerWidget {
  const FeatureManagementScreen({super.key, required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final canAdd = feature == 'homes' || feature == 'locations' || feature == 'assets' || feature == 'reminders';
    return ResponsivePage(
      title: _title(feature, lang),
      actions: [
        if (canAdd)
          IconButton(
            tooltip: lang == 'ar' ? 'إضافة' : 'Add',
            onPressed: () => _add(context, ref, lang),
            icon: const Icon(Icons.add_rounded),
          ),
      ],
      children: [
        _intro(context, lang),
        const SizedBox(height: 14),
        _body(context, ref, lang),
      ],
    );
  }

  Widget _intro(BuildContext context, String lang) {
    final text = switch (feature) {
      'homes' => lang == 'ar' ? 'أدر المنازل المرتبطة بحسابك واختر أسماء واضحة لها.' : 'Manage homes linked to your account and keep their names clear.',
      'locations' => lang == 'ar' ? 'قسّم المنزل إلى غرف أو مواقع لتعرف مكان كل أصل.' : 'Create rooms or locations so every asset has a clear place.',
      'assets' => lang == 'ar' ? 'جميع الأجهزة والممتلكات التي تتابعها داخل Home OS.' : 'All devices and belongings tracked in Home OS.',
      'reminders' => lang == 'ar' ? 'تابع المواعيد القادمة والمتأخرة من مكان واحد.' : 'Keep upcoming and overdue reminders in one place.',
      'reports' => lang == 'ar' ? 'ملخص بسيط يساعدك على فهم تكلفة منزلك وما يحتاج انتباهك.' : 'A simple summary of home costs and items that need attention.',
      'help' => lang == 'ar' ? 'شرح سريع لأهم أقسام Home OS وكيف تستخدمها.' : 'Quick guidance for the main Home OS sections.',
      _ => lang == 'ar' ? 'إدارة هذا القسم.' : 'Manage this section.',
    };
    return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5));
  }

  Widget _body(BuildContext context, WidgetRef ref, String lang) {
    return switch (feature) {
      'homes' => _homes(context, ref, lang),
      'locations' => _locations(context, ref, lang),
      'assets' => _assets(context, ref, lang),
      'reminders' => _reminders(context, ref, lang),
      'reports' => _reports(context, ref, lang),
      'help' => _help(context, lang),
      _ => AppCard(
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(lang == 'ar' ? 'هذا القسم له شاشة مخصصة' : 'This section has a dedicated screen'),
          ),
        ),
    };
  }

  Widget _homes(BuildContext context, WidgetRef ref, String lang) {
    final homes = ref.watch(homeRepositoryProvider).watchHomes();
    if (homes.isEmpty) {
      return EmptyState(
        icon: Icons.home_work_rounded,
        title: lang == 'ar' ? 'لا توجد منازل' : 'No homes yet',
        message: lang == 'ar' ? 'أضف المنزل الذي تريد تنظيمه.' : 'Add the home you want to organize.',
        actionLabel: lang == 'ar' ? 'إضافة منزل' : 'Add home',
        onAction: () => _addNamedItem(context, ref, lang, 'homes'),
      );
    }
    return Column(
      children: [
        for (final home in homes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.home_work_rounded),
                title: Text(home.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(home.type.value(lang)),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') _editHome(context, ref, home, lang);
                    if (value == 'delete') _deleteHome(context, ref, home, lang);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(lang == 'ar' ? 'تعديل' : 'Edit')),
                    PopupMenuItem(value: 'delete', child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _locations(BuildContext context, WidgetRef ref, String lang) {
    final homeRepo = ref.watch(homeRepositoryProvider);
    final locations = homeRepo.watchLocations();
    final assets = ref.watch(assetsProvider);
    if (locations.isEmpty) {
      return EmptyState(
        icon: Icons.room_preferences_rounded,
        title: lang == 'ar' ? 'لا توجد مواقع' : 'No locations yet',
        message: lang == 'ar' ? 'أضف غرفة أو موقعًا لتصنيف الأصول.' : 'Add a room or location to organize assets.',
        actionLabel: lang == 'ar' ? 'إضافة موقع' : 'Add location',
        onAction: () => _addNamedItem(context, ref, lang, 'locations'),
      );
    }
    return Column(
      children: [
        for (final location in locations)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.room_preferences_rounded),
                title: Text(location.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${assets.where((a) => a.locationId == location.id).length} ${lang == 'ar' ? 'أصول' : 'assets'}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') _editLocation(context, ref, location, lang);
                    if (value == 'delete') _deleteLocation(context, ref, location, lang);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(lang == 'ar' ? 'تعديل' : 'Edit')),
                    PopupMenuItem(value: 'delete', child: Text(lang == 'ar' ? 'حذف' : 'Delete')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _assets(BuildContext context, WidgetRef ref, String lang) {
    final repo = ref.watch(assetRepositoryProvider);
    final active = ref.watch(assetsProvider);
    final archived = repo.archivedAssets();
    if (active.isEmpty && archived.isEmpty) {
      return EmptyState(
        icon: Icons.devices_other_rounded,
        title: lang == 'ar' ? 'لا توجد أصول' : 'No assets yet',
        message: lang == 'ar' ? 'ابدأ بإضافة جهاز أو سيارة أو أي شيء تريد متابعته.' : 'Add a device, vehicle or anything you want to track.',
        actionLabel: lang == 'ar' ? 'إضافة أصل' : 'Add asset',
        onAction: () => context.push('/asset/new'),
      );
    }
    return Column(
      children: [
        for (final asset in active)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => context.push('/asset/${asset.id}'),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(asset.vehicle == null ? Icons.devices_other_rounded : Icons.directions_car_rounded),
                title: Text(asset.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(asset.vehicle == null ? asset.category.name : '${asset.vehicle!.odometerKm} km'),
                trailing: IconButton(
                  tooltip: lang == 'ar' ? 'أرشفة' : 'Archive',
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () => _archiveAsset(context, ref, asset, lang),
                ),
              ),
            ),
          ),
        if (archived.isNotEmpty) ...[
          SectionTitle(lang == 'ar' ? 'الأرشيف' : 'Archive'),
          for (final asset in archived)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: ListTile(
                  leading: const Icon(Icons.archive_rounded),
                  title: Text(asset.name.value(lang)),
                  trailing: TextButton(
                    onPressed: () {
                      ref.read(assetRepositoryProvider).restoreAsset(asset);
                      ref.invalidate(assetsProvider);
                    },
                    child: Text(lang == 'ar' ? 'استعادة' : 'Restore'),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _reminders(BuildContext context, WidgetRef ref, String lang) {
    final reminders = ref.watch(remindersProvider);
    final now = DateTime.now();
    final upcoming = reminders.where((r) => !r.isDone && !r.dueDate.isBefore(now)).toList();
    final overdue = reminders.where((r) => !r.isDone && r.dueDate.isBefore(now)).toList();
    final completed = reminders.where((r) => r.isDone).toList();
    if (reminders.isEmpty) {
      return EmptyState(
        icon: Icons.notifications_active_rounded,
        title: lang == 'ar' ? 'لا توجد تذكيرات' : 'No reminders yet',
        message: lang == 'ar' ? 'أضف موعدًا مهمًا وسنضعه أمامك بوضوح.' : 'Add an important date and keep it visible.',
        actionLabel: lang == 'ar' ? 'إضافة تذكير' : 'Add reminder',
        onAction: () => _addReminder(context, ref, lang),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty) ...[
          SectionTitle(lang == 'ar' ? 'متأخرة' : 'Overdue'),
          ...overdue.map((r) => _reminderCard(context, r, lang, danger: true)),
        ],
        if (upcoming.isNotEmpty) ...[
          SectionTitle(lang == 'ar' ? 'قادمة' : 'Upcoming'),
          ...upcoming.map((r) => _reminderCard(context, r, lang)),
        ],
        if (completed.isNotEmpty) ...[
          SectionTitle(lang == 'ar' ? 'مكتملة' : 'Completed'),
          ...completed.map((r) => _reminderCard(context, r, lang)),
        ],
      ],
    );
  }

  Widget _reminderCard(BuildContext context, Reminder reminder, String lang, {bool danger = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.notifications_active_rounded, color: danger ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
            title: Text(reminder.title.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${reminder.dueDate.year}/${reminder.dueDate.month}/${reminder.dueDate.day}'),
          ),
        ),
      );

  Widget _reports(BuildContext context, WidgetRef ref, String lang) {
    final expenses = ref.watch(expensesProvider);
    final maintenance = ref.watch(maintenanceProvider);
    final warranties = ref.watch(warrantiesProvider);
    final reminders = ref.watch(remindersProvider);
    final expenseTotal = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final maintenanceTotal = maintenance.fold<double>(0, (sum, e) => sum + e.cost);
    final expiring = warranties.where((w) => w.status == WarrantyStatus.expiringSoon).length;
    final attention = reminders.where((r) => !r.isDone).length;

    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _ReportCard(icon: Icons.payments_rounded, label: lang == 'ar' ? 'المصاريف' : 'Expenses', value: '${expenseTotal.toStringAsFixed(0)} SAR'),
        _ReportCard(icon: Icons.handyman_rounded, label: lang == 'ar' ? 'الصيانة' : 'Maintenance', value: '${maintenanceTotal.toStringAsFixed(0)} SAR'),
        _ReportCard(icon: Icons.warning_amber_rounded, label: lang == 'ar' ? 'تحتاج انتباه' : 'Need attention', value: '$attention'),
        _ReportCard(icon: Icons.verified_outlined, label: lang == 'ar' ? 'ضمانات قريبة' : 'Warranties soon', value: '$expiring'),
      ],
    );
  }

  Widget _help(BuildContext context, String lang) {
    final topics = [
      (Icons.devices_other_rounded, lang == 'ar' ? 'إضافة أصل' : 'Adding an asset', lang == 'ar' ? 'أضف الجهاز وحدد موقعه ثم أكمل التفاصيل عند الحاجة.' : 'Add the asset, choose its location, then add optional details when needed.'),
      (Icons.notifications_active_rounded, lang == 'ar' ? 'التذكيرات' : 'Reminders', lang == 'ar' ? 'استخدمها لمواعيد الصيانة والانتهاء والخدمات.' : 'Use reminders for maintenance, expiries and service dates.'),
      (Icons.verified_rounded, lang == 'ar' ? 'الضمانات' : 'Warranties', lang == 'ar' ? 'سجّل الضمان قبل أن تنسى تاريخ انتهائه.' : 'Save warranty details before the expiry date is forgotten.'),
      (Icons.group_rounded, lang == 'ar' ? 'العائلة' : 'Family', lang == 'ar' ? 'حدد دور كل شخص قبل منحه صلاحية الإدارة.' : 'Choose a role before granting someone management access.'),
      (Icons.privacy_tip_outlined, lang == 'ar' ? 'الخصوصية' : 'Privacy', lang == 'ar' ? 'بيانات كل مستخدم معزولة بحسابه في Firebase.' : 'Each user’s data is isolated by their Firebase account.'),
    ];
    return Column(
      children: [
        for (final topic in topics)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(topic.$1, color: Theme.of(context).colorScheme.primary),
                title: Text(topic.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(topic.$3),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, String lang) async {
    if (feature == 'assets') {
      context.push('/asset/new');
    } else if (feature == 'reminders') {
      _addReminder(context, ref, lang);
    } else {
      _addNamedItem(context, ref, lang, feature);
    }
  }

  Future<void> _addNamedItem(BuildContext context, WidgetRef ref, String lang, String kind) async {
    final value = await _nameDialog(context, lang, title: kind == 'homes' ? (lang == 'ar' ? 'إضافة منزل' : 'Add home') : (lang == 'ar' ? 'إضافة موقع' : 'Add location'));
    if (value == null || value.trim().isEmpty) return;
    final now = DateTime.now();
    if (kind == 'homes') {
      ref.read(homeRepositoryProvider).upsertHome(HomeProfile(id: 'home-${now.microsecondsSinceEpoch}', name: LocalizedText(ar: value, en: value), type: const LocalizedText(ar: 'منزل', en: 'Home'), createdAt: now));
    } else {
      ref.read(homeRepositoryProvider).upsertLocation(LocationArea(id: 'location-${now.microsecondsSinceEpoch}', name: LocalizedText(ar: value, en: value), icon: 'room'));
    }
  }

  void _addReminder(BuildContext context, WidgetRef ref, String lang) {
    final controller = TextEditingController();
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
            Text(lang == 'ar' ? 'إضافة تذكير' : 'Add reminder', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: lang == 'ar' ? 'عنوان التذكير' : 'Reminder title')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  final now = DateTime.now();
                  ref.read(reminderRepositoryProvider).addReminder(
                        Reminder(
                          id: 'reminder-${now.microsecondsSinceEpoch}',
                          title: LocalizedText(ar: controller.text.trim(), en: controller.text.trim()),
                          type: ReminderType.oneTime,
                          assetId: null,
                          dueDate: now.add(const Duration(days: 1)),
                          alertOffset: AlertOffset.oneDay,
                        ),
                      );
                  ref.invalidate(remindersProvider);
                  Navigator.pop(ctx);
                },
                child: Text(lang == 'ar' ? 'حفظ' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editHome(BuildContext context, WidgetRef ref, HomeProfile home, String lang) async {
    final value = await _nameDialog(context, lang, title: lang == 'ar' ? 'تعديل المنزل' : 'Edit home', initial: home.name.value(lang));
    if (value == null || value.trim().isEmpty) return;
    ref.read(homeRepositoryProvider).upsertHome(HomeProfile(id: home.id, name: LocalizedText(ar: value, en: value), type: home.type, createdAt: home.createdAt));
  }

  Future<void> _editLocation(BuildContext context, WidgetRef ref, LocationArea location, String lang) async {
    final value = await _nameDialog(context, lang, title: lang == 'ar' ? 'تعديل الموقع' : 'Edit location', initial: location.name.value(lang));
    if (value == null || value.trim().isEmpty) return;
    ref.read(homeRepositoryProvider).upsertLocation(LocationArea(id: location.id, name: LocalizedText(ar: value, en: value), icon: location.icon));
  }

  Future<void> _deleteHome(BuildContext context, WidgetRef ref, HomeProfile home, String lang) async {
    if (!await _confirm(context, lang, lang == 'ar' ? 'حذف المنزل؟' : 'Delete home?', lang == 'ar' ? 'سيتم حذف ${home.name.value(lang)}. تأكد أنه لا يحتوي بيانات تحتاجها.' : '${home.name.value(lang)} will be removed. Make sure you no longer need its data.')) return;
    ref.read(homeRepositoryProvider).deleteHome(home.id);
  }

  Future<void> _deleteLocation(BuildContext context, WidgetRef ref, LocationArea location, String lang) async {
    if (!await _confirm(context, lang, lang == 'ar' ? 'حذف الموقع؟' : 'Delete location?', lang == 'ar' ? 'تأكد من نقل الأصول المرتبطة بهذا الموقع أولًا.' : 'Move any linked assets before deleting this location.')) return;
    ref.read(homeRepositoryProvider).deleteLocation(location.id);
  }

  void _archiveAsset(BuildContext context, WidgetRef ref, HomeAsset asset, String lang) {
    final removed = ref.read(assetRepositoryProvider).softDeleteAsset(asset.id);
    ref.invalidate(assetsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
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

  Future<String?> _nameDialog(BuildContext context, String lang, {required String title, String? initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(lang == 'ar' ? 'حفظ' : 'Save')),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String lang, String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'تأكيد' : 'Confirm')),
          ],
        ),
      ) ??
      false;

  String _title(String feature, String lang) => switch (feature) {
        'homes' => lang == 'ar' ? 'المنازل' : 'Homes',
        'locations' => lang == 'ar' ? 'المواقع والغرف' : 'Locations & rooms',
        'assets' => lang == 'ar' ? 'الأصول' : 'Assets',
        'reminders' => lang == 'ar' ? 'التذكيرات' : 'Reminders',
        'reports' => lang == 'ar' ? 'التقارير' : 'Reports',
        'help' => lang == 'ar' ? 'مركز المساعدة' : 'Help center',
        _ => lang == 'ar' ? 'الإدارة' : 'Manage',
      };
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}
