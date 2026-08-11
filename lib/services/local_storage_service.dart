import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';

class LocalStorageService {
  static const String _cartBoxName = 'cartBox';
  static const String _cartItemsKey = 'cartItems';
  
  static Box? _cartBox;

  // Inicializar Hive
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Registrar el adaptador de CartItemModel
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CartItemModelAdapter());
      }
      
      // Abrir la caja del carrito
      _cartBox = await Hive.openBox(_cartBoxName);
      print('✅ Hive inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Hive: $e');
    }
  }

  // Guardar el carrito - usando JSON encode/decode para evitar problemas de tipos
  static Future<void> saveCart(List<CartItemModel> items) async {
    try {
      if (_cartBox == null) {
        await init();
      }
      
      // Convertir a JSON string para evitar problemas de tipos
      final itemsJson = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(itemsJson);
      await _cartBox?.put(_cartItemsKey, jsonString);
      print('✅ Carrito guardado: ${items.length} items');
    } catch (e) {
      print('❌ Error guardando carrito: $e');
    }
  }

  // Cargar el carrito - usando JSON decode para obtener Map<String, dynamic> correcto
  static Future<List<CartItemModel>> loadCart() async {
    try {
      if (_cartBox == null) {
        await init();
      }
      
      // Obtener el JSON string
      final jsonString = _cartBox?.get(_cartItemsKey) as String?;
      if (jsonString == null || jsonString.isEmpty) {
        print('📦 Carrito vacío');
        return [];
      }
      
      // Decodificar JSON a List<Map<String, dynamic>>
      final List<dynamic> itemsJson = jsonDecode(jsonString);
      final items = itemsJson.map((json) {
        // Asegurar que el mapa es Map<String, dynamic>
        final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
        return CartItemModel.fromJson(map);
      }).toList();
      
      print('📦 Carrito cargado: ${items.length} items');
      return items;
    } catch (e) {
      print('❌ Error cargando carrito: $e');
      return [];
    }
  }

  // Limpiar el carrito
  static Future<void> clearCart() async {
    try {
      if (_cartBox == null) {
        await init();
      }
      await _cartBox?.delete(_cartItemsKey);
      print('🗑️ Carrito eliminado');
    } catch (e) {
      print('❌ Error eliminando carrito: $e');
    }
  }
}
