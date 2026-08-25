import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/extended_repository_providers.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final assets = ref.watch(assetsProvider);
    final reminders = ref.watch(remindersProvider);
    final activity = ref.watch(activityProvider);
    final warranties = ref.watch(warrantiesProvider);
    final services = ref.watch(servicesProvider);
    final homes = ref.watch(homeRepositoryProvider).watchHomes();
    final now = DateTime.now();
    final overdue = reminders.where((r) => !r.isDone && r.dueDate.isBefore(now)).toList();
    final attention = reminders.where((r) => !r.isDone).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final homeName = homes.isEmpty ? (lang == 'ar' ? 'منزلك' : 'your home') : homes.first.name.value(lang);

    return ResponsivePage(
      title: l10n.appName,
      actions: [
        IconButton(
          tooltip: lang == 'ar' ? 'بحث' : 'Search',
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push('/search'),
        ),
      ],
      children: [
        _WelcomeHero(homeName: homeName, lang: lang, onQuickAdd: () => _showQuickAdd(context, lang)),
        if (attention.isNotEmpty) ...[
          SectionTitle(l10n.attention),
          SizedBox(
            height: 102,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attention.length > 3 ? 3 : attention.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final reminder = attention[index];
                final late = reminder.dueDate.isBefore(now);
                final color = late ? Theme.of(context).colorScheme.error : const Color(0xFFC47A32);
                return SizedBox(
                  width: 300,
                  child: AppCard(
                    onTap: () => context.go('/schedule'),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
                          child: Icon(late ? Icons.priority_high_rounded : Icons.notifications_active_rounded, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(reminder.title.value(lang), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(relativeDays(reminder.dueDate, lang), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        SectionTitle(l10n.yourHome),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: MediaQuery.sizeOf(context).width < 380 ? 1.25 : 1.55,
          children: [
            _MetricCard(label: l10n.assets, value: '${assets.length}', icon: Icons.devices_other_rounded, tone: _Tone.info),
            _MetricCard(label: l10n.vehicles, value: '${assets.where((a) => a.vehicle != null).length}', icon: Icons.directions_car_rounded, tone: _Tone.calm),
            _MetricCard(label: l10n.activeWarranties, value: '${warranties.where((w) => w.status != WarrantyStatus.expired).length}', icon: Icons.verified_rounded, tone: _Tone.good),
            _MetricCard(label: l10n.overdueTasks, value: '${overdue.length}', icon: Icons.assignment_late_rounded, tone: overdue.isEmpty ? _Tone.good : _Tone.danger),
          ],
        ),
        SectionTitle(l10n.today),
        if (services.isEmpty && reminders.isEmpty)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
              title: Text(lang == 'ar' ? 'لا شيء يحتاج انتباهك اليوم' : 'Nothing needs your attention today', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(lang == 'ar' ? 'استمتع بيوم هادئ، وسنظهر المهام القادمة هنا.' : 'Enjoy a quiet day. Upcoming tasks will appear here.'),
            ),
          )
        else if (services.isNotEmpty)
          AppCard(
            onTap: () => context.push('/manage/services'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .7), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.cleaning_services_rounded, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(services.first.name.value(lang), style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${l10n.services} • ${services.first.frequency.value(lang)}'),
              trailing: StatusChip(relativeDays(services.first.nextVisit, lang), Theme.of(context).colorScheme.primary),
            ),
          ),
        SectionTitle(l10n.latestActivity),
        if (activity.isEmpty)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_toggle_off_rounded),
              title: Text(lang == 'ar' ? 'لا يوجد نشاط بعد' : 'No activity yet'),
              subtitle: Text(lang == 'ar' ? 'عند إضافة أو تعديل شيء سيظهر سجله هنا.' : 'Changes you make will appear here.'),
            ),
          )
        else
          ...activity.take(4).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.history_rounded, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.description.value(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(compactDate(item.timestamp, lang), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showQuickAdd(BuildContext context, String lang) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang == 'ar' ? 'إضافة سريعة' : 'Quick add', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(lang == 'ar' ? 'اختر ما تريد تسجيله الآن.' : 'Choose what you want to add now.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _QuickAction(icon: Icons.devices_other_rounded, label: lang == 'ar' ? 'أصل جديد' : 'New asset', onTap: () { Navigator.pop(ctx); context.push('/asset/new'); }),
              _QuickAction(icon: Icons.handyman_rounded, label: lang == 'ar' ? 'سجل صيانة' : 'Maintenance', onTap: () { Navigator.pop(ctx); context.push('/manage/maintenance'); }),
              _QuickAction(icon: Icons.payments_rounded, label: lang == 'ar' ? 'مصروف' : 'Expense', onTap: () { Navigator.pop(ctx); context.push('/manage/expenses'); }),
              _QuickAction(icon: Icons.description_rounded, label: lang == 'ar' ? 'مستند' : 'Document', onTap: () { Navigator.pop(ctx); context.push('/manage/documents'); }),
              _QuickAction(icon: Icons.notifications_active_rounded, label: lang == 'ar' ? 'تذكير' : 'Reminder', onTap: () { Navigator.pop(ctx); context.push('/manage/reminders'); }),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.homeName, required this.lang, required this.onQuickAdd});
  final String homeName;
  final String lang;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [scheme.primaryContainer, scheme.secondaryContainer.withValues(alpha: .78)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .72), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.home_rounded, color: scheme.primary),
              ),
              const Spacer(),
              FilledButton.tonalIcon(onPressed: onQuickAdd, icon: const Icon(Icons.add_rounded), label: Text(lang == 'ar' ? 'إضافة' : 'Add')),
            ],
          ),
          const SizedBox(height: 22),
          Text(lang == 'ar' ? 'أهلًا بك في $homeName' : 'Welcome to $homeName', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            lang == 'ar' ? 'كل ما يحتاجه منزلك اليوم يظهر هنا بدون ازدحام.' : 'Everything your home needs today, without the clutter.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: .78), height: 1.45),
          ),
        ],
      ),
    );
  }
}

enum _Tone { info, calm, good, danger }

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.tone});
  final String label;
  final String value;
  final IconData icon;
  final _Tone tone;

  Color _color(BuildContext context) => switch (tone) {
        _Tone.info => const Color(0xFF4A84C6),
        _Tone.calm => Theme.of(context).colorScheme.primary,
        _Tone.good => const Color(0xFF41866A),
        _Tone.danger => Theme.of(context).colorScheme.error,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .6), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}
