import os

def update_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

# 1. Update AppTheme for Calm Premium
app_theme = """import 'package:flutter/material.dart';

class AppTheme {
  static const _radius = 24.0;
  static const _seed = Color(0xFF2C5E7A); // Calm premium blue/teal
  static const _accent = Color(0xFFD99058); // Premium bronze/gold accent

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      secondary: _accent,
      brightness: Brightness.light,
      surface: const Color(0xFFFCFBF9),
      surfaceContainerHigh: const Color(0xFFFFFFFF),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F2EE),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      secondary: _accent,
      brightness: Brightness.dark,
      surface: const Color(0xFF14161A),
      surfaceContainerHigh: const Color(0xFF1C1F26),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B0C0E),
      cardColor: const Color(0xFF14161A),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      typography: Typography.material2021(colorScheme: scheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: scheme.onSurface, letterSpacing: -0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
        space: 32,
      ),
    );
  }
}
"""
update_file('lib/core/theme/app_theme.dart', app_theme)

# 2. Update AppCard & InfoTip with Animations
app_card = """import 'package:flutter/material.dart';

class AppCard extends StatefulWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: widget.padding ?? const EdgeInsets.all(20), child: widget.child);
    if (widget.onTap == null) return Card(child: content);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap!(); },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shadowColor: Colors.black12,
            child: content,
          ),
        ),
      ),
    );
  }
}

class InfoTip extends StatelessWidget {
  const InfoTip({super.key, required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: title,
      icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, required this.actionLabel, required this.onAction});
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.add_rounded), label: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, this.color, {super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
"""
update_file('lib/core/widgets/app_card.dart', app_card)

# 3. Modify Settings (More Screen) to Group Items
more_screen = read_file('lib/features/settings/presentation/more_screen.dart')
import re
more_screen = re.sub(
    r'AppCard\(\s*child: Column\(\s*children: \[\s*SegmentedButton.*\]\s*\),\s*\)',
    r"""
        _SettingsGroup(title: lang == 'ar' ? 'الحساب' : 'Account', items: [
            _SettingsItem(lang == 'ar' ? 'الحساب الشخصي' : 'Profile', Icons.person_outline_rounded),
            _SettingsItem(lang == 'ar' ? 'أمان الحساب' : 'Security', Icons.shield_outlined),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'المظهر والتفضيلات' : 'Appearance & Preferences', items: [
            _SettingsItem(lang == 'ar' ? 'السمة (فاتح/داكن)' : 'Theme (Light/Dark)', Icons.palette_outlined),
            _SettingsItem(lang == 'ar' ? 'اللغة' : 'Language', Icons.language_rounded),
            _SettingsItem(lang == 'ar' ? 'الإشعارات' : 'Notifications', Icons.notifications_outlined),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'البيانات' : 'Data', items: [
            _SettingsItem(lang == 'ar' ? 'تصدير البيانات' : 'Export Data', Icons.download_rounded),
            _SettingsItem(lang == 'ar' ? 'إدارة المساحة' : 'Storage Management', Icons.storage_rounded),
        ]),
        _SettingsGroup(title: lang == 'ar' ? 'حول' : 'About', items: [
            _SettingsItem(lang == 'ar' ? 'مركز المساعدة' : 'Help Center', Icons.help_outline_rounded),
            _SettingsItem(lang == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy', Icons.privacy_tip_outlined),
        ]),
        const SizedBox(height: 16),
        Center(child: TextButton(onPressed: (){}, child: Text(lang == 'ar' ? 'تسجيل الخروج' : 'Log out', style: TextStyle(color: Colors.red)))),
        const SizedBox(height: 32),
    """, more_screen, flags=re.DOTALL)
more_screen += """
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
                  onTap: () {},
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
class _SettingsItem { const _SettingsItem(this.title, this.icon); final String title; final IconData icon; }
"""
update_file('lib/features/settings/presentation/more_screen.dart', more_screen)

print("Redesign applied.")
