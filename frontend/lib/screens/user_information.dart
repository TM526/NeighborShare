import 'package:flutter/material.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() =>
      _UserInformationPageState();
}

class _UserInformationPageState
    extends State<UserInformationPage> {
  final List<Map<String, dynamic>> users = [
    {
      "name": "John Doe",
      "email": "john@example.com",
      "role": "Donor",
      "status": "Active",
    },
    {
      "name": "Sarah Lee",
      "email": "sarah@example.com",
      "role": "Recipient",
      "status": "Active",
    },
    {
      "name": "Michael Smith",
      "email": "michael@example.com",
      "role": "Donor",
      "status": "Active",
    },
    {
      "name": "Jessica Brown",
      "email": "jessica@example.com",
      "role": "Recipient",
      "status": "Active",
    },
  ];

  Future<void> _banUser(int index) async {
    final user = users[index];

    final shouldBan = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.block,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text("Ban User"),
            ],
          ),
          content: Text(
            "Are you sure you want to ban ${user["name"]}?\n\n"
                "This user will no longer be able to use the platform.",
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
              child: const Text("Ban User"),
            ),
          ],
        );
      },
    );

    if (shouldBan != true) {
      return;
    }

    setState(() {
      users[index]["status"] = "Banned";
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${user["name"]} has been banned successfully.",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _unbanUser(int index) async {
    final user = users[index];

    final shouldUnban = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Unban User"),
          content: Text(
            "Do you want to restore access for ${user["name"]}?",
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
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text("Unban User"),
            ),
          ],
        );
      },
    );

    if (shouldUnban != true) {
      return;
    }

    setState(() {
      users[index]["status"] = "Active";
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${user["name"]} has been unbanned.",
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == "Banned") {
      return Colors.red;
    }

    return Colors.green;
  }

  Color _statusBackground(String status) {
    if (status == "Banned") {
      return Colors.red.shade100;
    }

    return Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Information"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: users.isEmpty
          ? const Center(
        child: Text(
          "No users found.",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(index);
        },
      ),
    );
  }

  Widget _buildUserCard(int index) {
    final user = users[index];

    final name = user["name"] as String;
    final email = user["email"] as String;
    final role = user["role"] as String;
    final status = user["status"] as String;

    final isBanned = status == "Banned";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                  isBanned
                      ? Colors.red.shade100
                      : const Color(0xFFE8F5E9),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: isBanned
                        ? Colors.red
                        : const Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Role: $role",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
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
                    color: _statusBackground(status),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: isBanned
                  ? OutlinedButton.icon(
                onPressed: () {
                  _unbanUser(index);
                },
                icon: const Icon(
                  Icons.lock_open,
                ),
                label: const Text(
                  "Unban User",
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(0xFF2E7D32),
                  side: const BorderSide(
                    color: Color(0xFF2E7D32),
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              )
                  : ElevatedButton.icon(
                onPressed: () {
                  _banUser(index);
                },
                icon: const Icon(Icons.block),
                label: const Text(
                  "Ban User",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape:
                  RoundedRectangleBorder(
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
}