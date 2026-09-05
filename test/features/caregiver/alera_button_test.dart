import 'package:alera/design_system/widgets/alera_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders primary icon button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AleraButton(label: 'Call', icon: Icons.phone, onPressed: _noop),
        ),
      ),
    );
    expect(find.text('Call'), findsOneWidget);
    expect(find.byIcon(Icons.phone), findsOneWidget);
  });

  testWidgets('renders disabled secondary button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AleraButton(
            label: 'Resolve',
            variant: AleraButtonVariant.secondary,
            onPressed: null,
          ),
        ),
      ),
    );
    expect(find.text('Resolve'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('hugs content when expand is false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AleraButton(label: 'Remind', expand: false, onPressed: _noop),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AleraButton)).width, lessThan(200));
  });
}

void _noop() {}
