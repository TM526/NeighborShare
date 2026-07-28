import 'package:flutter/material.dart';

class FlaggedListingsPage extends StatelessWidget {
  const FlaggedListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> flaggedListings = [
      {
        "title": "Expired Bread",
        "reportedBy": "John Doe",
        "reason": "Expired food listed",
        "status": "Pending"
      },
      {
        "title": "Spoiled Vegetables",
        "reportedBy": "Sarah Lee",
        "reason": "Unsafe food",
        "status": "Under Review"
      },
      {
        "title": "Duplicate Listing",
        "reportedBy": "Michael Smith",
        "reason": "Spam Listing",
        "status": "Resolved"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flagged Listings"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: flaggedListings.length,
        itemBuilder: (context, index) {
          final listing = flaggedListings[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing["title"]!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Reported By: ${listing["reportedBy"]}"),
                  Text("Reason: ${listing["reason"]}"),
                  Text("Status: ${listing["status"]}"),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        icon: const Icon(Icons.visibility),
                        label: const Text("Review"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text("Remove"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}