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
    final store = ref.watch(localStoreProvider);
    final hits = store.search(_query.text, lang);
    return ResponsivePage(
      title: lang == 'ar' ? 'البحث' : 'Search',
      children: [
        TextField(
          controller: _query,
          autofocus: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            labelText: lang == 'ar' ? 'ابحث في المنزل' : 'Search Home OS',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        if (hits.isEmpty)
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.manage_search_rounded),
              title: Text(lang == 'ar' ? 'ابدأ بكتابة اسم جهاز أو مقدم خدمة أو مستند' : 'Start typing an asset, provider, or document'),
            ),
          )
        else
          for (final hit in hits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: hit.type == 'asset' ? () => context.push('/asset/${hit.id}') : null,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.search_rounded),
                  title: Text(hit.title.value(lang)),
                  subtitle: Text(hit.type),
                ),
              ),
            ),
      ],
    );
  }
}
