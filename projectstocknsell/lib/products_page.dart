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

  final Color sageGreen = const Color(0xFF9CAF88);
  final Color beige = const Color(0xFFF5F5DC);
  final Color beigeDark = const Color(0xFFE6DCC3);

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
          backgroundColor: beige,
          title: Text('Selecciona cantidad (Stock: $stock)',
              style: TextStyle(color: sageGreen)),
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
              child: Text('Cancelar', style: TextStyle(color: sageGreen)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sageGreen,
              ),
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
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: sageGreen,
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
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return Card(
                  color: beigeDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      product['nombre'] ?? 'Sin nombre',
                      style: TextStyle(
                        color: sageGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['descripcion'] ?? ''),
                        const SizedBox(height: 8),
                        Text(
                          '\$${product['precio']?.toString() ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: sageGreen),
                      onPressed: () => showQuantityDialog(product),
                    ),
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
