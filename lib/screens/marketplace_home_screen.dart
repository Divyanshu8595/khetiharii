import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/crop_listing.dart';
import '../services/auth_service.dart';
import '../services/firestore_marketplace_repository.dart';
import 'my_orders_screen.dart';
import 'create_listing_screen.dart';

class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  final _repository = FirestoreMarketplaceRepository();
  final _search = TextEditingController();
  String _term = '';
  String _role = 'buyer';

  @override
  void initState() {
    super.initState();
    _loadRole();
    _search.addListener(() {
      final value = _search.text.trim();
      if (value != _term) setState(() => _term = value);
    });
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (mounted) setState(() => _role = doc.data()?['role'] as String? ?? 'buyer');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CropListing listing) async {
    final quantityController = TextEditingController();
    final quantity = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request ${listing.cropName}'),
        content: TextField(
          controller: quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Quantity (${listing.unit})', helperText: 'Available: ${listing.quantity} ${listing.unit}'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, double.tryParse(quantityController.text)), child: const Text('Continue')),
        ],
      ),
    );
    quantityController.dispose();
    if (quantity == null || quantity <= 0) return;
    try {
      await _repository.placeOrder(listing: listing, buyerId: FirebaseAuth.instance.currentUser!.uid, quantity: quantity);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order request sent to the farmer.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order could not be placed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khetiharii Market'),
        actions: [
          IconButton(tooltip: 'My orders', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyOrdersScreen(role: _role))), icon: const Icon(Icons.receipt_long)),
          IconButton(tooltip: 'Sign out', onPressed: () => AuthService().signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: _role == 'farmer' ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateListingScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Sell crop'),
      ) : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good to see you, ${user.displayName ?? 'there'}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('Find fresh produce directly from farmers.'),
              const SizedBox(height: 12),
              TextField(controller: _search, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search crops (e.g. wheat, rice)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            ]),
          ),
          Expanded(
            child: StreamBuilder<List<CropListing>>(
              stream: _repository.watchActiveListings(search: _term.isEmpty ? null : _term),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not load listings. Check Firestore setup and indexes.\n${snapshot.error}', textAlign: TextAlign.center)));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final listings = snapshot.data!;
                if (listings.isEmpty) return const Center(child: Text('No crop listings yet. Try another search or check back soon.'));
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: listings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = listings[index];
                    final isOwner = item.farmerId == user.uid;
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(Icons.grass, color: Colors.green.shade800)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.cropName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('${item.variety.isEmpty ? 'Local variety' : item.variety} · ${item.farmerName}'),
                            ])),
                            Text('₹${item.pricePerUnit.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                          ]),
                          const SizedBox(height: 12),
                          Text('${item.quantity} ${item.unit} available · per ${item.unit}'),
                          const SizedBox(height: 4),
                          Text('${item.village}, ${item.district}, ${item.state}', style: Theme.of(context).textTheme.bodySmall),
                          if (item.description.isNotEmpty) ...[const SizedBox(height: 8), Text(item.description)],
                          if (_role == 'buyer' && !isOwner) ...[
                            const SizedBox(height: 12),
                            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _placeOrder(item), child: const Text('Request to buy'))),
                          ],
                          if (isOwner) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Your listing', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
