class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Order {
  final String? id;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String? paymentId;
  final DateTime? createdAt;

  Order({
    this.id,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.totalAmount,
    this.status = 'pendiente',
    this.paymentId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerEmail': customerEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentId': paymentId,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id']?.toString(),
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      items: (json['items'] as List).map((item) => OrderItem(
        productId: item['productId'],
        name: item['name'],
        price: item['price'].toDouble(),
        quantity: item['quantity'],
      )).toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'] ?? 'pendiente',
      paymentId: json['paymentId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
