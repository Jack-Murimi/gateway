import 'package:flutter_test/flutter_test.dart';
import 'package:gateway/app/app.dart';

void main() {
  testWidgets('renders the login screen', (tester) async {
    await tester.pumpWidget(const GatewayApp());
    await tester.pumpAndSettle();

    expect(find.text('Gateway POS'), findsOneWidget);
    expect(find.text('LPG & Accessories Multi-Branch'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
