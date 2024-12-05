import 'package:flutter/material.dart';
import 'package:shoppin_and_go/widgets/cart_item.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoppin_and_go/main.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/services/device_id_service.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartService = CartApiService();
  List<CartItem> cartItems = [];
  bool _isLoaded = false;
  late StompClient stompClient;
  String? currentCartId;
  // bool _isFirstInventory = true;

  @override
  void initState() {
    super.initState();
    _initializeStompClient();
  }

  void _initializeStompClient() {
    const wsUrl = '${CartApiService.baseUrl}/ws';
    Logger().d('웹소켓 연결 시작: $wsUrl');

    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          Logger().d('웹소켓 연결됨');
          stompClient.subscribe(
            destination: '/queue/device/${DeviceIdService.deviceId}',
            callback: (frame) async {
              Logger().d('재고 변경 이벤트 수신');
              if (currentCartId != null && mounted) {
                try {
                  await _loadCartInventory(currentCartId!);
                } catch (e) {
                  Logger().e('재고 로드 실패: $e');
                }
              }
            },
          );
        },
      ),
    );
    stompClient.activate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      currentCartId = ModalRoute.of(context)!.settings.arguments as String;
      _loadCartInventory(currentCartId!);
      _isLoaded = true;
    }
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }

  // 테스트용 재고 등록 함수
  // Future<void> _registerTestInventory() async {
  //   final inventorySet = _isFirstInventory
  //       ? {'ramen-1': 2, 'chip-2': 1}
  //       : {'ramen-1': -2, 'chip-2': 1};

  //   try {
  //     for (final entry in inventorySet.entries) {
  //       await cartService.changeCartInventory(
  //           currentCartId!, entry.key, entry.value);
  //     }
  //     _isFirstInventory = !_isFirstInventory;

  //     await _loadCartInventory(currentCartId!);
  //   } catch (e) {
  //     Logger().e('테스트 재고 등록 실패: $e');
  //   }
  // }

  Future<void> _loadCartInventory(String cartId) async {
    try {
      final inventory =
          await cartService.getCartInventory(DeviceIdService.deviceId, cartId);
      if (!mounted) return;

      setState(() {
        cartItems = inventory.result.items
            .where((item) => item.quantity > 0)
            .map((item) => CartItem(
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                  imagePath: 'assets/${item.name}.png',
                ))
            .toList();
      });
    } catch (e) {
      Logger().e('재고 로드 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재고 정보를 불러오는데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmDialog(context);
        if (shouldPop) {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/register',
              (route) => false,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('장바구니'),
          actions: [
            // 랜덤 상품 추가 버튼
            IconButton(
              icon: const Icon(Icons.add_shopping_cart_outlined),
              onPressed: _addRandomItem,
            ),
            // 랜덤 상품 제거 버튼
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              onPressed: _removeRandomItem,
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black54,
        ),
        body: cartItems.isEmpty
            ? const Center(child: Text('장바구니가 비어있습니다'))
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) => cartItems[index],
                ),
              ),
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

  // 상품 코드와 이름 매핑
  final Map<String, String> _products = {
    'ramen-1': '신라면',
    'ramen-2': '짜파게티',
    // 'ramen-3': '불닭볶음면', 뭐지 이 새끼 이미지 안 불러와짐 ㄷㄷ
    'chip-1': '콘칩',
    'chip-2': '새우깡',
    'chip-3': '포테이토칩',
    'drink-1': '파워에이드',
    'drink-2': '게토레이',
    'drink-3': '코카콜라',
    'drink-4': '펩시',
  };

  // 랜덤 상품 추가
  Future<void> _addRandomItem() async {
    if (currentCartId == null) return;

    final random = Random();
    final productCode = _products.keys.elementAt(
      random.nextInt(_products.length),
    );

    try {
      await cartService.changeCartInventory(currentCartId!, productCode, 1);
      await _loadCartInventory(currentCartId!);
    } catch (e) {
      Logger().e('랜덤 상품 추가 실패: $e');
    }
  }

  // 랜덤 상품 제거
  Future<void> _removeRandomItem() async {
    if (currentCartId == null || cartItems.isEmpty) return;

    final random = Random();
    final selectedItem = cartItems[random.nextInt(cartItems.length)];

    // 상품 이름으로부터 상품 코드 찾기
    final productCode = _products.entries
        .firstWhere((entry) => entry.value == selectedItem.name)
        .key;

    try {
      await cartService.changeCartInventory(
        currentCartId!,
        productCode,
        -1,
      );
      await _loadCartInventory(currentCartId!);
    } catch (e) {
      Logger().e('랜덤 상품 제거 실패: $e');
    }
  }
}
