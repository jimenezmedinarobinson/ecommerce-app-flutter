import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      return getMockProducts();
    }
  }

  List<Product> getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Camiseta Azul',
        price: 19.99,
        description: 'Camiseta de algodón 100%',
        imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Camiseta',
        category: 'Ropa',
      ),
      Product(
        id: '2',
        name: 'Auriculares X',
        price: 49.99,
        description: 'Auriculares inalámbricos',
        imageUrl: 'https://via.placeholder.com/150/000000/FFFFFF?text=Auriculares',
        category: 'Electrónica',
      ),
    ];
  }

  Future<Order> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear pedido: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al crear pedido: $e');
      rethrow;
    }
  }

  Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar pedidos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar pedidos: $e');
      return [];
    }
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      
      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar pedido: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar pedido: $e');
      rethrow;
    }
  }
}
