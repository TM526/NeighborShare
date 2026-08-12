import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/screens/recipient_dashboard.dart';
import 'package:frontend/screens/donor_dashboard.dart';

void main() {
  testWidgets('Recipient: status changes from Pending to Approved update UI',
      (WidgetTester tester) async {
    var callCount = 0;

    final client = MockClient((request) async {
      callCount++;
      if (callCount == 1) {
        // Initial load: Pending
        return http.Response(
          jsonEncode([
            {
              'request_id': 1,
              'food_name': 'Vegetable Soup',
              'request_status': 'Pending'
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      // Subsequent load: Approved
      return http.Response(
        jsonEncode([
          {
            'request_id': 1,
            'food_name': 'Vegetable Soup',
            'request_status': 'Approved'
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipientDashboardScreen(recipientId: 1, httpClient: client),
    ));

    await tester.pumpAndSettle();

    // Initially shows Pending chip
    expect(find.text('Pending'), findsOneWidget);

    // Tap the refresh button to fetch updated status
    final Finder refresh = find.byTooltip('Refresh requests');
    expect(refresh, findsOneWidget);
    await tester.tap(refresh);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Now should show Approved and not Pending
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Pending'), findsNothing);
    expect(find.text('Your food request was approved.'), findsOneWidget);
  });

  testWidgets('Recipient: status changes from Pending to Rejected update UI',
      (WidgetTester tester) async {
    var callCount = 0;

    final client = MockClient((request) async {
      callCount++;
      if (callCount == 1) {
        return http.Response(
          jsonEncode([
            {
              'request_id': 2,
              'food_name': 'Fresh Bread',
              'request_status': 'Pending'
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response(
        jsonEncode([
          {
            'request_id': 2,
            'food_name': 'Fresh Bread',
            'request_status': 'Rejected'
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipientDashboardScreen(recipientId: 1, httpClient: client),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Pending'), findsOneWidget);

    await tester.tap(find.byTooltip('Refresh requests'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Rejected'), findsOneWidget);
    expect(find.text('Pending'), findsNothing);
    expect(find.text('Your food request was rejected.'), findsOneWidget);
  });

  testWidgets('Recipient: unchanged status does not show a repeated notification',
      (WidgetTester tester) async {
    var callCount = 0;

    final client = MockClient((request) async {
      callCount++;
      return http.Response(
        jsonEncode([
          {
            'request_id': 4,
            'food_name': 'Rice',
            'request_status': callCount == 1 ? 'Pending' : 'Pending'
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipientDashboardScreen(recipientId: 1, httpClient: client),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Refresh requests'));
    await tester.pumpAndSettle();

    expect(find.text('Your food request was approved.'), findsNothing);
    expect(find.text('Your food request was rejected.'), findsNothing);
  });

  testWidgets('Recipient: initial status does not show a change notification',
      (WidgetTester tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'request_id': 5,
            'food_name': 'Apples',
            'request_status': 'Approved'
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipientDashboardScreen(recipientId: 1, httpClient: client),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Your food request was approved.'), findsNothing);
    expect(find.text('Your food request was rejected.'), findsNothing);
  });

  testWidgets('Donor: new pending request shows in-app notification',
      (WidgetTester tester) async {
    var callCount = 0;

    final client = MockClient((request) async {
      callCount++;
      // First call: baseline (empty list)
      if (callCount == 1) {
        return http.Response(jsonEncode([]), 200,
            headers: {'content-type': 'application/json'});
      }

      // Subsequent calls: one pending request
      return http.Response(
        jsonEncode([
          {
            'request_id': 10,
            'recipient_name': 'Alex',
            'food_name': 'Canned Beans',
            'quantity': '1 pack',
            'message': 'Please',
            'request_status': 'Pending'
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    // First pump: baseline — no notification should be shown
    await tester.pumpWidget(MaterialApp(
      home: DonorDashboardScreen(accountId: 1, httpClient: client),
    ));

    await tester.pumpAndSettle();

    expect(find.text('NEW FOOD REQUEST'), findsNothing);

    // Recreate the widget (module-level baseline will now be set)
    await tester.pumpWidget(Container());
    await tester.pumpWidget(MaterialApp(
      home: DonorDashboardScreen(accountId: 1, httpClient: client),
    ));

    await tester.pumpAndSettle();

    // After second initialization, new pending request should trigger notification
    expect(find.text('NEW FOOD REQUEST'), findsOneWidget);
  });

  testWidgets('Recipient: API failure does not crash and shows error message',
      (WidgetTester tester) async {
    var callCount = 0;

    final client = MockClient((request) async {
      callCount++;
      if (callCount == 1) {
        return http.Response(
          jsonEncode([
            {'request_id': 3, 'food_name': 'Salad', 'request_status': 'Pending'}
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      // Simulate server error / unavailable on subsequent fetch
      return http.Response('Server error', 500);
    });

    await tester.pumpWidget(MaterialApp(
      home: RecipientDashboardScreen(recipientId: 1, httpClient: client),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Pending'), findsOneWidget);

    // Tap refresh which will hit the 500 response
    await tester.tap(find.byTooltip('Refresh requests'));
    await tester.pumpAndSettle();

    // Error message shown and app remains responsive
    expect(find.text('Unable to load your requests.'), findsWidgets);
  });
}
