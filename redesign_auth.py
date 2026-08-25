import os

code = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../domain/auth_models.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Icon(Icons.home_work_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 18),
                Text('Home OS', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('تسجيل الدخول للمتابعة', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AppCard(
                  child: Column(
                    children: [
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _signIn(AuthProviderType.google),
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                            label: const Text('تسجيل الدخول باستخدام Google'),
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _signIn(AuthProviderType.apple), // Reusing Apple for Anonymous internally as setup earlier
                            icon: const Icon(Icons.person_outline_rounded),
                            label: const Text('المتابعة كضيف (Guest)'),
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 16)
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn(AuthProviderType type) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signInProvider(type);
      if (mounted) context.go('/onboarding');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
        setState(() => _isLoading = false);
      }
    }
  }
}
"""

with open('C:/Projects/home_os/lib/features/auth/presentation/auth_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
