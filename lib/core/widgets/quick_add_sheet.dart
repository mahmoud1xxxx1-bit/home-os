import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
void showQuickAddSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final items = [
    (l10n.addAsset, Icons.devices_other_rounded, () => context.push('/asset/new')),
    (l10n.addVehicle, Icons.directions_car_rounded, () => context.push('/asset/new?vehicle=true')),
    (l10n.addMaintenance, Icons.handyman_rounded, () => _notice(context, l10n.addMaintenance)),
    (l10n.addReminder, Icons.notifications_active_rounded, () => _notice(context, l10n.addReminder)),
    (l10n.addDocument, Icons.description_rounded, () => _notice(context, l10n.addDocument)),
    (l10n.addService, Icons.cleaning_services_rounded, () => _notice(context, l10n.addService)),
    (l10n.addExpense, Icons.payments_rounded, () => _notice(context, l10n.addExpense)),
  ];
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.quickAdd, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 520 ? 4 : 2,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: [
                for (final item in items)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      item.$3();
                    },
                    icon: Icon(item.$2),
                    label: Text(item.$1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _notice(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
}
