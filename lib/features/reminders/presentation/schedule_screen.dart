import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final reminders = ref.watch(remindersProvider);
    return ResponsivePage(
      title: l10n.schedule,
      children: [
        SectionTitle(l10n.reminders),
        for (final reminder in reminders)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_icon(reminder.type)),
                title: Text(reminder.title.value(lang)),
                subtitle: Text('${_typeLabel(reminder.type, lang)} • ${relativeDays(reminder.dueDate, lang)}'),
                trailing: reminder.usageKm == null ? null : Text('${reminder.usageKm} km'),
              ),
            ),
          ),
      ],
    );
  }

  IconData _icon(ReminderType type) => switch (type) {
        ReminderType.oneTime => Icons.event_rounded,
        ReminderType.recurring => Icons.repeat_rounded,
        ReminderType.expiry => Icons.verified_rounded,
        ReminderType.usageBased => Icons.speed_rounded,
      };

  String _typeLabel(ReminderType type, String lang) => switch (type) {
        ReminderType.oneTime => lang == 'ar' ? 'مرة واحدة' : 'One-time',
        ReminderType.recurring => lang == 'ar' ? 'متكرر' : 'Recurring',
        ReminderType.expiry => lang == 'ar' ? 'انتهاء' : 'Expiry',
        ReminderType.usageBased => lang == 'ar' ? 'حسب الاستخدام' : 'Usage-based',
      };
}
