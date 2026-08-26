import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/subscriptions/subscription_providers.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final themeMode = ref.watch(themeControllerProvider);
    final entitlement = ref.watch(subscriptionEntitlementProvider);

    return ResponsivePage(
      title: lang == 'ar' ? 'الإعدادات' : 'Settings',
      children: [
        _IntroCard(lang: lang),
        const SizedBox(height: 18),
        _Group(
          title: lang == 'ar' ? 'الحساب' : 'Account',
          children: [
            _Tile(
              icon: Icons.person_outline_rounded,
              title: lang == 'ar' ? 'حسابي' : 'My account',
              subtitle: lang == 'ar' ? 'تسجيل الدخول، الحساب الضيف وحذف الحساب' : 'Sign-in, guest account and account deletion',
              onTap: () => context.push('/profile'),
            ),
            _Tile(
              icon: Icons.workspace_premium_outlined,
              title: lang == 'ar' ? 'الباقة' : 'Plan',
              subtitle: '${entitlement.title(lang)} • ${entitlement.priceLabel(lang)}',
              onTap: () => context.push('/upgrade'),
            ),
          ],
        ),
        _Group(
          title: lang == 'ar' ? 'المظهر والتفضيلات' : 'Appearance & preferences',
          children: [
            _Tile(
              icon: Icons.palette_outlined,
              title: lang == 'ar' ? 'المظهر' : 'Appearance',
              subtitle: _themeLabel(themeMode, lang),
              onTap: () => _chooseTheme(context, ref, lang, themeMode),
            ),
            _Tile(
              icon: Icons.language_rounded,
              title: lang == 'ar' ? 'اللغة' : 'Language',
              subtitle: lang == 'ar' ? 'العربية' : 'English',
              onTap: () => ref.read(localeControllerProvider.notifier).setLocale(Locale(lang == 'ar' ? 'en' : 'ar')),
            ),
            _Tile(
              icon: Icons.notifications_outlined,
              title: lang == 'ar' ? 'التذكيرات' : 'Reminders',
              subtitle: lang == 'ar' ? 'المواعيد والتنبيهات الخاصة بمنزلك' : 'Home schedules and reminders',
              onTap: () => context.push('/manage/reminders'),
            ),
          ],
        ),
        _Group(
          title: lang == 'ar' ? 'إدارة المنزل' : 'Home administration',
          children: [
            _Tile(
              icon: Icons.home_work_outlined,
              title: lang == 'ar' ? 'المنازل والغرف' : 'Homes & rooms',
              subtitle: lang == 'ar' ? 'إدارة هيكل المنزل والمواقع فقط' : 'Manage home structure and locations only',
              onTap: () => context.go('/house'),
            ),
            _Tile(
              icon: Icons.contacts_outlined,
              title: lang == 'ar' ? 'مقدمو الخدمات' : 'Service providers',
              subtitle: lang == 'ar' ? 'الأشخاص والشركات التي تتعامل معها' : 'People and companies you work with',
              onTap: () => context.push('/manage/providers'),
            ),
            _Tile(
              icon: Icons.group_outlined,
              title: lang == 'ar' ? 'العائلة والصلاحيات' : 'Family & permissions',
              subtitle: lang == 'ar' ? 'من يستطيع الوصول إلى Home OS' : 'Who can access Home OS',
              onTap: () => context.push('/manage/family'),
            ),
          ],
        ),
        _Group(
          title: lang == 'ar' ? 'المساعدة والخصوصية' : 'Help & privacy',
          children: [
            _Tile(
              icon: Icons.help_outline_rounded,
              title: lang == 'ar' ? 'مركز المساعدة' : 'Help center',
              subtitle: lang == 'ar' ? 'شرح مبسط لطريقة استخدام التطبيق' : 'Simple guidance for using the app',
              onTap: () => context.push('/manage/help'),
            ),
            _Tile(
              icon: Icons.shield_outlined,
              title: lang == 'ar' ? 'الخصوصية والأمان' : 'Privacy & security',
              subtitle: lang == 'ar' ? 'كيف نحمي بيانات منزلك' : 'How your home data is protected',
              onTap: () => _showPrivacy(context, lang),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(
              lang == 'ar' ? 'تسجيل الخروج' : 'Log out',
              style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(lang == 'ar' ? 'لن تُحذف بياناتك من Home OS.' : 'Your Home OS data will not be deleted.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _confirmLogout(context, ref, lang),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  static String _themeLabel(ThemeMode mode, String lang) => switch (mode) {
        ThemeMode.light => lang == 'ar' ? 'فاتح' : 'Light',
        ThemeMode.dark => lang == 'ar' ? 'داكن' : 'Dark',
        ThemeMode.system => lang == 'ar' ? 'حسب الجهاز' : 'System',
      };

  static Future<void> _chooseTheme(BuildContext context, WidgetRef ref, String lang, ThemeMode current) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang == 'ar' ? 'اختر المظهر' : 'Choose appearance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            for (final mode in ThemeMode.values)
              ListTile(
                leading: Icon(mode == ThemeMode.light ? Icons.light_mode_outlined : mode == ThemeMode.dark ? Icons.dark_mode_outlined : Icons.brightness_auto_outlined),
                title: Text(_themeLabel(mode, lang)),
                trailing: mode == current ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () => Navigator.pop(context, mode),
              ),
          ],
        ),
      ),
    );
    if (selected != null) await ref.read(themeControllerProvider.notifier).setThemeMode(selected);
  }

  static Future<void> _confirmLogout(BuildContext context, WidgetRef ref, String lang) async {
    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: Icon(Icons.logout_rounded, color: Theme.of(dialogContext).colorScheme.error),
            title: Text(lang == 'ar' ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to log out?'),
            content: Text(
              lang == 'ar'
                  ? 'لن تُحذف بياناتك. ستعود إلى شاشة الدخول ويمكنك استرجاع نفس البيانات عند الدخول بالحساب نفسه.'
                  : 'Your data will not be deleted. You will return to sign-in and can access the same data with the same account.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(lang == 'ar' ? 'نعم، تسجيل الخروج' : 'Yes, log out'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/auth');
  }

  static void _showPrivacy(BuildContext context, String lang) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang == 'ar' ? 'الخصوصية والأمان' : 'Privacy & security', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              lang == 'ar'
                  ? 'بيانات كل حساب معزولة داخل مساره الخاص في Firebase. لا يستطيع مستخدم آخر قراءة بيانات منزلك.'
                  : 'Each account is isolated inside its own Firebase path. Another user cannot read your home data.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.lang});
  final String lang;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(colors: [scheme.primaryContainer, scheme.secondaryContainer.withValues(alpha: .72)]),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .75), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.settings_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang == 'ar' ? 'إعدادات واضحة في مكان واحد' : 'Clear settings in one place', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(lang == 'ar' ? 'الحساب، المظهر، اللغة والخصوصية بدون خلطها بسجلات المنزل.' : 'Account, appearance, language and privacy without mixing them with home records.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) const Divider(height: 1, indent: 58),
                ],
              ],
            ),
          ),
        ],
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .55), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}
