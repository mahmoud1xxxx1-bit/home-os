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
    return ResponsivePage(
      title: 'Profile',
      children: [
        AppCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
            title: Text(user?.name ?? '-'),
            subtitle: Text(user?.email ?? '-'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () async {
            final ok = await _confirm(context, 'تسجيل الخروج؟');
            if (ok && context.mounted) {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/auth');
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('تسجيل الخروج'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () async {
            final ok = await _confirm(context, 'حذف الحساب المحلي؟');
            if (ok && context.mounted) {
              await ref.read(authControllerProvider.notifier).deleteAccount();
              if (context.mounted) context.go('/auth');
            }
          },
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('حذف الحساب'),
        ),
      ],
    );
  }

  Future<bool> _confirm(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
            ],
          ),
        ) ??
        false;
  }
}
