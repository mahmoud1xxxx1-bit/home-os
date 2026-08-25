import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final store = ref.watch(localStoreProvider);
    final items = store.family;

    return ResponsivePage(
      title: l10n.family,
      actions: [
        IconButton(
          tooltip: 'Invite Member',
          icon: const Icon(Icons.person_add_rounded),
          onPressed: () {
            store.upsertFamilyMember(FamilyMember(
              id: 'f-${DateTime.now().millisecondsSinceEpoch}',
              name: 'New Invite',
              role: FamilyRole.viewer,
              status: const LocalizedText(ar: 'مدعو', en: 'Invited'),
            ));
          },
        )
      ],
      children: [
        AppCard(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(lang == 'ar' ? 'المشاهد لا يمكنه التعديل أو الحذف.' : 'Viewers cannot edit or delete data.')),
            ],
          ),
        )),
        const SizedBox(height: 16),
        ...items.map((m) => AppCard(
          child: ListTile(
            leading: CircleAvatar(child: Text(m.name[0])),
            title: Text(m.name),
            subtitle: Text('${m.role.name} • ${m.status.value(lang)}'),
            trailing: PopupMenuButton<FamilyRole>(
              onSelected: (role) {
                store.upsertFamilyMember(FamilyMember(id: m.id, name: m.name, role: role, status: m.status));
              },
              itemBuilder: (ctx) => FamilyRole.values.map((r) => PopupMenuItem(value: r, child: Text(r.name))).toList(),
            ),
          ),
        )),
      ],
    );
  }
}
