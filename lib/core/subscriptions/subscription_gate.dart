import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'subscription_providers.dart';

bool ensureSubscriptionAccess(BuildContext context, WidgetRef ref, LimitedResource resource) {
  final decision = ref.read(accessDecisionProvider(resource));
  if (decision.allowed) return true;

  final reason = Uri.encodeQueryComponent(decision.reasonKey ?? 'free_limit_reached');
  context.push('/upgrade?reason=$reason');
  return false;
}

bool ensureHomeAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.home);
bool ensureAssetAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.asset);
bool ensureReminderAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.reminder);
bool ensureMaintenanceAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.maintenance);
bool ensureWarrantyAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.warranty);
bool ensureDocumentAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.document);
bool ensureProviderAccess(BuildContext context, WidgetRef ref) => ensureSubscriptionAccess(context, ref, LimitedResource.provider);
