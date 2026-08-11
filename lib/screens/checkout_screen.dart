import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/stripe_service.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final StripeService _stripeService = StripeService();

  @override
  void initState() {
    super.initState();
    _initStripe();
  }

  Future<void> _initStripe() async {
    try {
      await _stripeService.initialize();
      print('✅ Stripe inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Stripe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inicializar Stripe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Pedido'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Resumen del Pedido',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...cart.items.map((item) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.name} x${item.quantity}'),
                            Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                          ],
                        );
                      }).toList(),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!value.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isProcessing ? null : () => _processPayment(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Procesando...',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      )
                    : Text(
                        'Pagar con Stripe',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
              if (!_isProcessing)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    '💳 Prueba con: 4242 4242 4242 4242',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, CartProvider cart) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await _stripeService.processPayment(
        amount: cart.totalPrice,
        currency: 'usd',
        customerName: _nameController.text,
        customerEmail: _emailController.text,
        cartItems: cart.getProductsFromCart(),
        quantities: cart.getQuantitiesMap(),
      );

      if (success) {
        cart.clearCart();
        _showPaymentResult(context, true);
      } else {
        _showPaymentResult(context, false, error: 'El pago fue rechazado');
      }
    } catch (e) {
      _showPaymentResult(context, false, error: e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPaymentResult(BuildContext context, bool success, {String? error}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 50,
          ),
          content: Text(
            success
                ? '¡Pago completado con éxito!\nTu pedido ha sido confirmado.'
                : 'Error en el pago\n${error ?? 'Intenta nuevamente o usa otro método'}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (success) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: Text(success ? 'OK' : 'Intentar de nuevo'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
