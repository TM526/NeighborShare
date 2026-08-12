import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/incident_report.dart';

void main() {
  Future<void> pumpReportPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IncidentReportPage(),
      ),
    );
  }

  testWidgets('displays required incident report fields and action',
      (WidgetTester tester) async {
    await pumpReportPage(tester);

    expect(find.text('Report title'), findsOneWidget);
    expect(find.text('Incident details'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('blocks an empty report and displays validation messages',
      (WidgetTester tester) async {
    await pumpReportPage(tester);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Report title is required.'), findsOneWidget);
    expect(find.text('Report details are required.'), findsOneWidget);
    expect(
      find.text('Report is valid and ready for processing.'),
      findsNothing,
    );
  });

  testWidgets('blocks whitespace-only report fields',
      (WidgetTester tester) async {
    await pumpReportPage(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '   ');
    await tester.enterText(fields.at(1), '\n  ');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Report title is required.'), findsOneWidget);
    expect(find.text('Report details are required.'), findsOneWidget);
  });

  testWidgets('allows a valid report to continue processing',
      (WidgetTester tester) async {
    await pumpReportPage(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Unsafe food listing');
    await tester.enterText(fields.at(1), 'The listing contains expired food.');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(
        find.text('Report is valid and ready for processing.'), findsOneWidget);
    expect(find.text('Report title is required.'), findsNothing);
    expect(find.text('Report details are required.'), findsNothing);
  });
}
