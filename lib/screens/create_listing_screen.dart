import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/crop_listing.dart';
import '../services/firestore_marketplace_repository.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _crop = TextEditingController();
  final _variety = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _village = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  String _unit = 'quintal';
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_crop, _variety, _description, _quantity, _price, _village, _district, _state]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _positive(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number <= 0 ? 'Enter a number greater than zero' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await FirestoreMarketplaceRepository().createListing(CropListing(
        id: '',
        farmerId: user.uid,
        farmerName: user.displayName ?? 'Farmer',
        cropName: _crop.text.trim(),
        variety: _variety.text.trim(),
        description: _description.text.trim(),
        quantity: double.parse(_quantity.text),
        unit: _unit,
        pricePerUnit: double.parse(_price.text),
        village: _village.text.trim(),
        district: _district.text.trim(),
        state: _state.text.trim(),
        createdAt: DateTime.now(),
      ));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not publish listing: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sell your crop')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Crop details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(controller: _crop, decoration: const InputDecoration(labelText: 'Crop name', hintText: 'e.g. Wheat'), validator: _required),
          TextFormField(controller: _variety, decoration: const InputDecoration(labelText: 'Variety (optional)')),
          TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description', hintText: 'Quality, harvest date, etc.'), maxLines: 3),
          const SizedBox(height: 16),
          Text('Quantity and price', style: Theme.of(context).textTheme.titleLarge),
          TextFormField(controller: _quantity, decoration: InputDecoration(labelText: 'Available quantity ($_unit)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: _positive),
          DropdownButtonFormField<String>(
            value: _unit,
            decoration: const InputDecoration(labelText: 'Selling unit'),
            items: const ['quintal', 'kg', 'tonne', 'bag'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            onChanged: (value) => setState(() => _unit = value ?? 'quintal'),
          ),
          TextFormField(controller: _price, decoration: InputDecoration(labelText: 'Price per $_unit (₹)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: _positive),
          const SizedBox(height: 16),
          Text('Pickup location', style: Theme.of(context).textTheme.titleLarge),
          TextFormField(controller: _village, decoration: const InputDecoration(labelText: 'Village / town'), validator: _required),
          TextFormField(controller: _district, decoration: const InputDecoration(labelText: 'District'), validator: _required),
          TextFormField(controller: _state, decoration: const InputDecoration(labelText: 'State'), validator: _required),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: _saving ? null : _submit, icon: const Icon(Icons.publish), label: Text(_saving ? 'Publishing…' : 'Publish crop listing')),
        ],
      ),
    ),
  );
}
