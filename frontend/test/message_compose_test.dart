import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/message_compose.dart';

void main() {
  Widget buildCompose({ValueChanged<String>? onSend}) {
    return MaterialApp(
      home: MessageComposeScreen(
        donorName: 'Sarah Lee',
        listingName: 'Vegetable Soup',
        onSend: onSend,
      ),
    );
  }

  testWidgets('displays selected donor and listing information',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildCompose());

    expect(find.text('Sarah Lee'), findsOneWidget);
    expect(find.text('Regarding: Vegetable Soup'), findsOneWidget);
  });

  testWidgets('provides a message input and send button',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildCompose());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Send Message'), findsOneWidget);
  });

  testWidgets('blocks empty and whitespace-only messages',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildCompose());

    await tester.tap(find.text('Send Message'));
    await tester.pump();
    expect(find.text('Enter a message before sending.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Send Message'));
    await tester.pump();
    expect(find.text('Enter a message before sending.'), findsOneWidget);
  });

  testWidgets('accepts a valid message through the local callback',
      (WidgetTester tester) async {
    String? submittedMessage;
    await tester.pumpWidget(
      buildCompose(onSend: (message) => submittedMessage = message),
    );

    await tester.enterText(find.byType(TextField), ' Is the soup available? ');
    await tester.tap(find.text('Send Message'));
    await tester.pump();

    expect(submittedMessage, 'Is the soup available?');
    expect(find.text('Message ready to send.'), findsOneWidget);
  });
}
