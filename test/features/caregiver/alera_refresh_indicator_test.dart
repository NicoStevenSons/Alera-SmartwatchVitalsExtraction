import 'package:alera/design_system/alera_colors.dart';
import 'package:alera/design_system/widgets/alera_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses Alera defaults for the Flutter refresh indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AleraRefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 800)],
            ),
          ),
        ),
      ),
    );

    final RefreshIndicator indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    expect(indicator.backgroundColor, Colors.white);
    expect(indicator.color, AleraColors.primary);
    expect(indicator.displacement, 40);
    expect(indicator.edgeOffset, 0);
    expect(find.byType(ListView), findsOneWidget);
  });
}
