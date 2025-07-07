import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_toggle_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cart = [];
  @override
  void initState() {
    super.initState();
    loadCart();
  }
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    setState(() {
      cart = cartString != null ? json.decode(cartString) : [];
    });
  }
  void goToCheckout() {
    Navigator.pushNamed(context, '/checkout').then((_) => loadCart());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito'),
      actions: const [
  ThemeToggleButton(),
],),
      body: cart.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final product = cart[index];
                      return ListTile(
                        title: Text(product['nombre'] ?? ''),
                        subtitle: Text('Cantidad: ${product['cantidad'] ?? 1}'),
                        trailing: Text('\$${product['precio'] ?? ''}'),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: goToCheckout,
                  child: const Text('Comprar'),
                ),
              ],
            ),
    );
  }
}