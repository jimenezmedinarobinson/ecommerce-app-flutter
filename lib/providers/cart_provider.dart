import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item_model.dart';
import '../services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;
  
  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Cargar carrito guardado al iniciar
  Future<void> loadCart() async {
    final savedItems = await LocalStorageService.loadCart();  // CAMBIADO: usar método static
    if (savedItems.isNotEmpty) {
      _items = savedItems;
      notifyListeners();
      print('🔄 Carrito restaurado desde Hive');
    }
  }

  // Agregar un producto al carrito
  void addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      // Si ya existe, aumentar cantidad
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItemModel(
        productId: existingItem.productId,
        name: existingItem.name,
        price: existingItem.price,
        imageUrl: existingItem.imageUrl,
        category: existingItem.category,
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Si no existe, agregar nuevo
      _items.add(CartItemModel(
        productId: product.id ?? '',
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        quantity: 1,
      ));
    }
    
    _saveCart();
    notifyListeners();
  }

  // Eliminar un producto del carrito
  void removeItem(String productId) {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    
    if (existingIndex != -1) {
      final existingItem = _items[existingIndex];
      
      if (existingItem.quantity > 1) {
        // Si hay más de 1, reducir cantidad
        _items[existingIndex] = CartItemModel(
          productId: existingItem.productId,
          name: existingItem.name,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          category: existingItem.category,
          quantity: existingItem.quantity - 1,
        );
      } else {
        // Si solo hay 1, eliminar el item
        _items.removeAt(existingIndex);
      }
      
      _saveCart();
      notifyListeners();
    }
  }

  // Eliminar un producto completamente
  void removeItemCompletely(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveCart();
    notifyListeners();
  }

  // Vaciar todo el carrito
  void clearCart() {
    _items.clear();
    LocalStorageService.clearCart();  // CAMBIADO: usar método static
    notifyListeners();
  }

  // Obtener cantidad de un producto específico
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        productId: '',
        name: '',
        price: 0,
        imageUrl: '',
        category: '',
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Guardar el carrito en Hive
  void _saveCart() {
    LocalStorageService.saveCart(_items);  // CAMBIADO: usar método static
  }

  // Convertir los items del carrito a Product (para la API)
  List<Product> getProductsFromCart() {
    return _items.map((cartItem) {
      return Product(
        id: cartItem.productId,
        name: cartItem.name,
        price: cartItem.price,
        description: '',
        imageUrl: cartItem.imageUrl,
        category: cartItem.category,
      );
    }).toList();
  }

  // Obtener cantidades como mapa (para la API)
  Map<String, int> getQuantitiesMap() {
    final Map<String, int> quantities = {};
    for (var item in _items) {
      quantities[item.productId] = item.quantity;
    }
    return quantities;
  }
}
