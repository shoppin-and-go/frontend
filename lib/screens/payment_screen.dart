// PaymentScreen.dart

import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 선택된 카드 인덱스를 추적하기 위한 변수
  int selectedCardIndex = -1;

  @override
  Widget build(BuildContext context) {
    // CartScreen에서 전달된 cartItems 받기
    final List<Map<String, dynamic>> cartItems = ModalRoute.of(context)!
        .settings
        .arguments as List<Map<String, dynamic>>;

    // 총 금액 계산
    final int totalAmount = cartItems.fold(
      0,
      (sum, item) => (sum + (item['price'] * item['quantity'])).toInt(),
    );

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
            Text(
              '총 금액: ₩$totalAmount',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // 카드 선택 캐로셀
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  // 카드가 선택되면 활성화 스타일 적용
                  final bool isSelected = index == selectedCardIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCardIndex = index;
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            cards[index],
                            style: TextStyle(
                              fontSize: 18,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: selectedCardIndex != -1
                  ? () => _showConfirmationDialog(
                      context, cards[selectedCardIndex], cartItems)
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                backgroundColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
              ),
              child: const Text(
                '결제하기',
                style: TextStyle(
                    fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 결제 확인 다이얼로그
  void _showConfirmationDialog(BuildContext context, String selectedCard,
      List<Map<String, dynamic>> cartItems) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("결제 확인"),
          content: Text("$selectedCard로 결제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushReplacementNamed(
                  context,
                  '/receipt',
                  arguments: {
                    'cartItems': cartItems,
                    'selectedCard': selectedCard,
                  }, // 선택된 카드와 cartItems 전달
                );
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }
}
