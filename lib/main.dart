import 'package:flutter/material.dart';
import 'package:shoppin_and_go/screens/loading_screen.dart';
import 'package:shoppin_and_go/screens/receipt_screen.dart';
import 'package:shoppin_and_go/screens/register_screen.dart';
import 'package:shoppin_and_go/screens/qr_scan_screen.dart';
import 'package:shoppin_and_go/screens/cart_screen.dart';
import 'package:shoppin_and_go/screens/payment_screen.dart';
import 'package:intl/intl.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:shoppin_and_go/services/device_id_service.dart';
import 'package:logger/logger.dart';

// 총액 계산 함수
int calculateTotalAmount(List<CartItem> items) {
  return items.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );
}

// 가격을 원화(+쉼표) 형식 문자열로 변환
String formatToWon(int amount) {
  return '₩${NumberFormat('#,##0', 'ko_KR').format(amount)}';
}

void main() async {
  // WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  // await DeviceIdService.initialize(); // 디바이스 ID 초기화
  Logger().d('디바이스ID: ${DeviceIdService.deviceId}');
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
        '/payment': (context) => const PaymentScreen(),
        '/receipt': (context) => const ReceiptScreen(),
      },
    );
  }
}
