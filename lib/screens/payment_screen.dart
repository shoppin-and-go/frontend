import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> cards = [
      '1번 카드',
      '2번 카드',
      '3번 카드',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 총 금액 표시
            const Text(
              '총 금액: ₩50,000', // 장바구니에서 받아와서 수정할 부분
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // 카드 선택 캐로셀
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          cards[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 결제하기 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/receipt'); // 영수증 화면으로 전환
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              ),
              child: const Text(
                '결제하기',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
