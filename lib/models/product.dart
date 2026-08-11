class Product {
  final String? id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id']?.toString(),
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
