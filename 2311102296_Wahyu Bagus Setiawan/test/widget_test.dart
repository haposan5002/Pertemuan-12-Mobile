import 'package:flutter_test/flutter_test.dart';
import 'package:laprak_pertemuan_12/main.dart';

void main() {
  testWidgets('Counter Rocket Smoke Test', (WidgetTester tester) async {
    // Memanggil ApplicationRoot dari main.dart
    await tester.pumpWidget(const ApplicationRoot());

    // Memastikan halaman utama berhasil dimuat tanpa crash
    expect(find.text('CAPTURE & NOTIFY v2'), findsOneWidget);
  });
}