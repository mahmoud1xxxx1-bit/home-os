import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

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
        Text(
          lang == 'ar'
              ? 'سجل واضح لما تغيّر في Home OS: إضافات، صيانة، مستندات وتعديلات مهمة.'
              : 'A clear history of important changes in Home OS: additions, maintenance, documents and updates.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 14),
        if (activity.isEmpty)
          EmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: lang == 'ar' ? 'لا يوجد نشاط بعد' : 'No activity yet',
            message: lang == 'ar'
                ? 'عندما تضيف أصلًا أو تسجل صيانة أو تغيّر شيئًا مهمًا سيظهر هنا.'
                : 'When you add an asset, record maintenance or make an important change, it will appear here.',
            actionLabel: lang == 'ar' ? 'العودة للرئيسية' : 'Back to home',
            onAction: () => context.go('/'),
          )
        else
          for (var index = 0; index < activity.length; index++)
            _TimelineEntry(
              event: activity[index],
              lang: lang,
              isLast: index == activity.length - 1,
            ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.event, required this.lang, required this.isLast});

  final ActivityEvent event;
  final String lang;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: scheme.primary.withValues(alpha: .2), blurRadius: 0, spreadRadius: 5),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant.withValues(alpha: .8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.description.value(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          compactDate(event.timestamp, lang),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaChip(icon: Icons.person_outline_rounded, label: event.actor),
                        _MetaChip(icon: Icons.category_outlined, label: event.type.value(lang)),
                        _MetaChip(icon: Icons.label_outline_rounded, label: event.entity.value(lang)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
