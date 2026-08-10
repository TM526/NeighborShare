import 'package:flutter/material.dart';

import 'donor_profile.dart';
import 'recipient_profile.dart';
import 'browse_listings.dart';
import 'create_listing.dart';
import 'my_listings.dart';
import 'admin_login.dart';
import 'notifications.dart';
import 'inbox.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _selectedIndex = 0;

  // ==========================================
  // TEMPORARY DONOR PROFILE INFORMATION
  // ==========================================

  // This will later be replaced with information
  // retrieved from the backend/database.
  final Map<String, String> _donorProfile = {
    "fullName": "John Doe",
    "email": "john@example.com",
    "phone": "4161234567",
    "streetAddress": "123 Main Street",
    "city": "Toronto",
    "postalCode": "M5V 2T6",
  };

  // ==========================================
  // TEMPORARY RECIPIENT PROFILE INFORMATION
  // ==========================================

  // This will later be replaced with information
  // retrieved from the backend/database.
  final Map<String, String> _recipientProfile = {
    "fullName": "Sarah Lee",
    "email": "sarah@example.com",
    "phone": "4169876543",
    "streetAddress": "456 Queen Street",
    "city": "Toronto",
    "postalCode": "M5V 2T6",
    "dietaryPreference": "Vegetarian",
    "allergies": "Peanuts",
  };

  // ==========================================
  // CREATE DONOR PROFILE
  // ==========================================

  void _openCreateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDonorProfileScreen(),
      ),
    );
  }

  // ==========================================
  // EDIT DONOR PROFILE
  // ==========================================

  void _openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDonorProfileScreen(
          isEditing: true,
          existingProfile: _donorProfile,
        ),
      ),
    );
  }

  // ==========================================
  // CREATE RECIPIENT PROFILE
  // ==========================================

  void _openCreateRecipientProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRecipientProfileScreen(),
      ),
    );
  }

  // ==========================================
  // EDIT RECIPIENT PROFILE
  // ==========================================

  void _openEditRecipientProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRecipientProfileScreen(
          isEditing: true,
          existingProfile: _recipientProfile,
        ),
      ),
    );
  }

  // ==========================================
  // OPEN NOTIFICATIONS
  // ==========================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  // ==========================================
  // OPEN INBOX
  // ==========================================

  void _openInbox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InboxScreen(),
      ),
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION
  // ==========================================

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Home
        break;

      case 1:
      // Profile
        _openEditProfile();
        break;

      case 2:
      // Browse Listings
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BrowseListingsScreen(),
          ),
        );
        break;

      case 3:
      // My Listings
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MyListingsScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================
      // APP BAR
      // ==========================================

      appBar: AppBar(
        title: const Text(
          "NeighbourShare",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ==========================================
          // NOTIFICATIONS BUTTON
          // ==========================================

          IconButton(
            tooltip: "Notifications",
            icon: const Icon(
              Icons.notifications_outlined,
              size: 27,
            ),
            onPressed: _openNotifications,
          ),

          // ==========================================
          // INBOX BUTTON
          // ==========================================

          IconButton(
            tooltip: "Inbox",
            icon: const Icon(
              Icons.mail_outline,
              size: 27,
            ),
            onPressed: _openInbox,
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ==========================================
      // MAIN BODY
      // ==========================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // ==========================================
              // LOGO
              // ==========================================

              const Icon(
                Icons.volunteer_activism,
                color: Color(0xFF2E7D32),
                size: 90,
              ),

              const SizedBox(height: 20),

              // ==========================================
              // WELCOME
              // ==========================================

              const Text(
                "Welcome to NeighbourShare!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Help reduce food waste by donating surplus food "
                    "or browse available food donations in your community.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 35),

              // ==========================================
              // BROWSE LISTINGS
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.search,
                  ),
                  label: const Text(
                    "Browse Listings",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF2E7D32,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const BrowseListingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // CREATE DONOR PROFILE
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.person_add,
                  ),
                  label: const Text(
                    "Create Donor Profile",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF388E3C,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: _openCreateProfile,
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // EDIT DONOR PROFILE
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  label: const Text(
                    "Edit Donor Profile",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF66BB6A,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: _openEditProfile,
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // CREATE RECIPIENT PROFILE
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.people,
                  ),
                  label: const Text(
                    "Create Recipient Profile",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF2E7D32,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: _openCreateRecipientProfile,
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // EDIT RECIPIENT PROFILE
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  label: const Text(
                    "Edit Recipient Profile",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF66BB6A,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: _openEditRecipientProfile,
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // CREATE LISTING
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.add_box,
                  ),
                  label: const Text(
                    "Create Listing",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF43A047,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const CreateListingScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // MY LISTINGS
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.list_alt,
                  ),
                  label: const Text(
                    "My Listings",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF66BB6A,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MyListingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // ADMINISTRATOR
              // ==========================================

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.admin_panel_settings,
                  ),
                  label: const Text(
                    "Administrator",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF1B5E20,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const AdminLoginScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ==========================================
      // BOTTOM NAVIGATION
      // ==========================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(
          0xFF2E7D32,
        ),
        unselectedItemColor: Colors.grey,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list_alt,
            ),
            label: "My Listings",
          ),
        ],
      ),
    );
  }
}