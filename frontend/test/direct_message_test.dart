import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/inbox.dart';
import 'package:frontend/screens/message_details.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Client createInboxClient() {
  return MockClient((request) async {
    return http.Response('[]', 200);
  });
}

void main() {
  group('MessageDetailsScreen', () {
    testWidgets('displays sample incoming messages for Sarah Lee',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MessageDetailsScreen(
            personName: 'Sarah Lee',
            avatar: 'S',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Hi! Is the vegetable soup still available?'),
        findsOneWidget,
      );
      expect(
        find.text('Yes, it is still available!'),
        findsOneWidget,
      );
    });

    testWidgets('adds a new message when valid text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MessageDetailsScreen(
            personName: 'Sarah Lee',
            avatar: 'S',
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder messageInput = find.byType(TextField);
      expect(messageInput, findsOneWidget);

      await tester.enterText(messageInput, 'Thanks for the update!');
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();

      expect(find.text('Thanks for the update!'), findsOneWidget);
    });

    testWidgets('does not send a message when input is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MessageDetailsScreen(
            personName: 'Sarah Lee',
            avatar: 'S',
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();

      expect(find.text('Message conversation created.'), findsNothing);
      expect(find.text('Thanks for the update!'), findsNothing);
      expect(
        find.text('Hi! Is the vegetable soup still available?'),
        findsOneWidget,
      );
    });
  });

  group('InboxScreen', () {
    Finder findTextFieldByLabel(String label) {
      return find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == label,
        description: 'TextField with label "$label"',
      );
    }

    testWidgets('creates a new conversation from the new-message dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InboxScreen(httpClient: createInboxClient()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('New Message'));
      await tester.pumpAndSettle();

      final Finder recipientField = findTextFieldByLabel('Recipient');
      final Finder messageField = findTextFieldByLabel('Message');

      expect(recipientField, findsOneWidget);
      expect(messageField, findsOneWidget);

      await tester.enterText(recipientField, 'Alex');
      await tester.enterText(messageField, 'Hello there!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
      await tester.pumpAndSettle();

      expect(find.text('Message conversation created.'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Hello there!'), findsOneWidget);
    });

    testWidgets('does not create a new conversation with incomplete input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InboxScreen(httpClient: createInboxClient()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('New Message'));
      await tester.pumpAndSettle();

      final Finder messageField = findTextFieldByLabel('Message');
      expect(messageField, findsOneWidget);

      await tester.enterText(messageField, 'Hello there!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
      await tester.pumpAndSettle();

      expect(find.text('Message conversation created.'), findsNothing);
      expect(find.text('New Message'), findsOneWidget);
      expect(find.text('Hello there!'), findsOneWidget);
    });
  });
}
