import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_toggle_button.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];

  final Color sageGreen = const Color(0xFF9CAF88);
  final Color beige = const Color(0xFFF5F5DC);
  final Color beigeDark = const Color(0xFFE6DCC3);

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString('orders');
    setState(() {
      orders = ordersString != null ? json.decode(ordersString) : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: sageGreen,
        title: const Text('Pedidos'),
        actions: const [ThemeToggleButton()],
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'No hay pedidos',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  color: beigeDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: sageGreen,
                      child: Text('${index + 1}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: const Text(
                      'Pedido realizado',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Fecha: ${order['fecha'] ?? 'Sin fecha'}'),
                        if (order['total'] != null)
                          Text('Total: \$${order['total']}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: Colors.grey),
                    onTap: () {
                      // Mostrar detalles del pedido si lo deseas
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: beige,
                            title: const Text('Detalles del pedido'),
                            content: Text(
                              const JsonEncoder.withIndent('  ')
                                  .convert(order),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cerrar',
                                    style: TextStyle(color: sageGreen)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
