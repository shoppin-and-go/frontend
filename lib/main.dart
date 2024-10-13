import 'package:flutter/material.dart';
import 'package:shoppin_and_go/screens/loading_screen.dart';
import 'package:shoppin_and_go/screens/register_screen.dart';
import 'package:shoppin_and_go/screens/qr_scan_screen.dart';
import 'package:shoppin_and_go/screens/cart_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoppin and Go',
      home: const LoadingScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/scanner': (context) => const QRScanScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
