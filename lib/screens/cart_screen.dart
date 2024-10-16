import 'package:flutter/material.dart';
import 'dart:async';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showCornChip = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _showCornChip = !_showCornChip;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String cartId = ModalRoute.of(context)!.settings.arguments as String;
    final String totalAmount = _showCornChip ? '3,100' : '1,600';
    return Scaffold(
      appBar: AppBar(
        title: Text(cartId),
      ),
      body: ListView(
        children: [
          _buildCartItem('펩시', '1,600', '1', 'assets/pepsi.png'),
          if (_showCornChip)
            _buildCartItem('콘칩', '1,500', '1', 'assets/cornchip.png'),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            child: Text('결제하기 (총액 ₩$totalAmount)'),
            onPressed: () {
              // 결제 로직 구현
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(
      String name, String price, String count, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.asset(imagePath, width: 60, height: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('₩$price',
                    style: const TextStyle(fontSize: 14, color: Colors.red)),
              ],
            ),
          ),
          Text('수량: $count', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
