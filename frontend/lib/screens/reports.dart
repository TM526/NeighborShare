import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
const ReportsPage({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Reports"),
backgroundColor: Colors.green,
),
body: Padding(
padding: const EdgeInsets.all(20),
child: ListView(
children: [
_reportCard(
"Daily Activity Report",
"View platform activity for today.",
Icons.today,
Colors.blue,
),
_reportCard(
"Weekly Report",
"Summary of weekly donations and requests.",
Icons.calendar_view_week,
Colors.orange,
),
_reportCard(
"Monthly Report",
"Monthly statistics and analytics.",
Icons.calendar_month,
Colors.green,
),
_reportCard(
"Donation Report",
"Track food donations across the platform.",
Icons.volunteer_activism,
Colors.red,
),
_reportCard(
"User Report",
"Review user registrations and activities.",
Icons.people,
Colors.purple,
),
_reportCard(
"Flagged Listings Report",
"Review listings reported by users.",
Icons.flag,
Colors.deepOrange,
),
],
),
),
);
}

Widget _reportCard(
String title,
String subtitle,
IconData icon,
Color color,
) {
return Card(
margin: const EdgeInsets.only(bottom: 16),
elevation: 4,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: ListTile(
contentPadding: const EdgeInsets.all(18),
leading: CircleAvatar(
backgroundColor: color.withOpacity(.15),
child: Icon(
icon,
color: color,
),
),
title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: Padding(
padding: const EdgeInsets.only(top: 6),
child: Text(subtitle),
),
trailing: const Icon(Icons.arrow_forward_ios),
),
);
}
}
