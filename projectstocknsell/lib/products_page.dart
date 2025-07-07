import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_toggle_button.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<dynamic>> _products;

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://laboratorio06-web-backend.onrender.com/api/products'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<void> showQuantityDialog(Map<String, dynamic> product) async {
    int quantity = 1;
    int stock = product['stock'] ?? 1;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecciona cantidad (Stock: $stock)'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: quantity > 1
                        ? () => setState(() => quantity--)
                        : null,
                  ),
                  Text('$quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: quantity < stock
                        ? () => setState(() => quantity++)
                        : null,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                addToCart(product, quantity);
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addToCart(Map<String, dynamic> product, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    List<dynamic> cart = cartString != null ? json.decode(cartString) : [];
    cart.add({...product, 'cantidad': quantity});
    await prefs.setString('cart', json.encode(cart));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado al carrito')),
    );
  }

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: const [ThemeToggleButton()],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ListTile(
                  title: Text(product['nombre'] ?? 'Sin nombre'),
                  subtitle: Text(product['descripcion'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${product['precio']?.toString() ?? ''}'),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => showQuantityDialog(product),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}