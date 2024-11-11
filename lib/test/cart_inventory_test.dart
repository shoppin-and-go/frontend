// ignore_for_file: avoid_print

import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/models/exceptions.dart';

void main() async {
  final service = CartApiService(
      baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');

  const deviceId = 'test-device-id';
  const cartCode = 'cart-1';
  const invalidCartCode = 'invalid-cart';
  const unconnectedCartCode = 'cart-2';

  try {
    print('\n=== 재고 조회 테스트 시작 ===');

    // 1. 카트 연결
    print('\n1. 카트 연결 시도...');
    final connectResponse = await service.connectCart(deviceId, cartCode);
    print('카트 연결 성공: ${connectResponse.result.connection.cartCode}');

    // 1-1. 테스트를 위한 재고 등록
    print('\n1-1. 테스트용 재고 등록...');
    await service.changeCartInventory(cartCode, 'ramen-1', 3); // 상품1: 3개
    await service.changeCartInventory(cartCode, 'chip-2', 2); // 상품2: 2개
    print('재고 등록 완료');

    // 2. 연결된 카트의 재고 조회
    print('\n2. 연결된 카트의 재고 조회...');
    final inventory = await service.getCartInventory(deviceId, cartCode);
    print('재고 조회 결과:');
    for (var item in inventory.result.items) {
      print('  상품: ${item.name}, 수량: ${item.quantity}, 가격: ${item.price}원');
    }

    // 3. 존재하지 않는 카트 재고 조회 시도
    print('\n3. 존재하지 않는 카트 재고 조회 시도...');
    try {
      await service.getCartInventory(deviceId, invalidCartCode);
    } catch (e) {
      if (e is CartNotFoundException) {
        print('예상된 에러 발생 (카트 없음): ${e.message}');
      } else {
        print('예상치 못한 에러 발생: $e');
      }
    }

    // 4. 연결되지 않은 카트 재고 조회 시도
    print('\n4. 연결되지 않은 카트 재고 조회 시도...');
    try {
      await service.getCartInventory(deviceId, unconnectedCartCode);
    } catch (e) {
      if (e is UnconnectedCartException) {
        print('예상된 에러 발생 (연결되지 않은 카트): ${e.message}');
      } else {
        print('예상치 못한 에러 발생: $e');
      }
    }
  } catch (e) {
    print('예상치 못한 에러 발생: $e');
  } finally {
    // 테스트 종료 시 연결 해제
    print('\n5. 테스트 종료, 연결 해제...');
    await service.disconnectFromAllCarts(deviceId);
    print('연결 해제 완료');
  }
}
