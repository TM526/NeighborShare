import 'package:flutter/material.dart';

class ListingDetailsPage extends StatelessWidget {
  final Map<String, String> listing;

  const ListingDetailsPage({
    super.key,
    required this.listing,
  });

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Under Review":
        return Colors.blue;
      case "Resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange.shade100;
      case "Under Review":
        return Colors.blue.shade100;
      case "Resolved":
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = listing["title"] ?? "Unknown Listing";
    final reportedBy = listing["reportedBy"] ?? "Unknown";
    final reason = listing["reason"] ?? "No reason provided";
    final status = listing["status"] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Listing Details"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Flagged Listing",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Report Information",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _informationCard(
              icon: Icons.person_outline,
              title: "Reported By",
              value: reportedBy,
            ),

            _informationCard(
              icon: Icons.warning_amber_outlined,
              title: "Reported Reason",
              value: reason,
            ),

            _informationCard(
              icon: Icons.info_outline,
              title: "Current Status",
              value: status,
              valueColor: _statusColor(status),
              backgroundColor: _statusBackground(status),
            ),

            const SizedBox(height: 25),

            const Text(
              "Moderation Actions",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // Mark Under Review
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Listing marked as under review.",
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text(
                  "Mark as Under Review",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Remove listing
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmRemoval(context, title);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                label: const Text(
                  "Remove Listing",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.shade100,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Review the reported reason carefully before taking moderation action.",
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _informationCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 27,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoval(
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

                ScaffoldMessenger.of(context).showSnackBar(
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