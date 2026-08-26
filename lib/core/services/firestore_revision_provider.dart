import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits one lightweight revision whenever Firestore has synchronized all
/// active listeners. The actual collection listeners live in FirestoreHomeStore;
/// this provider must not duplicate those queries just to trigger Riverpod.
final firestoreRevisionProvider = StreamProvider<int>((ref) {
  var revision = 0;
  return FirebaseFirestore.instance.snapshotsInSync().map((_) => ++revision);
});
