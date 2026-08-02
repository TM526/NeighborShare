import 'package:flutter/material.dart';

class UserInformationPage extends StatelessWidget {
const UserInformationPage({super.key});

@override
Widget build(BuildContext context) {
final List<Map<String, String>> users = [
{
"name": "John Doe",
"role": "Donor",
"email": "john@example.com",
"status": "Active",
},
{
"name": "Sarah Johnson",
"role": "Recipient",
"email": "sarah@example.com",
"status": "Active",
},
{
"name": "Michael Smith",
"role": "Donor",
"email": "michael@example.com",
"status": "Suspended",
},
{
"name": "Emily Davis",
"role": "Recipient",
"email": "emily@example.com",
"status": "Pending",
},
];

return Scaffold(
appBar: AppBar(
title: const Text("User Information"),
backgroundColor: Colors.green,
),
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: users.length,
itemBuilder: (context, index) {
final user = users[index];

return Card(
elevation: 4,
margin: const EdgeInsets.only(bottom: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Row(
children: [
const CircleAvatar(
radius: 28,
backgroundColor: Colors.green,
child: Icon(
Icons.person,
color: Colors.white,
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
user["name"]!,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
Text(user["email"]!),
const SizedBox(height: 4),
Text("Role: ${user["role"]}"),
Text("Status: ${user["status"]}"),
],
),
),
],
),
const SizedBox(height: 20),
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
ElevatedButton.icon(
onPressed: () {},
icon: const Icon(Icons.warning_amber),
label: const Text("Warn"),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.orange,
),
),
const SizedBox(width: 10),
ElevatedButton.icon(
onPressed: () {},
icon: const Icon(Icons.block),
label: const Text("Ban"),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
),
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

