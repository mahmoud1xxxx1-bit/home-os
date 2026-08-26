import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/subscriptions/entitlements.dart';
import '../../../core/subscriptions/subscription_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key, this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final current = ref.watch(subscriptionEntitlementProvider);
    final usage = ref.watch(usageSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;

    return ResponsivePage(
      title: lang == 'ar' ? 'خطط Home OS' : 'Home OS plans',
      children: [
        AppCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.workspace_premium_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_reasonTitle(lang), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(_reasonMessage(lang), style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          title: lang == 'ar' ? 'مجانية' : 'Free',
          price: r'$0',
          subtitle: lang == 'ar' ? 'لتجربة Home OS بشكل حقيقي.' : 'A real way to try Home OS.',
          features: [
            lang == 'ar' ? 'منزل واحد' : '1 home',
            lang == 'ar' ? '10 أصول' : '10 assets',
            lang == 'ar' ? '10 تذكيرات نشطة' : '10 active reminders',
            lang == 'ar' ? '10 سجلات صيانة' : '10 maintenance records',
            lang == 'ar' ? '5 ضمانات' : '5 warranties',
            lang == 'ar' ? '10 مستندات' : '10 documents',
            lang == 'ar' ? '3 مقدمي خدمات' : '3 providers',
          ],
          selected: current.tier == SubscriptionTier.free,
        ),
        const SizedBox(height: 14),
        _PlanCard(
          title: 'Home OS Unlimited',
          price: r'$20 / month',
          subtitle: lang == 'ar' ? 'استخدام غير محدود لمنزل واحد.' : 'Unlimited use for one home.',
          features: [
            lang == 'ar' ? 'منزل واحد' : '1 home',
            lang == 'ar' ? 'أصول وصيانة وضمانات بلا حدود عملية' : 'Unlimited assets, maintenance and warranties',
            lang == 'ar' ? 'تذكيرات ومستندات ومقدمو خدمات بلا حدود عملية' : 'Unlimited reminders, documents and providers',
            lang == 'ar' ? 'كل ميزات Home OS الحالية' : 'All current Home OS features',
          ],
          highlighted: true,
          selected: current.tier == SubscriptionTier.unlimited,
        ),
        const SizedBox(height: 14),
        _PlanCard(
          title: 'Home OS Multi‑Home',
          price: r'$35 / month',
          subtitle: lang == 'ar' ? 'لإدارة أكثر من منزل من حساب واحد.' : 'Manage multiple homes from one account.',
          features: [
            lang == 'ar' ? 'عدة منازل' : 'Multiple homes',
            lang == 'ar' ? 'كل مزايا Unlimited' : 'Everything in Unlimited',
            lang == 'ar' ? 'بيانات كل منزل منظمة بشكل مستقل' : 'Each home stays clearly organized',
          ],
          selected: current.tier == SubscriptionTier.multiHome,
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang == 'ar' ? 'استخدامك الحالي' : 'Your current usage', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _UsageRow(label: lang == 'ar' ? 'المنازل' : 'Homes', value: '${usage.homes}'),
              _UsageRow(label: lang == 'ar' ? 'الأصول' : 'Assets', value: '${usage.assets}'),
              _UsageRow(label: lang == 'ar' ? 'التذكيرات النشطة' : 'Active reminders', value: '${usage.activeReminders}'),
              _UsageRow(label: lang == 'ar' ? 'الصيانة' : 'Maintenance', value: '${usage.maintenance}'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(18)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline_rounded, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang == 'ar'
                      ? 'ربط الشراء بمتجر Google Play هو الخطوة التالية. لن يتم خصم أي مبلغ قبل تفعيل منتجات الاشتراك رسميًا.'
                      : 'Google Play Billing is the next integration step. No charge can occur until the subscription products are activated.',
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), label: Text(lang == 'ar' ? 'العودة' : 'Back')),
      ],
    );
  }

  String _reasonTitle(String lang) {
    if (reason == 'multi_home_required') return lang == 'ar' ? 'تحتاج إلى Multi‑Home' : 'Multi‑Home required';
    if (reason == 'free_limit_reached') return lang == 'ar' ? 'وصلت إلى حد الباقة المجانية' : 'Free plan limit reached';
    return lang == 'ar' ? 'اختر الخطة المناسبة لك' : 'Choose the plan that fits you';
  }

  String _reasonMessage(String lang) {
    if (reason == 'multi_home_required') {
      return lang == 'ar' ? 'Unlimited يسمح بمنزل واحد. لإضافة منزل ثانٍ أو أكثر تحتاج إلى باقة Multi‑Home.' : 'Unlimited includes one home. A second home requires Multi‑Home.';
    }
    if (reason == 'free_limit_reached') {
      return lang == 'ar' ? 'لن نحذف بياناتك. أوقفنا الإضافة الجديدة فقط حتى تختار الترقية المناسبة.' : 'Your data stays safe. Only new additions are paused until you upgrade.';
    }
    return lang == 'ar' ? 'ابدأ مجانًا، ثم رقِّ فقط عندما تحتاج مساحة أكبر.' : 'Start free and upgrade only when you need more.';
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.price, required this.subtitle, required this.features, this.highlighted = false, this.selected = false});

  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool highlighted;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: highlighted ? scheme.primary.withValues(alpha: .65) : scheme.outlineVariant),
        gradient: highlighted
            ? LinearGradient(colors: [scheme.primaryContainer.withValues(alpha: .42), scheme.surfaceContainerHighest.withValues(alpha: .18)])
            : null,
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                if (selected) Icon(Icons.check_circle_rounded, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 6),
            Text(price, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: highlighted ? scheme.primary : null)),
            const SizedBox(height: 5),
            Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 14),
            for (final feature in features)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [Icon(Icons.check_rounded, size: 18, color: scheme.primary), const SizedBox(width: 8), Expanded(child: Text(feature))]),
              ),
          ],
        ),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]),
      );
}
