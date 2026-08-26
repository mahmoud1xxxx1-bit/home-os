import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_controller.dart';

final firestoreRevisionProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authControllerProvider).user?.id;
  if (uid == null || uid.isEmpty) return const Stream<int>.empty();

  final controller = StreamController<int>.broadcast();
  var revision = 0;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
  final subscriptions = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

  void signal() {
    Future<void>.delayed(Duration.zero, () {
      if (!controller.isClosed) controller.add(++revision);
    });
  }

  for (final collection in const [
    'homes',
    'locations',
    'assets',
    'maintenance',
    'reminders',
    'providers',
    'services',
    'warranties',
    'documents',
    'expenses',
    'family',
    'activity',
  ]) {
    subscriptions.add(userDoc.collection(collection).snapshots().listen((_) => signal()));
  }

  ref.onDispose(() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await controller.close();
  });

  return controller.stream;
});
