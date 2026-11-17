import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_dragon_studio/main.dart';

void main() {
  testWidgets('CloudDragonApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CloudDragonApp());
    expect(find.text('Cloud Dragon Studio'), findsWidgets);
  });
}
