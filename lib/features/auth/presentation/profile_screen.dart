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
    final email = user?.email;
    final providerName = user?.provider.name ?? 'anonymous';
    final isGuest = providerName == 'anonymous' || email == null || email.trim().isEmpty;
    final providerLabel = switch (providerName) {
      'google' => 'Google',
      'email' => lang == 'ar' ? 'بريد إلكتروني' : 'Email',
      'apple' => 'Apple',
      _ => lang == 'ar' ? 'ضيف' : 'Guest',
    };

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
                      isGuest ? (lang == 'ar' ? 'حساب ضيف' : 'Guest account') : email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: providerLabel),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isGuest)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.secondary),
              title: Text(lang == 'ar' ? 'أنت تستخدم Home OS كضيف' : 'You are using Home OS as a guest', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                lang == 'ar'
                    ? 'بيانات هذا الحساب مرتبطة بمعرّف الضيف الحالي. قبل الإطلاق النهائي سنضيف ترقية آمنة إلى Google دون فقد البيانات.'
                    : 'This data is tied to the current guest identity. Before production we will add a safe upgrade to Google without losing data.',
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
                title: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Log out', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(lang == 'ar' ? 'لن تُحذف بياناتك.' : 'Your data will not be deleted.'),
                onTap: () => _logout(context, ref, lang),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
                title: Text(lang == 'ar' ? 'حذف الحساب' : 'Delete account', style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.error)),
                subtitle: Text(lang == 'ar' ? 'يحذف الحساب وبيانات Home OS نهائيًا.' : 'Permanently deletes the account and Home OS data.'),
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
                  ? 'سيتم حذف حساب تسجيل الدخول وجميع بيانات Home OS السحابية المرتبطة به، بما فيها الأصول والصيانة والتذكيرات والضمانات والمستندات والمصاريف. لا يمكن التراجع عن هذا الإجراء.'
                  : 'Your sign-in account and all Home OS cloud data linked to it will be deleted, including assets, maintenance, reminders, warranties, documents and expenses. This cannot be undone.',
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
            content: Text(lang == 'ar' ? 'هل أنت متأكد تمامًا؟ سيتم حذف الحساب وبياناته نهائيًا.' : 'Are you absolutely sure? The account and its data will be permanently deleted.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'احتفظ بحسابي' : 'Keep my account')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                onPressed: () => Navigator.pop(context, true),
                child: Text(lang == 'ar' ? 'حذف الحساب والبيانات' : 'Delete account & data'),
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
