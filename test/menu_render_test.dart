import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moblieapp/screens/menu_screen.dart';

void main() {
  testWidgets('Test MenuScreen build', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR_CAUGHT: ${details.exception}');
      print('STACK: ${details.stack}');
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  });
}
