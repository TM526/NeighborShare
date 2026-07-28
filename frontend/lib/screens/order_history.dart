import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
const OrderHistoryPage({super.key});

@override
Widget build(BuildContext context) {
final List<Map<String, String>> orders = [
{
"id": "#1001",
"donor": "John Doe",
"recipient": "Sarah Johnson",
"food": "Fresh Vegetables",
"date": "July 26, 2026",
"status": "Completed",
},
{
"id": "#1002",
"donor": "Emily Davis",
"recipient": "Michael Smith",
"food": "Bread & Pastries",
"date": "July 25, 2026",
"status": "Completed",
},
{
"id": "#1003",
"donor": "David Wilson",
"recipient": "Olivia Brown",
"food": "Rice & Beans",
"date": "July 24, 2026",
"status": "Pending",
},
{
"id": "#1004",
"donor": "Sophia Taylor",
"recipient": "James Miller",
"food": "Fruit Basket",
"date": "July 23, 2026",
"status": "Cancelled",
},
];

return Scaffold(
appBar: AppBar(
title: const Text("Order History"),
backgroundColor: Colors.green,
),
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: orders.length,
itemBuilder: (context, index) {
final order = orders[index];

Color statusColor;

switch (order["status"]) {
case "Completed":
statusColor = Colors.green;
break;
case "Pending":
statusColor = Colors.orange;
break;
default:
statusColor = Colors.red;
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
order["id"]!,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const Divider(height: 20),
Text("Donor: ${order["donor"]}"),
Text("Recipient: ${order["recipient"]}"),
Text("Food Item: ${order["food"]}"),
Text("Date: ${order["date"]}"),
const SizedBox(height: 12),
Row(
children: [
const Text(
"Status:",
style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(width: 8),
Chip(
label: Text(order["status"]!),
backgroundColor: statusColor.withOpacity(0.15),
labelStyle: TextStyle(color: statusColor),
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
