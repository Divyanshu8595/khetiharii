import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khetiharii/models/crop_listing.dart';
import 'package:khetiharii/models/marketplace_order.dart';

void main() {
  group('CropListing', () {
    final createdAt = DateTime.utc(2026, 1, 2);

    test('serializes and restores a listing', () {
      final listing = CropListing(
        id: 'listing-1',
        farmerId: 'farmer-1',
        farmerName: 'A Farmer',
        cropName: 'Wheat',
        variety: 'HD-2967',
        description: 'Clean grain',
        quantity: 12,
        unit: 'quintal',
        pricePerUnit: 2400,
        village: 'Rampur',
        district: 'Gorakhpur',
        state: 'Uttar Pradesh',
        createdAt: createdAt,
      );

      final restored = CropListing.fromMap('listing-1', listing.toMap());

      expect(restored.cropName, 'Wheat');
      expect(restored.cropName, 'Wheat');
      expect(restored.totalValue, 28800);
      expect(restored.createdAt, createdAt);
      expect(restored.status, ListingStatus.active);
    });
  });

  group('MarketplaceOrder', () {
    test('parses persisted order status and totals', () {
      final order = MarketplaceOrder.fromMap('order-1', {
        'listingId': 'listing-1',
        'buyerId': 'buyer-1',
        'farmerId': 'farmer-1',
        'cropName': 'Rice',
        'quantity': 5,
        'unit': 'quintal',
        'unitPrice': 2100,
        'totalPrice': 10500,
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
      });

      expect(order.status, OrderStatus.accepted);
      expect(order.totalPrice, 10500);
      expect(order.quantity, 5);
    });
  });
}
