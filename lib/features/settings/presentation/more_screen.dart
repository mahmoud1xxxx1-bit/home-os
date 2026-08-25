import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final themeMode = ref.watch(themeControllerProvider);

    return ResponsivePage(
      title: l10n.more,
      children: [
        _HeroCard(lang: lang, onSearch: () => context.push('/search'), onProfile: () => context.push('/profile')),
        SectionTitle(lang == 'ar' ? 'إدارة المنزل' : 'Manage Home'),
        AppCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              for (final item in [
                ('homes', lang == 'ar' ? 'المنازل' : 'Homes', Icons.home_work_rounded),
                ('locations', lang == 'ar' ? 'المواقع والغرف' : 'Locations & rooms', Icons.room_preferences_rounded),
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
              ])
                _NavTile(icon: item.$3, title: item.$2, onTap: () => context.push('/manage/${item.$1}')),
            ],
          ),
        ),
        SectionTitle(l10n.settings),
        _SettingsGroup(
          title: lang == 'ar' ? 'الحساب والأمان' : 'Account & security',
          items: [
            _SettingsItem(
              title: lang == 'ar' ? 'الحساب الشخصي' : 'Profile',
              subtitle: lang == 'ar' ? 'معلومات الحساب وتسجيل الدخول' : 'Account and sign-in details',
              icon: Icons.person_outline_rounded,
              onTap: () => context.push('/profile'),
            ),
            _SettingsItem(
              title: lang == 'ar' ? 'الخصوصية والأمان' : 'Privacy & security',
              subtitle: lang == 'ar' ? 'كيف نحمي بيانات منزلك' : 'How your home data is protected',
              icon: Icons.shield_outlined,
              onTap: () => _showInfo(
                context,
                lang == 'ar' ? 'الخصوصية والأمان' : 'Privacy & security',
                lang == 'ar'
                    ? 'بياناتك السحابية معزولة حسب حسابك في Firebase. لا يستطيع مستخدم آخر قراءة بيانات منزلك.'
                    : 'Your cloud data is isolated by your Firebase account. Another user cannot read your home data.',
              ),
            ),
          ],
        ),
        _SettingsGroup(
          title: lang == 'ar' ? 'المظهر والتفضيلات' : 'Appearance & preferences',
          items: [
            _SettingsItem(
              title: lang == 'ar' ? 'المظهر' : 'Appearance',
              subtitle: _themeLabel(themeMode, lang),
              icon: Icons.palette_outlined,
              onTap: () => _chooseTheme(context, ref, lang, themeMode),
            ),
            _SettingsItem(
              title: lang == 'ar' ? 'اللغة' : 'Language',
              subtitle: lang == 'ar' ? 'العربية' : 'English',
              icon: Icons.language_rounded,
              onTap: () => ref.read(localeControllerProvider.notifier).setLocale(Locale(lang == 'ar' ? 'en' : 'ar')),
            ),
            _SettingsItem(
              title: lang == 'ar' ? 'الإشعارات والتذكيرات' : 'Notifications & reminders',
              subtitle: lang == 'ar' ? 'إدارة المواعيد والتنبيهات' : 'Manage schedules and alerts',
              icon: Icons.notifications_outlined,
              onTap: () => context.push('/manage/reminders'),
            ),
          ],
        ),
        _SettingsGroup(
          title: lang == 'ar' ? 'المساعدة والمعلومات' : 'Help & information',
          items: [
            _SettingsItem(
              title: lang == 'ar' ? 'مركز المساعدة' : 'Help center',
              subtitle: lang == 'ar' ? 'شرح مبسط لأقسام Home OS' : 'Simple guides for Home OS',
              icon: Icons.help_outline_rounded,
              onTap: () => context.push('/manage/help'),
            ),
            _SettingsItem(
              title: lang == 'ar' ? 'حول Home OS' : 'About Home OS',
              subtitle: lang == 'ar' ? 'الإصدار والخصوصية والدعم' : 'Version, privacy and support',
              icon: Icons.info_outline_rounded,
              onTap: () => _showInfo(
                context,
                'Home OS',
                lang == 'ar'
                    ? 'Home OS يساعدك على تنظيم المنزل والأجهزة والصيانة والضمانات والتذكيرات في مكان واحد.'
                    : 'Home OS keeps your home, assets, maintenance, warranties and reminders organized in one place.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: ListTile(
            leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(
              lang == 'ar' ? 'تسجيل الخروج' : 'Log out',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(lang == 'ar' ? 'ستحتاج لتسجيل الدخول للوصول إلى بياناتك مرة أخرى.' : 'You will need to sign in again to access your data.'),
            onTap: () => _confirmLogout(context, ref, lang),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _themeLabel(ThemeMode mode, String lang) => switch (mode) {
        ThemeMode.light => lang == 'ar' ? 'فاتح' : 'Light',
        ThemeMode.dark => lang == 'ar' ? 'داكن' : 'Dark',
        ThemeMode.system => lang == 'ar' ? 'حسب الجهاز' : 'System',
      };

  Future<void> _chooseTheme(BuildContext context, WidgetRef ref, String lang, ThemeMode current) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang == 'ar' ? 'اختر المظهر' : 'Choose appearance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: current,
                  title: Text(_themeLabel(mode, lang)),
                  onChanged: (value) => Navigator.pop(context, value),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(themeControllerProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.logout_rounded),
            title: Text(lang == 'ar' ? 'هل تريد تسجيل الخروج؟' : 'Log out?'),
            content: Text(
              lang == 'ar'
                  ? 'لن تُحذف بياناتك. يمكنك العودة إليها عند تسجيل الدخول بالحساب نفسه.'
                  : 'Your data will not be deleted. Sign in with the same account to access it again.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Log out')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/auth');
  }

  void _showInfo(BuildContext context, String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.lang, required this.onSearch, required this.onProfile});
  final String lang;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [scheme.primaryContainer, scheme.secondaryContainer.withValues(alpha: .82)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tune_rounded, color: scheme.onPrimaryContainer, size: 30),
          const SizedBox(height: 14),
          Text(
            lang == 'ar' ? 'كل شيء في مكانه' : 'Everything in its place',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'ar' ? 'أدر منزلك، حسابك وتفضيلاتك من هنا.' : 'Manage your home, account and preferences here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: .78)),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(onPressed: onProfile, icon: const Icon(Icons.person_rounded), label: Text(lang == 'ar' ? 'حسابي' : 'My account')),
              OutlinedButton.icon(onPressed: onSearch, icon: const Icon(Icons.search_rounded), label: Text(lang == 'ar' ? 'بحث' : 'Search')),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});
  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  ListTile(
                    leading: Icon(items[i].icon),
                    title: Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(items[i].subtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: items[i].onTap,
                  ),
                  if (i < items.length - 1) const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      );
}

class _SettingsItem {
  const _SettingsItem({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
