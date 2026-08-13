import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/listing_details.dart';

Map<String, String> listing({String? expiryDate}) => {
      'name': 'Vegetable Soup',
      'category': 'Cooked Meals',
      'quantity': '2 containers',
      'location': 'Community Centre',
      'description': 'Fresh soup',
      'donor_name': 'Sarah Lee',
      'status': 'Available',
      if (expiryDate != null) 'expiry_date': expiryDate,
    };

void main() {
  testWidgets('displays a provided expiry date', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FoodListingDetailsPage(
          listing: listing(expiryDate: '2026-12-31'),
        ),
      ),
    );

    expect(find.text('Expiry Date'), findsOneWidget);
    expect(find.text('December 31, 2026'), findsOneWidget);
  });

  testWidgets('displays Not specified when expiry date is missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FoodListingDetailsPage(listing: listing()),
      ),
    );

    expect(find.text('Expiry Date'), findsOneWidget);
    expect(find.text('Not specified'), findsOneWidget);
  });
}
