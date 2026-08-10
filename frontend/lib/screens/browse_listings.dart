import 'package:flutter/material.dart';
import 'request_food.dart';

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Cooked Meals",
    "Bakery",
    "Fruits",
    "Vegetables",
  ];

  final List<Map<String, String>> foodListings = [
    {
      "name": "Vegetable Soup",
      "category": "Cooked Meals",
      "quantity": "5 Portions",
      "location": "Scarborough",
      "status": "Available",
    },
    {
      "name": "Fresh Bread",
      "category": "Bakery",
      "quantity": "12 Loaves",
      "location": "North York",
      "status": "Available",
    },
    {
      "name": "Apples",
      "category": "Fruits",
      "quantity": "20 Pieces",
      "location": "Etobicoke",
      "status": "Available",
    },
    {
      "name": "Carrots",
      "category": "Vegetables",
      "quantity": "8 Bags",
      "location": "Downtown Toronto",
      "status": "Reserved",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _requestFood(Map<String, String> food) {
    if (food["status"] != "Available") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "This food listing is no longer available.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestFoodScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = foodListings.where((food) {
      final matchesSearch = food["name"]!
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());

      final matchesCategory =
          selectedCategory == "All" ||
              food["category"] == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Listings"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Browse Food Listings",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Find available food donations near you and request items that meet your needs.",
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search food...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            // Categories
            SizedBox(
              height: 45,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor:
                      const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Listings
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final food = filtered[index];

                  return _buildFoodCard(food);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(Map<String, String> food) {
    final isAvailable = food["status"] == "Available";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food title
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        food["name"]!,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        food["category"]!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    food["status"]!,
                    style: TextStyle(
                      color: isAvailable
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // Quantity
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 10),
                Text(
                  "Quantity: ${food["quantity"]}",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Location: ${food["location"]}",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Request button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isAvailable
                    ? () => _requestFood(food)
                    : null,
                icon: const Icon(Icons.volunteer_activism),
                label: Text(
                  isAvailable
                      ? "Request Food"
                      : "Listing Reserved",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  Colors.grey.shade300,
                  disabledForegroundColor:
                  Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Listings Found",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Try another search term or category.",
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
}