import 'dart:convert';

class CartInventoryItem {
  final String name;
  final int quantity;
  final int price;

  CartInventoryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CartInventoryItem.fromJson(Map<String, dynamic> json) {
    return CartInventoryItem(
      name: utf8.decode(json['name'].toString().codeUnits),
      quantity: json['quantity'] as int,
      price: json['price'] as int,
    );
  }
}

class CartInventoryStatus {
  final String code;
  final String message;
  final CartInventory result;

  CartInventoryStatus({
    required this.code,
    required this.message,
    required this.result,
  });

  factory CartInventoryStatus.fromJson(Map<String, dynamic> json) {
    return CartInventoryStatus(
      code: json['code'] as String,
      message: json['message'] as String,
      result: CartInventory.fromJson(json['result'] as Map<String, dynamic>),
    );
  }
}

class CartInventory {
  final String cartCode;
  final List<CartInventoryItem> items;

  CartInventory({
    required this.cartCode,
    required this.items,
  });

  factory CartInventory.fromJson(Map<String, dynamic> json) {
    return CartInventory(
      cartCode: json['inventory']['cartCode'] as String,
      items: (json['inventory']['items'] as List)
          .map((item) => CartInventoryItem.fromJson(item))
          .toList(),
    );
  }
}
