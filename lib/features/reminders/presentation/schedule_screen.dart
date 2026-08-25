import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final reminders = ref.watch(remindersProvider);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final overdue = reminders.where((r) => !r.isDone && r.dueDate.isBefore(todayStart)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final today = reminders.where((r) => !r.isDone && !r.dueDate.isBefore(todayStart) && r.dueDate.isBefore(tomorrowStart)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final upcoming = reminders.where((r) => !r.isDone && !r.dueDate.isBefore(tomorrowStart)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final completed = reminders.where((r) => r.isDone).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return ResponsivePage(
      title: l10n.schedule,
      children: [
        Text(
          lang == 'ar'
              ? 'شاهد ما تأخر، وما يحتاج انتباهك اليوم، وما هو قادم بدون أن تضيع بين القوائم.'
              : 'See what is overdue, what needs attention today and what is coming next without digging through lists.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 14),
        _SummaryStrip(
          overdue: overdue.length,
          today: today.length,
          upcoming: upcoming.length,
          lang: lang,
        ),
        const SizedBox(height: 16),
        if (reminders.isEmpty)
          EmptyState(
            icon: Icons.event_available_rounded,
            title: lang == 'ar' ? 'لا توجد تذكيرات بعد' : 'No reminders yet',
            message: lang == 'ar'
                ? 'أضف أول تذكير للصيانة أو الضمان أو موعد مهم للمنزل.'
                : 'Add your first reminder for maintenance, warranty or an important home date.',
          )
        else ...[
          if (overdue.isNotEmpty) ...[
            SectionTitle(lang == 'ar' ? 'متأخر' : 'Overdue'),
            ...overdue.map((r) => _ReminderCard(reminder: r, lang: lang, tone: _ReminderTone.danger)),
          ],
          if (today.isNotEmpty) ...[
            SectionTitle(lang == 'ar' ? 'اليوم' : 'Today'),
            ...today.map((r) => _ReminderCard(reminder: r, lang: lang, tone: _ReminderTone.today)),
          ],
          if (upcoming.isNotEmpty) ...[
            SectionTitle(lang == 'ar' ? 'القادم' : 'Upcoming'),
            ...upcoming.map((r) => _ReminderCard(reminder: r, lang: lang, tone: _ReminderTone.normal)),
          ],
          if (completed.isNotEmpty) ...[
            SectionTitle(lang == 'ar' ? 'مكتمل' : 'Completed'),
            ...completed.map((r) => _ReminderCard(reminder: r, lang: lang, tone: _ReminderTone.done)),
          ],
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

enum _ReminderTone { danger, today, normal, done }

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.lang, required this.tone});

  final Reminder reminder;
  final String lang;
  final _ReminderTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      _ReminderTone.danger => scheme.error,
      _ReminderTone.today => const Color(0xFFC47A32),
      _ReminderTone.normal => scheme.primary,
      _ReminderTone.done => const Color(0xFF4C8068),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(_icon(reminder.type), color: color),
          ),
          title: Text(
            reminder.title.value(lang),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('${_typeLabel(reminder.type, lang)} • ${relativeDays(reminder.dueDate, lang)}'),
          ),
          trailing: reminder.usageKm == null
              ? Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.speed_rounded, size: 18),
                    Text('${reminder.usageKm} km', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
        ),
      ),
    );
  }

  static IconData _icon(ReminderType type) => switch (type) {
        ReminderType.oneTime => Icons.event_rounded,
        ReminderType.recurring => Icons.repeat_rounded,
        ReminderType.expiry => Icons.verified_rounded,
        ReminderType.usageBased => Icons.speed_rounded,
      };

  static String _typeLabel(ReminderType type, String lang) => switch (type) {
        ReminderType.oneTime => lang == 'ar' ? 'مرة واحدة' : 'One-time',
        ReminderType.recurring => lang == 'ar' ? 'متكرر' : 'Recurring',
        ReminderType.expiry => lang == 'ar' ? 'انتهاء' : 'Expiry',
        ReminderType.usageBased => lang == 'ar' ? 'حسب الاستخدام' : 'Usage-based',
      };
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.overdue, required this.today, required this.upcoming, required this.lang});

  final int overdue;
  final int today;
  final int upcoming;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(child: _SummaryValue(value: overdue, label: lang == 'ar' ? 'متأخر' : 'Overdue')),
          const SizedBox(height: 42, child: VerticalDivider()),
          Expanded(child: _SummaryValue(value: today, label: lang == 'ar' ? 'اليوم' : 'Today')),
          const SizedBox(height: 42, child: VerticalDivider()),
          Expanded(child: _SummaryValue(value: upcoming, label: lang == 'ar' ? 'قادم' : 'Upcoming')),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
