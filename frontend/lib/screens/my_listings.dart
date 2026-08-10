import 'package:flutter/material.dart';
import 'edit_listing.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final List<Map<String, String>> listings = [
    {
      "food": "Vegetable Soup",
      "category": "Cooked Meals",
      "quantity": "5 Portions",
      "location": "Scarborough",
      "status": "Available",
      "description": "Fresh homemade vegetable soup.",
    },
    {
      "food": "Fresh Bread",
      "category": "Bakery",
      "quantity": "12 Loaves",
      "location": "North York",
      "status": "Reserved",
      "description": "Fresh bread available for donation.",
    },
    {
      "food": "Apples",
      "category": "Fruits",
      "quantity": "20 Pieces",
      "location": "Etobicoke",
      "status": "Available",
      "description": "Fresh apples for community members.",
    },
  ];

  Future<void> _editListing(int index) async {
    final updatedListing = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditListingScreen(
          listing: Map<String, String>.from(listings[index]),
        ),
      ),
    );

    if (updatedListing != null) {
      setState(() {
        listings[index] = updatedListing;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Listing updated successfully!"),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  Future<void> _deleteListing(int index) async {
    final foodName = listings[index]["food"] ?? "this listing";

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Listing"),
          content: Text(
            "Are you sure you want to delete \"$foodName\"?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      listings.removeAt(index);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$foodName deleted successfully."),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Available":
        return Colors.green;
      case "Reserved":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case "Available":
        return Colors.green.shade100;
      case "Reserved":
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: listings.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          return _buildListingCard(index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Listings Available",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You currently have no active food listings.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create a food listing to help someone in your community.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(int index) {
    final listing = listings[index];

    final foodName = listing["food"] ?? "Food Listing";
    final category = listing["category"] ?? "Other";
    final quantity = listing["quantity"] ?? "Not specified";
    final location = listing["location"] ?? "Not specified";
    final status = listing["status"] ?? "Available";
    final description = listing["description"] ?? "";

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "Edit") {
                      _editListing(index);
                    } else if (value == "Delete") {
                      _deleteListing(index);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: "Edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 10),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "Delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 10),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // Quantity
            _infoRow(
              icon: Icons.inventory_2_outlined,
              label: "Quantity",
              value: quantity,
            ),

            const SizedBox(height: 10),

            // Location
            _infoRow(
              icon: Icons.location_on_outlined,
              label: "Location",
              value: location,
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoRow(
                icon: Icons.description_outlined,
                label: "Description",
                value: description,
              ),
            ],

            const SizedBox(height: 15),

            // Status and actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                TextButton.icon(
                  onPressed: () {
                    _editListing(index);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                ),

                const SizedBox(width: 5),

                TextButton.icon(
                  onPressed: () {
                    _deleteListing(index);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}