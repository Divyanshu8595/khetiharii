import 'package:cloud_firestore/cloud_firestore.dart';

enum ListingStatus { active, reserved, sold, archived }

class CropListing {
  const CropListing({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropName,
    required this.variety,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.village,
    required this.district,
    required this.state,
    required this.createdAt,
    this.status = ListingStatus.active,
    this.imageUrl,
  });

  final String id;
  final String farmerId;
  final String farmerName;
  final String cropName;
  final String variety;
  final String description;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String village;
  final String district;
  final String state;
  final DateTime createdAt;
  final ListingStatus status;
  final String? imageUrl;

  double get totalValue => quantity * pricePerUnit;

  Map<String, Object?> toMap() => {
        'farmerId': farmerId,
        'farmerName': farmerName,
        'cropName': cropName,
        'cropNameLower': cropName.trim().toLowerCase(),
        'variety': variety,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'village': village,
        'district': district,
        'state': state,
        'createdAt': Timestamp.fromDate(createdAt),
        'status': status.name,
        'imageUrl': imageUrl,
      };

  factory CropListing.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];
    return CropListing(
      id: id,
      farmerId: map['farmerId'] as String? ?? '',
      farmerName: map['farmerName'] as String? ?? 'Farmer',
      cropName: map['cropName'] as String? ?? '',
      variety: map['variety'] as String? ?? '',
      description: map['description'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'quintal',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0,
      village: map['village'] as String? ?? '',
      district: map['district'] as String? ?? '',
      state: map['state'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      status: ListingStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => ListingStatus.active,
      ),
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
