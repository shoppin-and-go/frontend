import 'package:flutter/material.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:slide_to_act/slide_to_act.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String cartId = ModalRoute.of(context)!.settings.arguments as String;

    // CartItem 목록 생성
    final List<CartItem> cartItems = [
      const CartItem(
        name: '펩시',
        price: '1600',
        count: '1',
        imagePath: 'assets/pepsi.png',
      ),
      const CartItem(
        name: '콘칩',
        price: '1500',
        count: '2',
        imagePath: 'assets/cornchip.png',
      ),
    ];

    // 장바구니 아이템 데이터를 ReceiptScreen에 전달할 수 있도록 Map 형식으로 변환
    final List<Map<String, dynamic>> cartItemData = cartItems
        .map((item) => {
              'name': item.name,
              'price': int.parse(item.price),
              'quantity': int.parse(item.count),
              'imagePath': item.imagePath,
            })
        .toList();

    // 총 금액 계산
    final int totalAmount = cartItemData.fold(
      0,
      (sum, item) => (sum + (item['price'] * item["quantity"])).toInt(),
    );

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
                    '₩${totalAmount.toString()}',
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
                    arguments: cartItemData,
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
