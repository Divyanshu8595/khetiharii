import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { requested, accepted, rejected, completed, cancelled }

class MarketplaceOrder {
  const MarketplaceOrder({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.farmerId,
    required this.cropName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String farmerId;
  final String cropName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'listingId': listingId,
        'buyerId': buyerId,
        'farmerId': farmerId,
        'cropName': cropName,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory MarketplaceOrder.fromMap(String id, Map<String, dynamic> map) =>
      MarketplaceOrder(
        id: id,
        listingId: map['listingId'] as String? ?? '',
        buyerId: map['buyerId'] as String? ?? '',
        farmerId: map['farmerId'] as String? ?? '',
        cropName: map['cropName'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] as String? ?? 'quintal',
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
        totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
        status: OrderStatus.values.firstWhere(
          (value) => value.name == map['status'],
          orElse: () => OrderStatus.requested,
        ),
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
