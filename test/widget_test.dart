import 'package:flutter_test/flutter_test.dart';
import 'package:feevo/app.dart';

void main() {
  testWidgets('Feevo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FeevoApp());
    expect(find.byType(FeevoApp), findsOneWidget);
  });
}
