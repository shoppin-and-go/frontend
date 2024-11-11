import 'package:flutter/material.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoppin_and_go/main.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/services/device_id_service.dart';
// import 'package:logger/logger.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartService = CartApiService(
      baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');
  List<CartItem> cartItems = [];
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      final String cartId =
          ModalRoute.of(context)!.settings.arguments as String;
      // _registerTestInventory(cartId).then((_) async {
      //   await _loadCartInventory(cartId);
      //   _isLoaded = true;
      // });
      _loadCartInventory(cartId);
      _isLoaded = true;
    }
  }

  // 테스트용 재고 등록 함수
  // Future<void> _registerTestInventory(String cartId) async {
  //   try {
  //     Logger().d('테스트용 재고 등록 중...');
  //     await cartService.changeCartInventory(cartId, 'ramen-1', 3); // 라면 3개
  //     await cartService.changeCartInventory(cartId, 'chip-2', 2); // 과자 2개
  //     Logger().d('테스트용 재고 등록 완료');
  //   } catch (e) {
  //     Logger().d('테스트용 재고 등록 실패: $e');
  //   }
  // }

  Future<void> _loadCartInventory(String cartId) async {
    try {
      final String cartId =
          ModalRoute.of(context)!.settings.arguments as String;
      final inventory =
          await cartService.getCartInventory(DeviceIdService.deviceId, cartId);

      setState(() {
        cartItems = inventory.result.items
            .map((item) => CartItem(
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                  imagePath: 'assets/logo.png', // 기본 이미지 사용
                ))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재고 정보를 불러오는데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String cartId = ModalRoute.of(context)!.settings.arguments as String;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmDialog(context);
        if (shouldPop) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
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
      ),
    );
  }

  Future<bool> _showExitConfirmDialog(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카트와의 연결이 해제됩니다'),
          content: const Text('정말 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // 다이얼로그 닫기, 화면 유지
              },
              child: const Text('계속 쇼핑하기'),
            ),
            TextButton(
              onPressed: () async {
                await cartService
                    .disconnectFromAllCarts(DeviceIdService.deviceId);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }
}
