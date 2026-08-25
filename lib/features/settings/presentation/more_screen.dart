import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final store = ref.watch(localStoreProvider);
    final providers = ref.watch(providersProvider);
    final documents = ref.watch(documentsProvider);
    final expenses = ref.watch(expensesProvider);

    return ResponsivePage(
      title: l10n.more,
      children: [
        AppCard(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(onPressed: () => context.push('/search'), icon: const Icon(Icons.search_rounded), label: const Text('Search')),
              FilledButton.tonalIcon(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_rounded), label: Text(l10n.account)),
            ],
          ),
        ),
        SectionTitle(lang == 'ar' ? 'إدارة الأقسام' : 'Manage sections'),
        AppCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in [
                ('homes', l10n.defaultHome, Icons.home_work_rounded),
                ('locations', l10n.location, Icons.room_preferences_rounded),
                ('assets', l10n.assets, Icons.devices_other_rounded),
                ('maintenance', l10n.maintenance, Icons.handyman_rounded),
                ('reminders', l10n.reminders, Icons.notifications_active_rounded),
                ('warranties', l10n.warranties, Icons.verified_rounded),
                ('services', l10n.services, Icons.cleaning_services_rounded),
                ('providers', l10n.providers, Icons.contacts_rounded),
                ('documents', l10n.documents, Icons.description_rounded),
                ('expenses', l10n.expenses, Icons.payments_rounded),
                ('family', l10n.family, Icons.group_rounded),
                ('reports', l10n.reports, Icons.bar_chart_rounded),
                ('help', l10n.help, Icons.help_outline_rounded),
              ])
                ActionChip(
                  avatar: Icon(item.$3),
                  label: Text(item.$2),
                  onPressed: () => context.push('/manage/${item.$1}'),
                ),
            ],
          ),
        ),
        SectionTitle(l10n.services),
        for (final service in store.services)
          _InfoTile(
            icon: Icons.cleaning_services_rounded,
            title: service.name.value(lang),
            subtitle: '${l10n.frequency}: ${service.frequency.value(lang)} • ${l10n.nextVisit}: ${compactDate(service.nextVisit, lang)}',
          ),
        SectionTitle(l10n.providers),
        for (final provider in providers)
          _InfoTile(
            icon: Icons.contacts_rounded,
            title: provider.name,
            subtitle: '${provider.type.value(lang)} • ${provider.phone} • ${provider.visitCount}',
          ),
        SectionTitle(l10n.warranties),
        for (final warranty in store.warranties)
          _InfoTile(
            icon: Icons.verified_rounded,
            title: warranty.provider,
            subtitle: '${_warrantyStatus(warranty.status, l10n)} • ${compactDate(warranty.end, lang)}',
          ),
        SectionTitle(l10n.documents),
        for (final document in documents)
          _InfoTile(
            icon: Icons.description_rounded,
            title: document.title.value(lang),
            subtitle: '${document.category.value(lang)} • ${document.placeholder}',
          ),
        SectionTitle(l10n.expenses),
        AppCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Pill(l10n.thisMonth, '${expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(0)} SAR'),
              _Pill(l10n.thisYear, '1330 SAR'),
              _Pill(l10n.byCategory, l10n.maintenance),
              _Pill(l10n.byAsset, store.watchAssets().first.name.value(lang)),
            ],
          ),
        ),
        SectionTitle(l10n.family),
        for (final member in store.family)
          _InfoTile(icon: Icons.group_rounded, title: member.name, subtitle: '${member.role.name} • ${member.status.value(lang)}'),
        SectionTitle(l10n.reports),
        _InfoTile(icon: Icons.bar_chart_rounded, title: l10n.reports, subtitle: l10n.comingReady),
        SectionTitle(l10n.settings),
        _SettingsGroup(title: lang == 'ar' ? 'الحساب' : 'Account', items: [
            _SettingsItem(lang == 'ar' ? 'الحساب الشخصي' : 'Profile', Icons.person_outline_rounded, () => context.push('/profile')),
            _SettingsItem(lang == 'ar' ? 'أمان الحساب' : 'Security', Icons.shield_outlined, () {}),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'المظهر والتفضيلات' : 'Appearance & Preferences', items: [
            _SettingsItem(lang == 'ar' ? 'السمة (فاتح/داكن)' : 'Theme (Light/Dark)', Icons.palette_outlined, () {}),
            _SettingsItem(lang == 'ar' ? 'اللغة' : 'Language', Icons.language_rounded, () {}),
            _SettingsItem(lang == 'ar' ? 'الإشعارات' : 'Notifications', Icons.notifications_outlined, () {}),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'البيانات' : 'Data', items: [
            _SettingsItem(lang == 'ar' ? 'تصدير البيانات' : 'Export Data', Icons.download_rounded, () {}),
            _SettingsItem(lang == 'ar' ? 'إدارة المساحة' : 'Storage Management', Icons.storage_rounded, () {}),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'حول' : 'About', items: [
            _SettingsItem(lang == 'ar' ? 'مركز المساعدة' : 'Help Center', Icons.help_outline_rounded, () {}),
            _SettingsItem(lang == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy', Icons.privacy_tip_outlined, () {}),
        ]),
        const SizedBox(height: 16),
        Center(child: TextButton.icon(onPressed: (){}, icon: const Icon(Icons.logout_rounded, color: Colors.red), label: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Log out', style: const TextStyle(color: Colors.red)))),
        const SizedBox(height: 32),
      ],
    );
  }

  String _warrantyStatus(dynamic status, AppLocalizations l10n) {
    final name = status.name as String;
    return switch (name) {
      'valid' => l10n.valid,
      'expiringSoon' => l10n.expiringSoon,
      _ => l10n.expired,
    };
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.title, this.value);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.payments_rounded),
      label: Text('$title: $value'),
    );
  }
}


class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});
  final String title;
  final List<_SettingsItem> items;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary))),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  leading: Icon(items[i].icon),
                  title: Text(items[i].title),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: items[i].onTap,
                ),
                if (i < items.length - 1) const Divider(height: 1, indent: 56),
              ]
            ]
          )
        )
      ]
    );
  }
}
class _SettingsItem { const _SettingsItem(this.title, this.icon, this.onTap); final String title; final IconData icon; final VoidCallback onTap; }
