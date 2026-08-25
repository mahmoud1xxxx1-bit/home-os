import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final assets = ref.watch(assetsProvider);
    final reminders = ref.watch(remindersProvider);
    final activity = ref.watch(activityProvider);
    final store = ref.watch(localStoreProvider);
    final warranties = store.warranties;

    return ResponsivePage(
      title: l10n.appName,
      actions: [
        IconButton(
          tooltip: l10n.quickAdd,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
          onPressed: () => _showQuickAdd(context, ref, lang),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('${l10n.welcome}، ${store.watchHomes().first.name.value(lang)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        ),
        
        if (reminders.isNotEmpty) ...[
          SectionTitle(l10n.attention),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reminders.length > 3 ? 3 : reminders.length,
              itemBuilder: (ctx, i) {
                final r = reminders[i];
                return Container(
                  width: 320,
                  margin: EdgeInsets.only(right: lang == 'en' ? 16 : 0, left: lang == 'ar' ? 16 : 0),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.warning_amber_rounded, color: Colors.orange)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(r.title.value(lang), style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(relativeDays(r.dueDate, lang), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ])),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ],

        SectionTitle(l10n.yourHome),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _MetricCard(label: l10n.assets, value: '${assets.length}', icon: Icons.devices_other_rounded, color: Colors.blue),
            _MetricCard(label: l10n.vehicles, value: '${assets.where((a) => a.vehicle != null).length}', icon: Icons.directions_car_rounded, color: Colors.teal),
            _MetricCard(label: l10n.activeWarranties, value: '${warranties.length}', icon: Icons.verified_rounded, color: Colors.green),
            _MetricCard(label: l10n.overdueTasks, value: '1', icon: Icons.assignment_late_rounded, color: Colors.red),
          ],
        ),
        
        SectionTitle(l10n.today),
        if (store.services.isNotEmpty)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.cleaning_services_rounded, color: Theme.of(context).colorScheme.primary)),
              title: Text(store.services.first.name.value(lang), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.services),
              trailing: StatusChip(relativeDays(store.services.first.nextVisit, lang), Theme.of(context).colorScheme.primary),
            ),
          ),

        SectionTitle(l10n.latestActivity),
        ...activity.take(4).map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.history_rounded, size: 20)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.description.value(lang), style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(compactDate(item.timestamp, lang), style: Theme.of(context).textTheme.bodySmall),
                ])),
              ],
            ),
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showQuickAdd(BuildContext context, WidgetRef ref, String lang) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang == 'ar' ? 'إضافة سريعة' : 'Quick Add', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(avatar: const Icon(Icons.devices_other_rounded), label: Text(lang == 'ar' ? 'أصل جديد' : 'New Asset'), onPressed: () { Navigator.pop(ctx); context.push('/asset/new'); }),
                ActionChip(avatar: const Icon(Icons.handyman_rounded), label: Text(lang == 'ar' ? 'سجل صيانة' : 'Maintenance Record'), onPressed: () { Navigator.pop(ctx); context.push('/manage/maintenance'); }),
                ActionChip(avatar: const Icon(Icons.receipt_long_rounded), label: Text(lang == 'ar' ? 'مصروف' : 'Expense'), onPressed: () { Navigator.pop(ctx); context.push('/manage/expenses'); }),
                ActionChip(avatar: const Icon(Icons.description_rounded), label: Text(lang == 'ar' ? 'مستند' : 'Document'), onPressed: () { Navigator.pop(ctx); context.push('/manage/documents'); }),
              ]
            )
          ],
        )
      )
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
