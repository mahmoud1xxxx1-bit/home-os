import os
import re

def rewrite_settings():
    path = 'lib/features/settings/presentation/more_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find where SectionTitle(l10n.settings) starts
    start_str = "SectionTitle(l10n.settings),"
    start_idx = content.find(start_str)
    
    if start_idx != -1:
        # we will replace everything from SectionTitle(l10n.settings), to the end of the build method
        # The build method ends at:
        #       ],
        #     );
        #   }
        # 
        #   String _warrantyStatus
        
        end_str = "  String _warrantyStatus"
        end_idx = content.find(end_str)
        
        if end_idx != -1:
            # We want to replace the whole settings list with standard grouped tiles.
            new_settings = """SectionTitle(l10n.settings),
        _SettingsGroup(title: lang == 'ar' ? 'الحساب' : 'Account', items: [
            _SettingsItem(lang == 'ar' ? 'الحساب الشخصي' : 'Profile', Icons.person_outline_rounded, () => context.push('/profile')),
            _SettingsItem(lang == 'ar' ? 'أمان الحساب' : 'Security', Icons.shield_outlined, () {}),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'المظهر والتفضيلات' : 'Appearance & Preferences', items: [
            _SettingsItem(lang == 'ar' ? 'السمة (فاتح/داكن)' : 'Theme (Light/Dark)', Icons.palette_outlined, () {}),
            _SettingsItem(lang == 'ar' ? 'اللغة' : 'Language', Icons.language_rounded, () {}),
            _SettingsItem(lang == 'ar' ? 'الإشعارات' : 'Notifications', Icons.notifications_outlined, () {}),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'البيانات' : 'Data', items: [
            _SettingsItem(lang == 'ar' ? 'تصدير البيانات' : 'Export Data', Icons.download_rounded, () {}),
            _SettingsItem(lang == 'ar' ? 'إدارة المساحة' : 'Storage Management', Icons.storage_rounded, () {}),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'حول' : 'About', items: [
            _SettingsItem(lang == 'ar' ? 'مركز المساعدة' : 'Help Center', Icons.help_outline_rounded, () {}),
            _SettingsItem(lang == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy', Icons.privacy_tip_outlined, () {}),
        ]),
        const SizedBox(height: 16),
        Center(child: TextButton.icon(onPressed: (){}, icon: const Icon(Icons.logout_rounded, color: Colors.red), label: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Log out', style: const TextStyle(color: Colors.red)))),
        const SizedBox(height: 32),
      ],
    );
  }
"""
            # find where the `    );` ends before `String _warrantyStatus`
            build_end = content.rfind("    );\n  }", start_idx, end_idx) + 11
            
            content = content[:start_idx] + new_settings + "\n" + content[end_idx:]
            
            # also append the classes
            content += """
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});
  final String title;
  final List<_SettingsItem> items;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary))),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  leading: Icon(items[i].icon),
                  title: Text(items[i].title),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: items[i].onTap,
                ),
                if (i < items.length - 1) const Divider(height: 1, indent: 56),
              ]
            ]
          )
        )
      ]
    );
  }
}
class _SettingsItem { const _SettingsItem(this.title, this.icon, this.onTap); final String title; final IconData icon; final VoidCallback onTap; }
"""
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)

rewrite_settings()
print("Settings rewritten.")
