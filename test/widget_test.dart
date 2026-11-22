import 'package:flutter_test/flutter_test.dart';
import 'package:moblieapp/main.dart';

void main() {
  testWidgets('Banchong Cafe smoke test - verifies MenuScreen and categories', (WidgetTester tester) async {
    await tester.pumpWidget(const BanchongCafeApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // ตรวจสอบว่ามีชื่อหัวข้อเมนูเครื่องดื่ม & เค้ก และหมวดหมู่หลัก
    expect(find.text('เมนูเครื่องดื่ม & เค้ก'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Non-Coffee'), findsOneWidget);
    expect(find.text('Cake'), findsOneWidget);
  });
}
