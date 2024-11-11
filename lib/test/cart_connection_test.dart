import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/models/exceptions.dart';

void main() async {
  final service = CartApiService(
      baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');

  const deviceId = 'test-device-id';
  const invalidCartCode = 'cart-3';

  try {
    // 1. 현재 활성 연결 상태 확인
    print('현재 활성 연결 상태 확인중...');
    final activeConnections = await service.getCartConnections(deviceId);
    print('현재 활성 연결:');
    for (var conn in activeConnections) {
      print('  카트: ${conn.cartCode}, 연결시간: ${conn.connectedAt}');
    }

    // 2. 기존 연결 모두 해제
    print('\n기존 연결 해제중...');
    await service.disconnectFromAllCarts(deviceId);
    print('모든 연결 해제 완료');

    // 3. 연결이 모두 해제 되었는 지 재확인
    final reconnections = await service.getCartConnections(deviceId);
    print('\n연결 해제 후 상태:');
    for (var conn in reconnections) {
      print(
          '  카트: ${conn.cartCode}, 연결시간: ${conn.connectedAt}, 연결상태: ${conn.connected}');
    }

    print('\n=== 존재하지 않는 카트 연결 테스트 ===');
    print('존재하지 않는 카트 코드로 연결 시도...');
    await service.connectCart(deviceId, invalidCartCode);
  } catch (e) {
    if (e is CartNotFoundException) {
      print('예상된 에러 발생: ${e.message}');
    } else {
      print('예상치 못한 에러 발생: $e');
    }
  }
}
