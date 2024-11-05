import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 결제 금액 및 내역 예시 데이터
    const double totalAmount = 50000.0; // Example amount
    final List<Map<String, dynamic>> purchaseItems = [
      {'name': 'Item 1', 'quantity': 2, 'price': 15000.0},
      {'name': 'Item 2', 'quantity': 1, 'price': 20000.0},
    ];

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
                itemCount: purchaseItems.length,
                itemBuilder: (context, index) {
                  final item = purchaseItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('수량: ${item['quantity']}'),
                    trailing: Text(
                      '₩${item['price'].toStringAsFixed(0)}',
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
                ),
                child: const Text('확인', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
