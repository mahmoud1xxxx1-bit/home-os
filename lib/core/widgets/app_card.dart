import 'package:flutter/material.dart';

class AppCard extends StatefulWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    if (widget.onTap != null) {
      _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
      _scale = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() { 
    _ctrl?.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: widget.padding ?? const EdgeInsets.all(20), child: widget.child);
    if (widget.onTap == null || _ctrl == null) return Card(child: content);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl!.forward(),
      onExit: (_) => _ctrl!.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _ctrl!.forward(),
        onTapUp: (_) { _ctrl!.reverse(); widget.onTap!(); },
        onTapCancel: () => _ctrl!.reverse(),
        child: ScaleTransition(
          scale: _scale!,
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
