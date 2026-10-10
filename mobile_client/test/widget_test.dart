import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_client/main.dart';

void main() {
  testWidgets('Items screen builds', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Items'), findsOneWidget);
  });
}
