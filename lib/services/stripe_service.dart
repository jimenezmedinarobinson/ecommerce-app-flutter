import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_service.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  final ApiService _apiService = ApiService();

  // Inicializar Stripe (simplificado)
  Future<void> initialize() async {
    // Solo verificamos que exista la clave
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (publishableKey == null) {
      print('⚠️ Advertencia: Stripe publishable key no encontrada en .env');
    } else {
      print('✅ Stripe configurado con clave: ${publishableKey.substring(0, 10)}...');
    }
    // En esta versión simplificada, no inicializamos el SDK
    // Solo simulamos el pago para pruebas
  }

  // Procesar un pago (SIMULADO - para pruebas sin conexión real a Stripe)
  Future<bool> processPayment({
    required double amount,
    required String currency,
    required String customerName,
    required String customerEmail,
    required List<Product> cartItems,
    required Map<String, int> quantities,
  }) async {
    try {
      print('💰 Procesando pago simulado por \$${amount.toStringAsFixed(2)}');
      print('👤 Cliente: $customerName');
      print('📧 Email: $customerEmail');
      
      // Simular un retraso de procesamiento
      await Future.delayed(Duration(seconds: 2));
      
      // Simular pago exitoso (siempre exitoso en modo prueba)
      final paymentId = 'sim_${DateTime.now().millisecondsSinceEpoch}';
      print('✅ Pago simulado exitoso: $paymentId');
      
      // Guardar el pedido
      final order = await _saveOrder(
        customerName: customerName,
        customerEmail: customerEmail,
        cartItems: cartItems,
        quantities: quantities,
        paymentId: paymentId,
      );
      
      return order != null;
    } catch (e) {
      print('❌ Error en el pago simulado: $e');
      return false;
    }
  }

  // Guardar el pedido en el backend
  Future<Order?> _saveOrder({
    required String customerName,
    required String customerEmail,
    required List<Product> cartItems,
    required Map<String, int> quantities,
    required String paymentId,
  }) async {
    try {
      final orderItems = cartItems.map((product) {
        return OrderItem(
          productId: product.id!,
          name: product.name,
          price: product.price,
          quantity: quantities[product.id] ?? 1,
        );
      }).toList();

      double total = 0;
      for (var product in cartItems) {
        total += product.price * (quantities[product.id] ?? 1);
      }

      final order = Order(
        customerName: customerName,
        customerEmail: customerEmail,
        items: orderItems,
        totalAmount: total,
        paymentId: paymentId,
        status: 'pagado',
      );

      return await _apiService.createOrder(order);
    } catch (e) {
      print('Error guardando el pedido: $e');
      return null;
    }
  }
}
