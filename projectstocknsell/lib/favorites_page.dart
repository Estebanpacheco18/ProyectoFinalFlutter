import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites');
    setState(() {
      favorites = favString != null ? json.decode(favString) : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Favoritos'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No hay productos favoritos.'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return ListTile(
                  leading: product['imagen'] != null
                      ? Image.network(product['imagen'], width: 50, height: 50)
                      : null,
                  title: Text(product['nombre'] ?? ''),
                  subtitle: Text(product['descripcion'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                        tooltip: 'Añadir al carrito',
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final cartString = prefs.getString('cart');
                          List<dynamic> cart = cartString != null ? json.decode(cartString) : [];
                          bool found = false;
                          for (var item in cart) {
                            if (item['_id'] == product['_id']) {
                              item['cantidad'] = (item['cantidad'] ?? 0) + 1;
                              found = true;
                              break;
                            }
                          }
                          if (!found) {
                            cart.add({...product, 'cantidad': 1});
                          }
                          await prefs.setString('cart', json.encode(cart));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Producto agregado al carrito')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            favorites.removeAt(index);
                            prefs.setString('favorites', json.encode(favorites));
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}