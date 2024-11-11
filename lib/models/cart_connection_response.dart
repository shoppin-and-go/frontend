class CartConnectionResponse {
  final String code;
  final String message;
  final CartConnectionResult result;

  CartConnectionResponse({
    required this.code,
    required this.message,
    required this.result,
  });

  factory CartConnectionResponse.fromJson(Map<String, dynamic> json) {
    return CartConnectionResponse(
      code: json['code'],
      message: json['message'],
      result: CartConnectionResult.fromJson(json['result']),
    );
  }
}

class CartConnectionResult {
  final Connection connection;

  CartConnectionResult({required this.connection});

  factory CartConnectionResult.fromJson(Map<String, dynamic> json) {
    return CartConnectionResult(
      connection: Connection.fromJson(json['connection']),
    );
  }
}

class Connection {
  final String cartCode;
  final String connectedAt;
  final bool connected;

  Connection({
    required this.cartCode,
    required this.connectedAt,
    required this.connected,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      cartCode: json['cartCode'],
      connectedAt: json['connectedAt'],
      connected: json['connected'],
    );
  }
}
