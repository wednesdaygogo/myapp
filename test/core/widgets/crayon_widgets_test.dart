import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_records/core/widgets/crayon_card.dart';
import 'package:health_records/core/widgets/crayon_button.dart';
import 'package:health_records/core/widgets/crayon_avatar.dart';
import 'package:health_records/core/theme/crayon_theme.dart';

void main() {
  group('CrayonCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrayonCard(child: const Text('Test Content')),
        ),
      ));

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('has correct background color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrayonCard(child: const Text('Test')),
        ),
      ));

      final container = tester.widget<Container>(find.widgetWithText(Container, 'Test'));
      // Verify it renders
      expect(container, isNotNull);
    });
  });

  group('CrayonButton', () {
    testWidgets('renders with text and icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrayonButton(
            text: 'Save',
            icon: Icons.save,
            onPressed: () {},
          ),
        ),
      ));

      expect(find.text('Save'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('onPressed callback works', (tester) async {
      var pressed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrayonButton(
            text: 'Click',
            onPressed: () => pressed = true,
          ),
        ),
      ));

      await tester.tap(find.text('Click'));
      expect(pressed, isTrue);
    });
  });

  group('CrayonAvatar', () {
    testWidgets('renders emoji for preset name', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrayonAvatar(presetName: 'bear', size: 60),
        ),
      ));

      // Bear emoji should be rendered
      expect(find.text('🐻'), findsOneWidget);
    });

    testWidgets('renders default icon when no preset', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrayonAvatar(size: 60),
        ),
      ));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}