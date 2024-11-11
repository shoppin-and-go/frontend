import 'package:flutter/material.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoppin_and_go/main.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String cartId = ModalRoute.of(context)!.settings.arguments as String;

    // CartItem 목록 생성
    final List<CartItem> cartItems = [
      const CartItem(
        name: '펩시',
        price: 1600,
        quantity: 1,
        imagePath: 'assets/pepsi.png',
      ),
      const CartItem(
        name: '콘칩',
        price: 1500,
        quantity: 2,
        imagePath: 'assets/cornchip.png',
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmDialog(context);
        if (shouldPop) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(cartId),
        ),
        body: ListView(children: cartItems),
        bottomNavigationBar: SizedBox(
          height: 150,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '총 금액',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      formatToWon(calculateTotalAmount(cartItems)),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SlideAction(
                  sliderButtonIcon: Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                  ),
                  text: '밀어서 결제하기',
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  outerColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
                  innerColor: Colors.transparent,
                  borderRadius: 36,
                  sliderRotate: false,
                  sliderButtonYOffset: -40,
                  onSubmit: () {
                    // 결제 화면에 cartItemData 전달
                    Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: cartItems,
                    );
                    return;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmDialog(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카트와의 연결이 해제됩니다'),
          content: const Text('정말 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // 다이얼로그 닫기, 화면 유지
              },
              child: const Text('계속 쇼핑하기'),
            ),
            TextButton(
              onPressed: () async {
                await CartApiService(
                        baseUrl:
                            'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com')
                    .disconnectFromAllCarts('test-device-id'); // 임시 디바이스 ID
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }
}
