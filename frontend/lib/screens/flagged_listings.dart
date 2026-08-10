import 'package:flutter/material.dart';
import 'listing_details.dart';

class FlaggedListingsPage extends StatelessWidget {
  const FlaggedListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> flaggedListings = [
      {
        "title": "Expired Bread",
        "reportedBy": "John Doe",
        "reason": "Expired food listed",
        "status": "Pending",
      },
      {
        "title": "Spoiled Vegetables",
        "reportedBy": "Sarah Lee",
        "reason": "Unsafe food",
        "status": "Under Review",
      },
      {
        "title": "Duplicate Listing",
        "reportedBy": "Michael Smith",
        "reason": "Spam Listing",
        "status": "Resolved",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flagged Listings"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    listing["title"]!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 19,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Reported By: ${listing["reportedBy"]}",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        size: 19,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Reason: ${listing["reason"]}",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 19,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Status: ${listing["status"]}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ListingDetailsPage(
                                    listing: listing,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          Icons.visibility,
                        ),
                        label: const Text("Review"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton.icon(
                        onPressed: () {
                          _showRemoveDialog(
                            context,
                            listing["title"]!,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          Icons.delete,
                        ),
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

  void _showRemoveDialog(
      BuildContext context,
      String title,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Listing"),
          content: Text(
            "Are you sure you want to remove \"$title\"?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Listing removal request submitted.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }
}