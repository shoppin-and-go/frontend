import 'package:flutter/material.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoppin_and_go/main.dart';

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

    return Scaffold(
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
    );
  }
}
