import 'package:hive/hive.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 0)
class CartItemModel {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double price;
  
  @HiveField(3)
  final String imageUrl;
  
  @HiveField(4)
  final String category;
  
  @HiveField(5)
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['id'] ?? json['_id']?.toString() ?? '',
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      category: json['category'] ?? 'General',
      quantity: json['quantity'] ?? 1,
    );
  }
}
