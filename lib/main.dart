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
import 'package:shoppin_and_go/services/cart_api_service.dart';

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
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await DeviceIdService.initialize(); // 디바이스 ID 초기화
  Logger().d('디바이스ID: ${DeviceIdService.deviceId}');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final cartService = CartApiService(
      baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      _cleanupOnExit();
    }
  }

  Future<void> _cleanupOnExit() async {
    try {
      await cartService.disconnectFromAllCarts(DeviceIdService.deviceId);
      Logger().d('앱 종료: 모든 카트 연결 해제 완료');
    } catch (e) {
      Logger().e('앱 종료: 카트 연결 해제 실패: $e');
    }
  }

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
