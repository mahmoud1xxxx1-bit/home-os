import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  final _homeName = TextEditingController();
  final _homeType = TextEditingController();
  int _index = 0;
  String _choice = 'ac';
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _homeName.dispose();
    _homeType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final pages = [
      (Icons.home_work_rounded, l10n.onboarding1Title, l10n.onboarding1Body),
      (Icons.verified_rounded, l10n.onboarding2Title, l10n.onboarding2Body),
      (Icons.history_edu_rounded, l10n.onboarding3Title, l10n.onboarding3Body),
      (Icons.add_home_work_rounded, l10n.onboarding4Title, l10n.onboarding4Body),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _saving ? null : () => _finish(createHome: false),
                      child: Text(l10n.skip),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: (value) {
                        FocusScope.of(context).unfocus();
                        setState(() => _index = value);
                      },
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              top: 16,
                              bottom: MediaQuery.viewInsetsOf(context).bottom > 0 ? 20 : 40,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                              child: Column(
                                mainAxisAlignment: index == 3 ? MainAxisAlignment.start : MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: index == 3 ? 90 : 118,
                                    height: index == 3 ? 90 : 118,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).colorScheme.primaryContainer,
                                          Theme.of(context).colorScheme.secondaryContainer,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Icon(page.$1, size: index == 3 ? 46 : 58, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    page.$2,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    page.$3,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          height: 1.55,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  if (index == 3) ...[
                                    const SizedBox(height: 26),
                                    TextField(
                                      controller: _homeName,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: l10n.homeName,
                                        hintText: lang == 'ar' ? 'مثال: منزل الرياض' : 'Example: Riyadh Home',
                                        prefixIcon: const Icon(Icons.home_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _homeType,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                      decoration: InputDecoration(
                                        labelText: l10n.homeTypeOptional,
                                        hintText: lang == 'ar' ? 'فيلا، شقة، استراحة...' : 'Villa, apartment, vacation home...',
                                        prefixIcon: const Icon(Icons.category_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: Text(
                                        l10n.firstThing,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final item in [
                                          ('ac', l10n.airConditioner, Icons.ac_unit_rounded),
                                          ('car', l10n.car, Icons.directions_car_rounded),
                                          ('device', l10n.device, Icons.devices_other_rounded),
                                          ('pool', l10n.pool, Icons.pool_rounded),
                                          ('other', l10n.other, Icons.more_horiz_rounded),
                                        ])
                                          ChoiceChip(
                                            avatar: Icon(item.$3, size: 18),
                                            label: Text(item.$2),
                                            selected: _choice == item.$1,
                                            onSelected: (_) => setState(() => _choice = item.$1),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
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
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (_index == pages.length - 1) {
                                _finish(createHome: true);
                              } else {
                                _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
                              }
                            },
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(_index == pages.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded),
                      label: Text(_index == pages.length - 1 ? l10n.start : l10n.next),
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

  Future<void> _finish({required bool createHome}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (createHome) {
        final name = _homeName.text.trim();
        if (name.isNotEmpty) {
          final now = DateTime.now();
          ref.read(homeRepositoryProvider).upsertHome(
                HomeProfile(
                  id: 'home-${now.microsecondsSinceEpoch}',
                  name: LocalizedText(ar: name, en: name),
                  type: LocalizedText(
                    ar: _homeType.text.trim().isEmpty ? 'منزل' : _homeType.text.trim(),
                    en: _homeType.text.trim().isEmpty ? 'Home' : _homeType.text.trim(),
                  ),
                  createdAt: now,
                ),
              );
        }
      }
      await ref.read(authControllerProvider.notifier).completeOnboarding();
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
