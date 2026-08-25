import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_models.dart';
import 'local_repositories.dart';
import 'repositories.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => _LocalServiceRepository(ref.watch(localStoreProvider)),
);

final warrantyRepositoryProvider = Provider<WarrantyRepository>(
  (ref) => _LocalWarrantyRepository(ref.watch(localStoreProvider)),
);

final familyRepositoryProvider = Provider<FamilyRepository>(
  (ref) => _LocalFamilyRepository(ref.watch(localStoreProvider)),
);

final homesProvider = Provider<List<HomeProfile>>(
  (ref) => ref.watch(homeRepositoryProvider).watchHomes(),
);

final locationsProvider = Provider<List<LocationArea>>(
  (ref) => ref.watch(homeRepositoryProvider).watchLocations(),
);

final servicesProvider = Provider<List<ServicePlan>>(
  (ref) => ref.watch(serviceRepositoryProvider).watchServices(),
);

final warrantiesProvider = Provider<List<Warranty>>(
  (ref) => ref.watch(warrantyRepositoryProvider).watchWarranties(),
);

final familyProvider = Provider<List<FamilyMember>>(
  (ref) => ref.watch(familyRepositoryProvider).watchFamily(),
);

class _LocalServiceRepository implements ServiceRepository {
  _LocalServiceRepository(this.store);
  final LocalHomeStore store;

  @override
  List<ServicePlan> watchServices() => List.unmodifiable(store.services);

  @override
  void upsertService(ServicePlan service) {
    final index = store.services.indexWhere((item) => item.id == service.id);
    if (index >= 0) {
      store.services[index] = service;
    } else {
      store.services.add(service);
    }
  }

  @override
  void deleteService(String id) => store.services.removeWhere((item) => item.id == id);

  @override
  void markServiceVisitCompleted(String id) => store.markServiceVisitCompleted(id);
}

class _LocalWarrantyRepository implements WarrantyRepository {
  _LocalWarrantyRepository(this.store);
  final LocalHomeStore store;

  @override
  List<Warranty> watchWarranties() => List.unmodifiable(store.warranties);

  @override
  void upsertWarranty(Warranty warranty) {
    final index = store.warranties.indexWhere((item) => item.id == warranty.id);
    if (index >= 0) {
      store.warranties[index] = warranty;
    } else {
      store.warranties.add(warranty);
    }
  }

  @override
  void deleteWarranty(String id) => store.warranties.removeWhere((item) => item.id == id);
}

class _LocalFamilyRepository implements FamilyRepository {
  _LocalFamilyRepository(this.store);
  final LocalHomeStore store;

  @override
  List<FamilyMember> watchFamily() => List.unmodifiable(store.family);

  @override
  void upsertFamilyMember(FamilyMember member) => store.upsertFamilyMember(member);

  @override
  void removeFamilyMember(String id) => store.removeFamilyMember(id);
}
