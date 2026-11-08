import 'package:flutter_test/flutter_test.dart';
import 'package:karyasetara/main.dart';

void main() {
  testWidgets('KaryaSetara app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KaryaSetaraApp());
    expect(find.text('KaryaSetara'), findsOneWidget);
  });
}
