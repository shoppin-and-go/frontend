import 'package:flutter/material.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String cartId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(cartId),
      ),
      body: ListView(
        children: const [
          CartItem(
            name: '펩시',
            price: '1,600',
            count: '1',
            imagePath: 'assets/pepsi.png',
          ),
          CartItem(
            name: '콘칩',
            price: '1,500',
            count: '1',
            imagePath: 'assets/cornchip.png',
          ),
        ],
      ),
    );
  }
}
