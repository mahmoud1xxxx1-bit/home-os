import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/extended_repository_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(familyProvider);
    final currentRole = items.isEmpty ? FamilyRole.owner : items.first.role;
    final canManage = currentRole != FamilyRole.viewer && currentRole != FamilyRole.limited;

    return ResponsivePage(
      title: l10n.family,
      actions: [
        if (canManage)
          IconButton(
            tooltip: lang == 'ar' ? 'إضافة عضو' : 'Add member',
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showAdd(context, ref, lang),
          ),
      ],
      children: [
        Text(
          lang == 'ar' ? 'شارك إدارة المنزل مع أفراد العائلة وحدد ما يستطيع كل شخص فعله.' : 'Share home management with family and control what each person can do.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(lang == 'ar' ? 'ماذا تعني الأدوار؟' : 'What do the roles mean?', style: const TextStyle(fontWeight: FontWeight.w800))),
                ],
              ),
              const SizedBox(height: 12),
              _RoleLine(role: FamilyRole.owner, lang: lang),
              _RoleLine(role: FamilyRole.admin, lang: lang),
              _RoleLine(role: FamilyRole.member, lang: lang),
              _RoleLine(role: FamilyRole.viewer, lang: lang),
              _RoleLine(role: FamilyRole.limited, lang: lang),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.group_rounded,
            title: lang == 'ar' ? 'لا يوجد أعضاء بعد' : 'No family members yet',
            message: lang == 'ar' ? 'أضف أول عضو وحدد دوره بوضوح.' : 'Add the first member and choose a clear role.',
            actionLabel: lang == 'ar' ? 'إضافة عضو' : 'Add member',
            onAction: () => _showAdd(context, ref, lang),
          )
        else
          ...items.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(member.name.isEmpty ? '?' : member.name.characters.first.toUpperCase()),
                  ),
                  title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${_roleLabel(member.role, lang)} • ${member.status.value(lang)}'),
                  trailing: canManage
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'remove') {
                              _remove(context, ref, member, lang);
                            } else {
                              final role = FamilyRole.values.byName(value);
                              ref.read(familyRepositoryProvider).upsertFamilyMember(
                                    FamilyMember(id: member.id, name: member.name, role: role, status: member.status),
                                  );
                              ref.invalidate(familyProvider);
                            }
                          },
                          itemBuilder: (context) => [
                            for (final role in FamilyRole.values)
                              PopupMenuItem(value: role.name, child: Text(_roleLabel(role, lang))),
                            const PopupMenuDivider(),
                            PopupMenuItem(value: 'remove', child: Text(lang == 'ar' ? 'إزالة العضو' : 'Remove member')),
                          ],
                        )
                      : const Icon(Icons.lock_outline_rounded),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, FamilyMember member, String lang) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang == 'ar' ? 'إزالة العضو؟' : 'Remove member?'),
            content: Text(lang == 'ar' ? 'سيتم إلغاء وصول ${member.name} إلى هذا المنزل.' : '${member.name} will lose access to this home.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(lang == 'ar' ? 'إزالة' : 'Remove')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    ref.read(familyRepositoryProvider).removeFamilyMember(member.id);
    ref.invalidate(familyProvider);
  }

  void _showAdd(BuildContext context, WidgetRef ref, String lang) {
    final nameCtrl = TextEditingController();
    var role = FamilyRole.viewer;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(ctx).bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang == 'ar' ? 'إضافة عضو' : 'Add member', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, autofocus: true, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: lang == 'ar' ? 'الاسم' : 'Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<FamilyRole>(
                initialValue: role,
                decoration: InputDecoration(labelText: lang == 'ar' ? 'الدور' : 'Role'),
                items: FamilyRole.values.map((value) => DropdownMenuItem(value: value, child: Text(_roleLabel(value, lang)))).toList(),
                onChanged: (value) => setSheetState(() => role = value ?? role),
              ),
              const SizedBox(height: 8),
              Text(_roleDescription(role, lang), style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    ref.read(familyRepositoryProvider).upsertFamilyMember(
                          FamilyMember(
                            id: 'family-${DateTime.now().microsecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            role: role,
                            status: const LocalizedText(ar: 'مدعو', en: 'Invited'),
                          ),
                        );
                    ref.invalidate(familyProvider);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'تمت إضافة العضو' : 'Family member added')));
                  },
                  child: Text(lang == 'ar' ? 'إضافة' : 'Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _roleLabel(FamilyRole role, String lang) => switch (role) {
      FamilyRole.owner => lang == 'ar' ? 'المالك' : 'Owner',
      FamilyRole.admin => lang == 'ar' ? 'مدير' : 'Admin',
      FamilyRole.member => lang == 'ar' ? 'عضو' : 'Member',
      FamilyRole.viewer => lang == 'ar' ? 'مشاهد' : 'Viewer',
      FamilyRole.limited => lang == 'ar' ? 'وصول محدود' : 'Limited',
    };

String _roleDescription(FamilyRole role, String lang) => switch (role) {
      FamilyRole.owner => lang == 'ar' ? 'تحكم كامل بالمنزل والأعضاء والإعدادات.' : 'Full control over the home, members and settings.',
      FamilyRole.admin => lang == 'ar' ? 'يمكنه إدارة أغلب البيانات والأعضاء.' : 'Can manage most home data and members.',
      FamilyRole.member => lang == 'ar' ? 'يمكنه إضافة وتحديث البيانات اليومية.' : 'Can add and update everyday home data.',
      FamilyRole.viewer => lang == 'ar' ? 'عرض فقط، بدون تعديل أو حذف.' : 'View only, without edit or delete access.',
      FamilyRole.limited => lang == 'ar' ? 'وصول محدود للأقسام التي تسمح بها.' : 'Limited access to selected sections.',
    };

class _RoleLine extends StatelessWidget {
  const _RoleLine({required this.role, required this.lang});
  final FamilyRole role;
  final String lang;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: '${_roleLabel(role, lang)}: ', style: const TextStyle(fontWeight: FontWeight.w800)),
                    TextSpan(text: _roleDescription(role, lang)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
