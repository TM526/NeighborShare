import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
const FeedbackPage({super.key});

@override
Widget build(BuildContext context) {
final List<Map<String, dynamic>> feedbackList = [
{
"name": "John Doe",
"rating": 5,
"comment":
"Excellent platform! It helped me donate food quickly and easily.",
"date": "July 25, 2026",
},
{
"name": "Sarah Johnson",
"rating": 4,
"comment":
"Very helpful application. I received food assistance on time.",
"date": "July 24, 2026",
},
{
"name": "Michael Smith",
"rating": 3,
"comment":
"Good platform, but the notification system could be improved.",
"date": "July 22, 2026",
},
{
"name": "Emily Davis",
"rating": 5,
"comment":
"Simple, user-friendly, and makes food sharing much easier.",
"date": "July 20, 2026",
},
];

return Scaffold(
appBar: AppBar(
title: const Text("User Feedback"),
backgroundColor: Colors.green,
),
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: feedbackList.length,
itemBuilder: (context, index) {
final feedback = feedbackList[index];

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
Row(
children: [
const CircleAvatar(
radius: 25,
backgroundColor: Colors.green,
child: Icon(
Icons.person,
color: Colors.white,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
feedback["name"],
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
],
),
const SizedBox(height: 12),
Row(
children: List.generate(
feedback["rating"],
(index) => const Icon(
Icons.star,
color: Colors.amber,
size: 22,
),
),
),
const SizedBox(height: 10),
Text(
feedback["comment"],
style: const TextStyle(fontSize: 15),
),
const SizedBox(height: 12),
Align(
alignment: Alignment.bottomRight,
child: Text(
feedback["date"],
style: const TextStyle(
color: Colors.grey,
fontStyle: FontStyle.italic,
),
),
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