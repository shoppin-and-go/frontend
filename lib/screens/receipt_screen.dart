import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppin_and_go/main.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:shoppin_and_go/services/device_id_service.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // PaymentScreen에서 전달된 arguments 가져오기
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<CartItem> cartItems = args['cartItems']; // 장바구니 항목
    final String selectedCard = args['selectedCard']; // 선택된 카드 정보

    // 현재 날짜와 시간을 지정된 형식으로 가져오기
    final String purchaseDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String purchaseTime = DateFormat('HH:mm').format(DateTime.now());
    const String purchaseLocation = '이마트 자양점'; // 구매 장소

    final cartService = CartApiService(
        baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');

    return PopScope(
      // 뒤로 가기 및 스와이프 동작을 비활성화
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 구매 장소를 화면 상단에 중앙 정렬하여 표시
              const Center(
                child: Text(
                  purchaseLocation,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              // 구매 날짜와 시간, 결제 카드 정보를 표시
              Text('구매 날짜: $purchaseDate'),
              Text('구매 시간: $purchaseTime'),
              Text('결제 카드: $selectedCard'),
              const Divider(),
              const SizedBox(height: 16.0),
              // '구매 내역' 제목 표시
              const Text(
                '구매 내역',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // 장바구니 항목 목록을 생성하는 ListView.builder
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length, // 항목 개수
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item.name), // 항목 이름
                      subtitle: Text('수량: ${item.quantity}'), // 항목 수량
                      trailing: Text(
                        // 항목 가격 표시
                        formatToWon(item.price * item.quantity),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // 총 결제 금액을 화면 하단에 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 결제 금액',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatToWon(calculateTotalAmount(cartItems)),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // 확인 버튼 (클릭 시 '/register' 화면으로 이동)
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await cartService
                        .disconnectFromAllCarts(DeviceIdService.deviceId);
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/register',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    backgroundColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                        fontSize: 18, color: Color.fromRGBO(255, 255, 255, 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
