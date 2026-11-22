import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moblieapp/screens/menu_screen.dart';

void main() {
  testWidgets('Reproduce menu error', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('CAUGHT_FLUTTER_ERROR: ${details.exception}');
      print('STACKTRACE:\n${details.stack}');
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Fast-forward 3 seconds for http timeout
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    final foundCaramel = find.text('Caramel Macchiato');
    print('Found Caramel Macchiato: ${foundCaramel.evaluate().isNotEmpty}');

    final foundItemsCount = find.textContaining('พบ ');
    print('Found count widget: ${foundItemsCount.evaluate().isNotEmpty}');
  });
}
