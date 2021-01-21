import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suggestion_text_field/src/suggestion_overlay.dart';
import 'package:suggestion_text_field/src/suggestion_text_field.dart';

void main() {
  testWidgets(
    "Text field will display the given hint text",
    (WidgetTester tester) async {
      await tester.pumpWidget(TestApp(SuggestionTextField(
        decoration: InputDecoration(hintText: "Test"),
        getSuggestions: (_) {
          return [];
        },
        textSubmitted: (_) {},
      )));

      expect(find.text("Test"), findsOneWidget);
    },
  );

  testWidgets(
    "getSuggestions is called when text is entered",
    (WidgetTester tester) async {
      bool getSuggestionsCalled = false;
      await tester.pumpWidget(TestApp(SuggestionTextField(
        decoration: InputDecoration(hintText: "Test"),
        getSuggestions: (_) {
          getSuggestionsCalled = true;
          return [];
        },
        textSubmitted: (_) {},
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(SuggestionTextField), "H");

      expect(getSuggestionsCalled, true);
    },
  );

  testWidgets(
    "Submitted text is sent to callback",
    (WidgetTester tester) async {
      bool textSubmitted = false;
      await tester.pumpWidget(TestApp(SuggestionTextField(
        selectionAction: SuggestionSelectionAction.Submit,
        decoration: InputDecoration(hintText: "Test"),
        getSuggestions: (text) {
          return text.split(" ");
        },
        textSubmitted: (text) {
          textSubmitted = true;
        },
      )));

      await tester.enterText(find.byType(SuggestionTextField), "Hello World");
      await tester.pumpAndSettle();
      expect(find.byType(SuggestionOverlay), findsOneWidget);
      await tester.tap(find.widgetWithText(Row, "Hello"));
      await tester.pumpAndSettle();

      expect(textSubmitted, true);
    },
  );
}

class TestApp extends StatelessWidget {
  final SuggestionTextField textField;

  TestApp(this.textField);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        body: Center(
          child: Inner(
            textField,
          ),
        ),
      ),
    );
  }
}

class Inner extends StatefulWidget {
  final SuggestionTextField textField;
  Inner(this.textField);

  @override
  _InnerState createState() => _InnerState();
}

class _InnerState extends State<Inner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.textField,
    );
  }
}
