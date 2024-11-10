import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartItem extends StatelessWidget {
  final String name;
  final int price;
  final int quantity;
  final String imagePath;

  CartItem({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });

  final NumberFormat currencyFormat = NumberFormat('#,##0', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₩${currencyFormat.format(price)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '수량: $quantity',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
