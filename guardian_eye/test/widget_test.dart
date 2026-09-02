import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_eye/main.dart';

void main() {
  testWidgets('Guardian Eye renders the security dashboard', (tester) async {
    await tester.pumpWidget(const GuardianEyeApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Guardian Eye'), findsOneWidget);
    expect(find.text('ระบบตรวจสอบหยุดอยู่'), findsOneWidget);
    expect(find.text('เริ่มการตรวจสอบ'), findsOneWidget);
  });
}
