import 'package:flutter/material.dart';

class IncidentReportPage extends StatelessWidget {
const IncidentReportPage({super.key});

@override
Widget build(BuildContext context) {
final List<Map<String, String>> incidents = [
{
"id": "INC-001",
"title": "Inappropriate Food Listing",
"reportedBy": "Sarah Johnson",
"date": "July 26, 2026",
"status": "Open",
"description":
"A donor uploaded expired food items that violated community guidelines.",
},
{
"id": "INC-002",
"title": "Fake User Account",
"reportedBy": "Michael Smith",
"date": "July 24, 2026",
"status": "Investigating",
"description":
"A suspected fake account was reported by multiple users.",
},
{
"id": "INC-003",
"title": "Harassment Complaint",
"reportedBy": "Emily Davis",
"date": "July 22, 2026",
"status": "Resolved",
"description":
"A recipient reported receiving inappropriate messages from another user.",
},
];

return Scaffold(
appBar: AppBar(
title: const Text("Incident Reports"),
backgroundColor: Colors.green,
),
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: incidents.length,
itemBuilder: (context, index) {
final incident = incidents[index];

Color statusColor;

switch (incident["status"]) {
case "Open":
statusColor = Colors.red;
break;
case "Investigating":
statusColor = Colors.orange;
break;
default:
statusColor = Colors.green;
}

return Card(
elevation: 4,
margin: const EdgeInsets.only(bottom: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
incident["id"]!,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
incident["title"]!,
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 12),
Text("Reported By: ${incident["reportedBy"]}"),
Text("Date: ${incident["date"]}"),
const SizedBox(height: 12),
Text(
incident["description"]!,
style: const TextStyle(fontSize: 15),
),
const SizedBox(height: 16),
Row(
children: [
const Text(
"Status:",
style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(width: 8),
Chip(
label: Text(incident["status"]!),
backgroundColor: statusColor.withOpacity(0.15),
labelStyle: TextStyle(color: statusColor),
),
],
),
const SizedBox(height: 15),
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
ElevatedButton.icon(
onPressed: () {},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.orange,
),
icon: const Icon(Icons.edit),
label: const Text("Review"),
),
const SizedBox(width: 10),
ElevatedButton.icon(
onPressed: () {},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
),
icon: const Icon(Icons.check),
label: const Text("Resolve"),
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
