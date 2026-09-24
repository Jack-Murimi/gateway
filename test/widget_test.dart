import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/app/app.dart';

void main() {
  testWidgets('renders the design foundation shell', (tester) async {
    await tester.pumpWidget(const GatewayApp());
    await tester.pumpAndSettle();

    expect(find.text('Gateway POS'), findsOneWidget);
    expect(find.text('Design foundation ready'), findsOneWidget);
  });
}
