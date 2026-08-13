import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/inbox.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('shows API unread count and clears it after marking read',
      (WidgetTester tester) async {
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add(request.method);

      if (request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {
              'message_id': 11,
              'donor_id': 4,
              'recipient_id': 1,
              'message': 'Please confirm pickup.',
              'sent_at': '2026-01-01T10:00:00.000Z',
              'is_read': false,
            },
            {
              'message_id': 12,
              'donor_id': 4,
              'recipient_id': 1,
              'message': 'Thanks!',
              'sent_at': '2026-01-01T10:05:00.000Z',
              'is_read': false,
            },
          ]),
          200,
        );
      }

      return http.Response(
        jsonEncode({'messages': [
          {'message_id': 11, 'is_read': true},
          {'message_id': 12, 'is_read': true},
        ]}),
        200,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: InboxScreen(httpClient: client),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 unread conversation'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Donor #4'), findsOneWidget);

    await tester.tap(find.text('Donor #4'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(requests, contains('PATCH'));
    expect(find.text('1 unread conversation'), findsNothing);
    expect(find.text('2'), findsNothing);
  });
}