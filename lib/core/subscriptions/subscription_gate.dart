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
