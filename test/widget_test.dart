import 'package:flutter_test/flutter_test.dart';
import 'package:Netravest/main.dart';

void main() {
  testWidgets('Netravest dashboard widget smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Memastikan dashboard memuat teks penting
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('Kondisi Alat'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);
    expect(find.text('LOKASI ANDA'), findsOneWidget);

    // Majukan waktu virtual selama 10 detik agar timer tutorial (1.5s)
    // dan SnackBar auto-dismiss (4s) selesai sepenuhnya.
    await tester.pump(const Duration(seconds: 10));
  });
}
