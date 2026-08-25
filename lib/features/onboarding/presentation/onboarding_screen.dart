import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  String _choice = 'ac';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      (Icons.home_work_rounded, l10n.onboarding1Title, l10n.onboarding1Body),
      (Icons.verified_rounded, l10n.onboarding2Title, l10n.onboarding2Body),
      (Icons.history_edu_rounded, l10n.onboarding3Title, l10n.onboarding3Body),
      (Icons.add_home_work_rounded, l10n.onboarding4Title, l10n.onboarding4Body),
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(onPressed: _finish, child: Text(l10n.skip)),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(page.$1, size: 92, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 28),
                            Text(page.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 12),
                            Text(page.$3, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                            if (index == 3) ...[
                              const SizedBox(height: 28),
                              TextField(decoration: InputDecoration(labelText: l10n.homeName, hintText: 'منزل الرياض')),
                              const SizedBox(height: 12),
                              TextField(decoration: InputDecoration(labelText: l10n.homeTypeOptional)),
                              const SizedBox(height: 18),
                              Align(alignment: AlignmentDirectional.centerStart, child: Text(l10n.firstThing)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final item in [
                                    ('ac', l10n.airConditioner),
                                    ('car', l10n.car),
                                    ('device', l10n.device),
                                    ('pool', l10n.pool),
                                    ('other', l10n.other),
                                  ])
                                    ChoiceChip(
                                      label: Text(item.$2),
                                      selected: _choice == item.$1,
                                      onSelected: (_) => setState(() => _choice = item.$1),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          width: i == _index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: i == _index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_index == pages.length - 1) {
                          _finish();
                        } else {
                          _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                        }
                      },
                      child: Text(_index == pages.length - 1 ? l10n.start : l10n.next),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (mounted) context.go('/');
  }
}
