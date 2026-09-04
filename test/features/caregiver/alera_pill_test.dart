import 'package:alera/design_system/widgets/alera_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders label and optional leading widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AleraPill(label: 'Message', leading: Icon(Icons.message)),
        ),
      ),
    );
    expect(find.text('Message'), findsOneWidget);
    expect(find.byIcon(Icons.message), findsOneWidget);
  });

  testWidgets('calls onTap and exposes selected filter semantics', (
    tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AleraPill(
            label: 'Warning',
            selected: true,
            variant: AleraPillVariant.filter,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Warning'));
    expect(tapped, isTrue);
    expect(
      tester.getSemantics(find.text('Warning')),
      matchesSemantics(
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        isFocusable: true,
        label: 'Warning',
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });
}
