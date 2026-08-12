import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedPeriod = "Weekly";
  Map<String, dynamic>? _summary;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await http.get(Uri.parse('$apiBaseUrl/reports/summary'));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _summary = json;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Server returned status ${resp.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshReports() {
    fetchReports();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Refreshing report data..."),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _openReport(String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$reportName report selected."),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshReports,
            tooltip: "Refresh Reports",
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
          child: RefreshIndicator(
          onRefresh: () async {
            _refreshReports();
          },
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _buildHeader(),

              const SizedBox(height: 22),

              if (_isLoading) ...[
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text("Loading report data..."),
                      ],
                    ),
                  ),
                ),
              ] else if (_error != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Error loading reports: ${_error ?? "Unknown error"}',
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                          TextButton(
                            onPressed: _refreshReports,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _buildPeriodSelector(),

                const SizedBox(height: 22),

                const Text(
                  "Platform Overview",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _buildStatisticsGrid(),

                const SizedBox(height: 28),
                const SizedBox(height: 12),
                // Recent activity (7 days)
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.calendar_view_week,
                        title: "Listings (7d)",
                        value: (_summary != null ? '${_summary!['recentListings7d'] ?? 0}' : '—'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.schedule,
                        title: "Requests (7d)",
                        value: (_summary != null ? '${_summary!['recentRequests7d'] ?? 0}' : '—'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  "Available Reports",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _buildReportCard(
                  icon: Icons.people_alt_outlined,
                  title: "User Activity Report",
                  description:
                  "View user activity and engagement across the platform.",
                  value: (_summary != null ? '${(_summary!['totalDonors'] ?? 0) + (_summary!['totalRecipients'] ?? 0)}' : '—'),
                  label: "Active Users",
                  onTap: () {
                    _openReport("User Activity");
                  },
                ),

                _buildReportCard(
                  icon: Icons.volunteer_activism_outlined,
                  title: "Listings Activity",
                  description:
                  "Review food listings created and recent listing activity.",
                  value: (_summary != null ? '${_summary!['totalListings'] ?? 0}' : '—'),
                  label: "Listings",
                  onTap: () {
                    _openReport("Listings Activity");
                  },
                ),

                _buildReportCard(
                  icon: Icons.restaurant_menu_outlined,
                  title: "Food Listing Report",
                  description:
                  "Review food listings created and their current activity.",
                  value: (_summary != null ? '${_summary!['totalListings'] ?? 0}' : '—'),
                  label: "Listings",
                  onTap: () {
                    _openReport("Food Listing");
                  },
                ),

                _buildReportCard(
                  icon: Icons.assignment_outlined,
                  title: "Request Activity Report",
                  description:
                  "Review recipient requests and request activity.",
                  value: (_summary != null ? '${_summary!['totalRequests'] ?? 0}' : '—'),
                  label: "Requests",
                  onTap: () {
                    _openReport("Request Activity");
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _refreshReports,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Refresh Report Data",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildInformationCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 42,
            color: Color(0xFF2E7D32),
          ),
          SizedBox(height: 12),
          Text(
            "Platform Reports",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Monitor platform usage, donations, users, requests, and listing activity.",
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Report Period",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _periodChip("Daily"),
              const SizedBox(width: 8),
              _periodChip("Weekly"),
              const SizedBox(width: 8),
              _periodChip("Monthly"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodChip(String period) {
    final isSelected = selectedPeriod == period;

    return ChoiceChip(
      label: Text(period),
      selected: isSelected,
      selectedColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setState(() {
          selectedPeriod = period;
        });
      },
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _statCard(
          icon: Icons.volunteer_activism,
          title: "Donors",
          value: (_summary != null ? '${_summary!['totalDonors'] ?? 0}' : '—'),
        ),
        _statCard(
          icon: Icons.people,
          title: "Users",
          value: (_summary != null ? '${(_summary!['totalDonors'] ?? 0) + (_summary!['totalRecipients'] ?? 0)}' : '—'),
        ),
        _statCard(
          icon: Icons.assignment,
          title: "Requests",
          value: (_summary != null ? '${_summary!['totalRequests'] ?? 0}' : '—'),
        ),
        _statCard(
          icon: Icons.restaurant,
          title: "Listings",
          value: (_summary != null ? '${_summary!['totalListings'] ?? 0}' : '—'),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF2E7D32),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2E7D32),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Report figures shown here are sample interface data. "
                  "They can be connected to the platform database when "
                  "the reporting backend is implemented.",
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}