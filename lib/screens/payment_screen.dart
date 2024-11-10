import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedCardIndex = -1; // 선택된 카드 인덱스를 추적하는 변수

  @override
  Widget build(BuildContext context) {
    // CartScreen에서 전달된 cartItems 받기
    final List<Map<String, dynamic>> cartItems = ModalRoute.of(context)!
        .settings
        .arguments as List<Map<String, dynamic>>;

    // 총 금액 계산
    final int totalAmount = cartItems.fold(
      0,
      (sum, item) => sum + ((item['price'] as int) * (item['quantity'] as int)),
    );

    final List<String> cards = [
      '1번 카드',
      '2번 카드',
      '3번 카드',
    ];

    // 가격 표시 형식을 위한 NumberFormat 설정 (천 단위 쉼표 추가)
    final NumberFormat currencyFormat = NumberFormat('#,##0', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 총 금액 표시
            Text(
              '총 금액: ₩${currencyFormat.format(totalAmount)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // 상품 리스트
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      // 상품 이미지가 null인 경우 기본 이미지 경로를 사용
                      leading: Image.asset(
                        item['imagePath'] ?? 'assets/default.png', // 기본 이미지 경로
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item['name'] ??
                          '상품 이름 없음'), // 상품 이름이 null인 경우 기본 텍스트 표시
                      subtitle: Text(
                          '수량: ${item['quantity'] ?? 0}'), // 수량이 null인 경우 0으로 표시
                      trailing: Text(
                        // 천 단위 쉼표가 포함된 가격 표시
                        '₩${currencyFormat.format((item['price'] as int) * (item['quantity'] as int))}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // 안내 문구
            const Text(
              '상품을 추가 / 제거하려면 뒤로 이동하세요',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            // 카드 선택 제목
            const Text(
              '카드 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // 카드 선택 캐로셀
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  // 카드가 선택되면 스타일 적용
                  final bool isSelected = index == selectedCardIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCardIndex = index;
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: isSelected ? Colors.pinkAccent[400] : Colors.white,
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
            const SizedBox(height: 16.0),
            // 결제하기 버튼 (카드가 선택되지 않으면 비활성화)
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
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                // 결제 완료 후 영수증 화면으로 이동
                Navigator.pushReplacementNamed(
                  context,
                  '/receipt',
                  arguments: {
                    'cartItems': cartItems,
                    'selectedCard': selectedCard,
                  },
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
