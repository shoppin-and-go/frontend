import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoppin_and_go/models/cart_connection_response.dart';
import 'package:shoppin_and_go/models/exceptions.dart';
import 'package:shoppin_and_go/models/cart_connection.dart';

class CartApiService {
  final String baseUrl;

  CartApiService({required this.baseUrl});

  Future<CartConnectionResponse> connectCart(
      String deviceId, String cartCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart-connections'),
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
        body: jsonEncode({
          'deviceId': deviceId,
          'cartCode': cartCode,
        }),
      );

      final data = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return CartConnectionResponse.fromJson(data);
        case 400:
          throw CartNotFoundException(data['message']);
        case 409:
          throw DeviceAlreadyConnectedException(data['message']);
        default:
          throw Exception('Unknown error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 디바이스의 카트 연결 상태 조회
  Future<List<CartConnection>> getCartConnections(String deviceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/devices/$deviceId/cart-connections'),
      headers: {'Content-Type': 'application/json;charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result']['connections'] as List)
          .map((connection) => CartConnection.fromJson(connection))
          .toList();
    }

    throw Exception('Failed to get cart connections');
  }

  // 디바이스의 모든 카트 연결 해제
  Future<void> disconnectFromAllCarts(String deviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/devices/$deviceId/cart-connections'),
      headers: {'Content-Type': 'application/json;charset=UTF-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to disconnect from carts');
    }
  }
}
