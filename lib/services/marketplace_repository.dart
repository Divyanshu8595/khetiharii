import '../models/crop_listing.dart';
import '../models/marketplace_order.dart';

abstract interface class MarketplaceRepository {
  Stream<List<CropListing>> watchActiveListings({String? search});
  Future<void> createListing(CropListing listing);
  Future<void> placeOrder({
    required CropListing listing,
    required String buyerId,
    required double quantity,
  });
  Stream<List<MarketplaceOrder>> watchOrdersForUser(String uid);
  Stream<List<MarketplaceOrder>> watchOrdersForFarmer(String uid);
  Future<void> updateOrderStatus({
    required String orderId,
    required String farmerId,
    required String status,
  });
}
