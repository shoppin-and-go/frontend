import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // PaymentScreen에서 전달된 cartItems 받기
    final List<Map<String, dynamic>> cartItems = ModalRoute.of(context)!
        .settings
        .arguments as List<Map<String, dynamic>>;
    final double totalAmount = cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 완료'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '결제 내역',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('수량: ${item['quantity']}'),
                    trailing: Text(
                      '₩${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₩${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register'); // 결제 완료 후 돌아가기
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  backgroundColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
                ),
                child: const Text('확인',
                    style: TextStyle(
                        fontSize: 18, color: Color.fromRGBO(255, 255, 255, 1))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
