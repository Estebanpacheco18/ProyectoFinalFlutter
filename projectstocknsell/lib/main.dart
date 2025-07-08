import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'home_page.dart';
import 'checkout_page.dart';

void main() {
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Productos',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF9CAF88), // sageGreen
            scaffoldBackgroundColor: const Color(0xFFF5F5DC), // beige
            cardColor: const Color(0xFFE6DCC3), // beigeDark
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF9CAF88),
              foregroundColor: Colors.black,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black87),
              bodyLarge: TextStyle(color: Colors.black87),
              titleLarge: TextStyle(color: Colors.black87),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9CAF88),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF9CAF88),
            scaffoldBackgroundColor: const Color(0xFF23231F), // beige oscuro
            cardColor: const Color(0xFF3A3A2E), // beigeDark oscuro
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF9CAF88),
              foregroundColor: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9CAF88),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/home': (context) => const HomePage(),
            '/checkout': (context) => const CheckoutPage(),
          },
        );
      },
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.title});
  final String title;

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

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
                  trailing: Text('\$${product['precio']?.toString() ?? ''}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}