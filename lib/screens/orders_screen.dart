import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';
import 'login_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final authService = AuthService();
    final isAuthenticated = await authService.isAuthenticated();
    
    if (!isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }
    
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      _orders = await _apiService.fetchOrders();
    } catch (e) {
      print('Error al cargar pedidos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pedidos: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(Order order, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(order.id!, newStatus);
      setState(() {
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index] = Order(
            id: order.id,
            customerName: order.customerName,
            customerEmail: order.customerEmail,
            items: order.items,
            totalAmount: order.totalAmount,
            status: newStatus,
            paymentId: order.paymentId,
            createdAt: order.createdAt,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "$newStatus"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay pedidos aún'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ExpansionTile(
                        leading: Icon(
                          _getStatusIcon(order.status),
                          color: _getStatusColor(order.status),
                        ),
                        title: Text('Orden #${order.id?.substring(0, 8) ?? 'N/A'}'),
                        subtitle: Text(
                          '${order.customerName} - \$${order.totalAmount.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          order.status,
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cliente: ${order.customerName}'),
                                Text('Email: ${order.customerEmail}'),
                                Text('ID de pago: ${order.paymentId ?? 'N/A'}'),
                                SizedBox(height: 10),
                                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...order.items.map((item) {
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
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('Cambiar estado:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (order.status != 'pagado')
                                      _buildStatusButton('pagado', order),
                                    if (order.status != 'enviado')
                                      _buildStatusButton('enviado', order),
                                    if (order.status != 'entregado')
                                      _buildStatusButton('entregado', order),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusButton(String status, Order order) {
    return ElevatedButton(
      onPressed: () => _updateStatus(order, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getStatusColor(status),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(status),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pendiente':
        return Icons.pending;
      case 'pagado':
        return Icons.payment;
      case 'enviado':
        return Icons.local_shipping;
      case 'entregado':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'pagado':
        return Colors.blue;
      case 'enviado':
        return Colors.purple;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
