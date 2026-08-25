import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final activity = ref.watch(activityProvider);
    return ResponsivePage(
      title: l10n.activity,
      children: [
        for (final event in activity)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timeline_rounded),
                title: Text(event.description.value(lang)),
                subtitle: Text('${event.actor} • ${event.type.value(lang)} • ${compactDate(event.timestamp, lang)}'),
              ),
            ),
          ),
      ],
    );
  }
}
