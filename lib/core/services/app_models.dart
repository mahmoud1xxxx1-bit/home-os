enum AssetCategory { appliance, hvac, kitchen, outdoor, vehicle, other }

enum ReminderType { oneTime, recurring, expiry, usageBased }

enum AlertOffset { sameDay, oneDay, threeDays, sevenDays, thirtyDays, custom }

enum WarrantyStatus { valid, expiringSoon, expired }

enum FamilyRole { owner, admin, member, viewer, limited }

class LocalizedText {
  const LocalizedText({required this.ar, required this.en});

  final String ar;
  final String en;

  String value(String languageCode) => languageCode == 'ar' ? ar : en;
}

class HomeProfile {
  const HomeProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText type;
  final DateTime createdAt;
}

class LocationArea {
  const LocationArea({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final LocalizedText name;
  final String icon;
}

class HomeAsset {
  const HomeAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.locationId,
    this.image,
    this.brand,
    this.model,
    this.serialNumber,
    this.purchaseDate,
    this.purchasePrice,
    this.installationDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.vehicle,
  });

  final String id;
  final LocalizedText name;
  final AssetCategory category;
  final String locationId;
  final String? image;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime? installationDate;
  final LocalizedText? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final VehicleDetails? vehicle;

  HomeAsset copyWith({
    String? id,
    LocalizedText? name,
    AssetCategory? category,
    String? locationId,
    String? image,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchaseDate,
    double? purchasePrice,
    DateTime? installationDate,
    LocalizedText? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    VehicleDetails? vehicle,
  }) {
    return HomeAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      locationId: locationId ?? this.locationId,
      image: image ?? this.image,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      installationDate: installationDate ?? this.installationDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

class VehicleDetails {
  const VehicleDetails({
    required this.make,
    required this.year,
    this.plateNumber,
    this.vin,
    required this.odometerKm,
    this.insuranceExpiry,
    this.inspectionExpiry,
    this.warrantyExpiry,
    this.lastMaintenance,
    this.nextDueDate,
    this.nextDueKm,
  });

  final String make;
  final int year;
  final String? plateNumber;
  final String? vin;
  final int odometerKm;
  final DateTime? insuranceExpiry;
  final DateTime? inspectionExpiry;
  final DateTime? warrantyExpiry;
  final DateTime? lastMaintenance;
  final DateTime? nextDueDate;
  final int? nextDueKm;
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.assetId,
    required this.date,
    required this.type,
    required this.description,
    required this.cost,
    this.providerId,
    this.phone,
    this.serviceWarrantyUntil,
    this.nextDue,
    this.beforeImagePlaceholder,
    this.afterImagePlaceholder,
    this.invoicePlaceholder,
    this.notes,
  });

  final String id;
  final String assetId;
  final DateTime date;
  final LocalizedText type;
  final LocalizedText description;
  final double cost;
  final String? providerId;
  final String? phone;
  final DateTime? serviceWarrantyUntil;
  final DateTime? nextDue;
  final String? beforeImagePlaceholder;
  final String? afterImagePlaceholder;
  final String? invoicePlaceholder;
  final LocalizedText? notes;
}

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.assetId,
    required this.dueDate,
    required this.alertOffset,
    this.usageKm,
    this.repeatEveryDays,
    this.isDone = false,
  });

  final String id;
  final LocalizedText title;
  final ReminderType type;
  final String? assetId;
  final DateTime dueDate;
  final AlertOffset alertOffset;
  final int? usageKm;
  final int? repeatEveryDays;
  final bool isDone;
}

class ServicePlan {
  const ServicePlan({
    required this.id,
    required this.name,
    required this.providerId,
    required this.phone,
    required this.frequency,
    required this.cost,
    required this.lastVisit,
    required this.nextVisit,
    this.notes,
  });

  final String id;
  final LocalizedText name;
  final String providerId;
  final String phone;
  final LocalizedText frequency;
  final double cost;
  final DateTime lastVisit;
  final DateTime nextVisit;
  final LocalizedText? notes;
}

class ProviderContact {
  const ProviderContact({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    required this.whatsApp,
    required this.visitCount,
    required this.totalPaid,
    required this.lastVisit,
    required this.linkedAssetIds,
    this.notes,
  });

  final String id;
  final String name;
  final LocalizedText type;
  final String phone;
  final String whatsApp;
  final int visitCount;
  final double totalPaid;
  final DateTime lastVisit;
  final List<String> linkedAssetIds;
  final LocalizedText? notes;
}

class Warranty {
  const Warranty({
    required this.id,
    required this.assetId,
    required this.start,
    required this.end,
    required this.provider,
    required this.number,
    required this.status,
    this.notes,
    this.documentPlaceholder,
  });

  final String id;
  final String assetId;
  final DateTime start;
  final DateTime end;
  final String provider;
  final String number;
  final WarrantyStatus status;
  final LocalizedText? notes;
  final String? documentPlaceholder;
}

class HomeDocument {
  const HomeDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.relatedAssetId,
    required this.createdAt,
    required this.placeholder,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText category;
  final String? relatedAssetId;
  final DateTime createdAt;
  final String placeholder;
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.assetId,
    required this.amount,
    required this.date,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText category;
  final String? assetId;
  final double amount;
  final DateTime date;
}

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });

  final String id;
  final String name;
  final FamilyRole role;
  final LocalizedText status;
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.actor,
    required this.type,
    required this.entity,
    required this.timestamp,
    required this.description,
  });

  final String id;
  final String actor;
  final LocalizedText type;
  final LocalizedText entity;
  final DateTime timestamp;
  final LocalizedText description;
}
