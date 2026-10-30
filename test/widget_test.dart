import 'package:flutter_test/flutter_test.dart';
import 'package:khetiharii/main.dart';

void main() {
  testWidgets('App loads welcome screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the welcome screen renders or MyApp loads successfully.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
