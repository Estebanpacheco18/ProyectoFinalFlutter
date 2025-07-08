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

class _ProductsPageState extends State<ProductsPage> with TickerProviderStateMixin {
  late Future<List<dynamic>> _products;
  int? _animatingIndex;

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

  Future<void> addToCart(Map<String, dynamic> product, int quantity, int index) async {
    setState(() => _animatingIndex = index);
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    List<dynamic> cart = cartString != null ? json.decode(cartString) : [];
    cart.add({...product, 'cantidad': quantity});
    await prefs.setString('cart', json.encode(cart));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado al carrito')),
    );
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() => _animatingIndex = null);
  }

  Future<void> showQuantityDialog(Map<String, dynamic> product, int index) async {
    int quantity = 1;
    int stock = product['stock'] ?? 1;
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Selecciona cantidad (Stock: $stock)',
              style: TextStyle(color: theme.primaryColor)),
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
              child: Text('Cancelar', style: TextStyle(color: theme.primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
              ),
              onPressed: () {
                addToCart(product, quantity, index);
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
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
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 400 + index * 50),
                  opacity: 1,
                  child: Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: product['imagen'] != null && product['imagen'].toString().isNotEmpty
                                  ? Image.network(
                                      product['imagen'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 60),
                                    )
                                  : const Center(
                                      child: Icon(Icons.image_not_supported, size: 60),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product['nombre'] ?? 'Sin nombre',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(product['descripcion'] ?? ''),
                          const SizedBox(height: 8),
                          Text(
                            '\$${product['precio']?.toString() ?? ''}',
                            style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: (product['stock'] ?? 0) > 0
                                ? AnimatedScale(
                                    scale: _animatingIndex == index ? 1.3 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: IconButton(
                                      icon: Icon(Icons.add_shopping_cart, color: theme.primaryColor),
                                      onPressed: () => showQuantityDialog(product, index),
                                      tooltip: 'Añadir al carrito',
                                    ),
                                  )
                                : const Text(
                                    'Sin stock',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
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