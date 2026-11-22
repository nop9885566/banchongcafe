import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/queue_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BanchongCafeApp());
}

class BanchongCafeApp extends StatelessWidget {
  const BanchongCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'บรรจงคาเฟ่ - Banchong Cafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/menu',
      routes: {
        '/': (context) => const MenuScreen(),
        '/menu': (context) => const MenuScreen(),
        '/cart': (context) => const CartScreen(),
        '/queue': (context) => const QueueScreen(orderId: 0),
      },
    );
  }
}
