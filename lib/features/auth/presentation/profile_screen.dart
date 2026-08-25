import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import 'auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final lang = Localizations.localeOf(context).languageCode;
    final isGuest = user?.email == null || user!.email!.trim().isEmpty;

    return ResponsivePage(
      title: lang == 'ar' ? 'الحساب' : 'Account',
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: .78),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(isGuest ? Icons.person_outline_rounded : Icons.person_rounded, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? (lang == 'ar' ? 'ضيف' : 'Guest'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      isGuest ? (lang == 'ar' ? 'حساب ضيف' : 'Guest account') : (user?.email ?? ''),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: isGuest ? (lang == 'ar' ? 'ضيف' : 'Guest') : (lang == 'ar' ? 'Google' : 'Google')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isGuest)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.secondary),
              title: Text(lang == 'ar' ? 'أنت تستخدم Home OS كضيف' : 'You are using Home OS as a guest', style: const TextStyle(fontWeight: FontWeight.w750)),
              subtitle: Text(
                lang == 'ar'
                    ? 'احتفظ بهذا الحساب على الجهاز الحالي. سنضيف لاحقًا ترقية سلسة إلى Google دون فقدان البيانات.'
                    : 'Keep using this guest account on this device. A seamless Google upgrade without data loss will be added later.',
              ),
            ),
          ),
        const SizedBox(height: 18),
        SectionTitle(lang == 'ar' ? 'إدارة الحساب' : 'Account actions'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Log out', style: const TextStyle(fontWeight: FontWeight.w750)),
                subtitle: Text(lang == 'ar' ? 'لن تُحذف بياناتك.' : 'Your data will not be deleted.'),
                onTap: () => _logout(context, ref, lang),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
                title: Text(lang == 'ar' ? 'حذف الحساب' : 'Delete account', style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.error)),
                subtitle: Text(lang == 'ar' ? 'إجراء خطير ولا يمكن التراجع عنه.' : 'A destructive action that cannot be undone.'),
                onTap: () => _deleteAccount(context, ref, lang),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.logout_rounded),
            title: Text(lang == 'ar' ? 'هل تريد تسجيل الخروج؟' : 'Log out?'),
            content: Text(lang == 'ar' ? 'لن يتم حذف بياناتك. يمكنك العودة إليها عند تسجيل الدخول بالحساب نفسه.' : 'Your data will not be deleted. Sign in with the same account to access it again.'),
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

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref, String lang) async {
    final first = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(lang == 'ar' ? 'حذف الحساب نهائيًا؟' : 'Delete account permanently?'),
            content: Text(
              lang == 'ar'
                  ? 'سيتم حذف حساب تسجيل الدخول. بيانات Home OS المرتبطة بالحساب تحتاج معالجة حذف مستقلة قبل الإطلاق النهائي، لذلك لا نريد تنفيذ هذا بالخطأ.'
                  : 'Your sign-in account will be deleted. Home OS cloud data requires a dedicated deletion flow before production, so this action must never happen accidentally.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                onPressed: () => Navigator.pop(context, true),
                child: Text(lang == 'ar' ? 'متابعة' : 'Continue'),
              ),
            ],
          ),
        ) ??
        false;
    if (!first || !context.mounted) return;

    final second = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang == 'ar' ? 'تأكيد أخير' : 'Final confirmation'),
            content: Text(lang == 'ar' ? 'هل أنت متأكد تمامًا من حذف الحساب؟' : 'Are you absolutely sure you want to delete this account?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'احتفظ بحسابي' : 'Keep my account')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                onPressed: () => Navigator.pop(context, true),
                child: Text(lang == 'ar' ? 'حذف الحساب' : 'Delete account'),
              ),
            ],
          ),
        ) ??
        false;
    if (!second) return;

    await ref.read(authControllerProvider.notifier).deleteAccount();
    if (context.mounted) context.go('/auth');
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .75),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      );
}
