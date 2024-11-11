class CartConnection {
  final String cartCode;
  final String connectedAt;
  final bool connected;

  CartConnection({
    required this.cartCode,
    required this.connectedAt,
    required this.connected,
  });

  factory CartConnection.fromJson(Map<String, dynamic> json) {
    return CartConnection(
      cartCode: json['cartCode'] as String,
      connectedAt: json['connectedAt'] as String,
      connected: json['connected'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartCode': cartCode,
      'connectedAt': connectedAt,
      'connected': connected,
    };
  }
}
