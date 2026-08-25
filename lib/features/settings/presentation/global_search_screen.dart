import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final term = _query.text.trim().toLowerCase();
    final assets = ref.watch(assetsProvider);
    final providers = ref.watch(providersProvider);
    final documents = ref.watch(documentsProvider);
    final locations = ref.watch(homeRepositoryProvider).watchLocations();

    final hits = <_SearchHit>[];
    if (term.isNotEmpty) {
      for (final asset in assets) {
        final name = asset.name.value(lang);
        if (name.toLowerCase().contains(term) || (asset.brand ?? '').toLowerCase().contains(term) || (asset.model ?? '').toLowerCase().contains(term)) {
          hits.add(_SearchHit(type: 'asset', title: name, subtitle: lang == 'ar' ? 'أصل' : 'Asset', icon: Icons.devices_other_rounded, route: '/asset/${asset.id}'));
        }
      }
      for (final provider in providers) {
        if (provider.name.toLowerCase().contains(term) || provider.type.value(lang).toLowerCase().contains(term) || provider.phone.toLowerCase().contains(term)) {
          hits.add(_SearchHit(type: 'provider', title: provider.name, subtitle: lang == 'ar' ? 'مقدم خدمة' : 'Provider', icon: Icons.contacts_rounded, route: '/manage/providers'));
        }
      }
      for (final document in documents) {
        if (document.title.value(lang).toLowerCase().contains(term) || document.category.value(lang).toLowerCase().contains(term)) {
          hits.add(_SearchHit(type: 'document', title: document.title.value(lang), subtitle: document.category.value(lang), icon: Icons.description_rounded, route: '/manage/documents'));
        }
      }
      for (final location in locations) {
        if (location.name.value(lang).toLowerCase().contains(term)) {
          hits.add(_SearchHit(type: 'location', title: location.name.value(lang), subtitle: lang == 'ar' ? 'موقع أو غرفة' : 'Location or room', icon: Icons.room_preferences_rounded, route: '/house'));
        }
      }
    }

    return ResponsivePage(
      title: lang == 'ar' ? 'البحث' : 'Search',
      children: [
        Text(
          lang == 'ar' ? 'ابحث في الأجهزة والمواقع ومقدمي الخدمات والمستندات.' : 'Search assets, locations, providers and documents.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _query,
          autofocus: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: lang == 'ar' ? 'مثال: المكيف، التأمين، أحمد...' : 'Try AC, insurance, Ahmed...',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        if (term.isEmpty)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.manage_search_rounded, color: Theme.of(context).colorScheme.primary),
              title: Text(lang == 'ar' ? 'ابدأ بكتابة ما تبحث عنه' : 'Start typing what you are looking for', style: const TextStyle(fontWeight: FontWeight.w750)),
              subtitle: Text(lang == 'ar' ? 'ستظهر النتائج هنا مصنفة حسب نوعها.' : 'Results will appear here with clear categories.'),
            ),
          )
        else if (hits.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: lang == 'ar' ? 'لم نجد نتيجة' : 'No results found',
            message: lang == 'ar' ? 'جرّب اسمًا أقصر أو كلمة مختلفة.' : 'Try a shorter name or a different keyword.',
            actionLabel: lang == 'ar' ? 'مسح البحث' : 'Clear search',
            onAction: () {
              _query.clear();
              setState(() {});
            },
          )
        else
          for (final hit in hits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => context.push(hit.route),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .58),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(hit.icon, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(hit.title, style: const TextStyle(fontWeight: FontWeight.w750)),
                  subtitle: Text(hit.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
      ],
    );
  }
}

class _SearchHit {
  const _SearchHit({required this.type, required this.title, required this.subtitle, required this.icon, required this.route});
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
