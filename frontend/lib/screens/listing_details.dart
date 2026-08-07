import 'package:flutter/material.dart';

class ListingDetailsScreen extends StatelessWidget {
  final Map<String, String> foodItem;

  const ListingDetailsScreen({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    final name = foodItem['name'] ?? 'Unnamed food';
    final category = foodItem['category'] ?? 'Other';
    final quantity = foodItem['quantity'] ?? 'Not provided';
    final location = foodItem['location'] ?? 'Not provided';
    final description = foodItem['description'] ?? '';
    final status = foodItem['status'] ?? 'Available';
    final donorName = foodItem['donor_name'] ?? 'Unknown donor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _buildDetailRow(
                Icons.category,
                'Category',
                category,
              ),
              _buildDetailRow(
                Icons.inventory_2,
                'Quantity',
                quantity,
              ),
              _buildDetailRow(
                Icons.location_on,
                'Pickup Location',
                location,
              ),
              _buildDetailRow(
                Icons.person,
                'Donor',
                donorName,
              ),
              _buildDetailRow(
                Icons.info_outline,
                'Status',
                status,
              ),

              const SizedBox(height: 24),

              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  description.isEmpty
                      ? 'No description provided.'
                      : description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}