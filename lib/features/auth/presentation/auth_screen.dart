import 'package:flutter/material.dart';
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
    final lang = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  margin: const EdgeInsets.symmetric(horizontal: 180),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [scheme.primaryContainer, scheme.secondaryContainer]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(Icons.home_work_rounded, size: 44, color: scheme.primary),
                ),
                const SizedBox(height: 20),
                Text('Home OS', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  lang == 'ar' ? 'منزلك منظم، ومعلوماته في مكان واحد.' : 'Your home, organized in one trusted place.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        lang == 'ar' ? 'ابدأ الآن' : 'Get started',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang == 'ar'
                            ? 'استخدم Google لحساب دائم، أو جرّب التطبيق أولًا كضيف.'
                            : 'Use Google for a permanent account, or try Home OS as a guest first.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.45),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : () => _signIn(AuthProviderType.google, lang),
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                          label: Text(lang == 'ar' ? 'المتابعة باستخدام Google' : 'Continue with Google'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => _signIn(AuthProviderType.anonymous, lang),
                          icon: const Icon(Icons.person_outline_rounded),
                          label: Text(lang == 'ar' ? 'المتابعة كضيف' : 'Continue as guest'),
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 10),
                            Text(lang == 'ar' ? 'جارٍ تجهيز حسابك...' : 'Preparing your account...'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  lang == 'ar'
                      ? 'لن نعرض رسائل تقنية خام. إذا تعذر تسجيل الدخول ستظهر لك رسالة واضحة ويمكنك المحاولة مرة أخرى.'
                      : 'If sign-in fails, Home OS will show a clear message instead of technical error text.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn(AuthProviderType type, String lang) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signInProvider(type);
      if (mounted) context.go('/onboarding');
    } on StateError catch (error) {
      if (!mounted) return;
      if (error.message == 'GOOGLE_SIGN_IN_CANCELLED') return;
      _showError(lang == 'ar' ? 'تعذر تسجيل الدخول الآن. حاول مرة أخرى.' : 'Sign-in could not be completed. Please try again.');
    } catch (_) {
      if (!mounted) return;
      _showError(
        lang == 'ar'
            ? 'لم نتمكن من تسجيل الدخول. تحقق من اتصال الإنترنت ثم حاول مرة أخرى.'
            : 'We could not sign you in. Check your internet connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
