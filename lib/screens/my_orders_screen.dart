import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_order.dart';
import '../services/firestore_marketplace_repository.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final repository = FirestoreMarketplaceRepository();
    final stream = role == 'farmer'
        ? repository.watchOrdersForFarmer(uid)
        : repository.watchOrdersForUser(uid);
    return Scaffold(
      appBar: AppBar(title: Text(role == 'farmer' ? 'Crop requests' : 'My orders')),
      body: StreamBuilder<List<MarketplaceOrder>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load orders: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('No order activity yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(order.cropName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                      Chip(label: Text(order.status.name.toUpperCase())),
                    ]),
                    Text('${order.quantity} ${order.unit} × ₹${order.unitPrice.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text('Total: ₹${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (role == 'farmer' && order.status == OrderStatus.requested) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: OutlinedButton(
                          onPressed: () => repository.updateOrderStatus(orderId: order.id, farmerId: uid, status: 'rejected'),
                          child: const Text('Decline'),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: FilledButton(
                          onPressed: () => repository.updateOrderStatus(orderId: order.id, farmerId: uid, status: 'accepted'),
                          child: const Text('Accept request'),
                        )),
                      ]),
                    ],
                    if (role == 'farmer' && order.status == OrderStatus.accepted) ...[
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: FilledButton(
                        onPressed: () => repository.updateOrderStatus(orderId: order.id, farmerId: uid, status: 'completed'),
                        child: const Text('Mark completed'),
                      )),
                    ],
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
