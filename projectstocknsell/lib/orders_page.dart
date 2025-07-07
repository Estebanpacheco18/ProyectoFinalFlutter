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
      appBar: AppBar(title: const Text('Pedidos'),
      actions: const [
  ThemeToggleButton(),
],
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No hay pedidos'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Pedido ${index + 1}'),
                  subtitle: Text('Fecha: ${order['fecha']}'),
                  onTap: () {
                    // Puedes mostrar detalles del pedido aquí
                  },
                );
              },
            ),
    );
  }
}